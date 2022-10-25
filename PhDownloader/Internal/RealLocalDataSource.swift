//
//  RealLocalDataSource.swift
//  PhDownloader
//
//  Created by Petrus Nguyễn Thái Học on 10/21/22.
//  Copyright © 2022 Petrus Nguyễn Thái Học. All rights reserved.
//

import Foundation
import RxSwift
import Realm
import RealmSwift

private class CancellationError: Error {
  static let shared = CancellationError()
}

private typealias CheckDisposed = () throws -> Void

final internal class RealLocalDataSource: LocalDataSource {

  /// Since we use `Realm` in background thread
  private let realmInitializer: RealmInitializer

  /// DispatchQueue that is used to dispatch blocks that updated realm `Object`
  private let realmDispatchQueue = DispatchQueue(
    label: "com.hoc081098.ph_downloader.realm.serial-queue",
    qos: .userInitiated
  )

  init(realmInitializer: @escaping RealmInitializer) {
    self.realmInitializer = realmInitializer
  }
  
  private func getRefreshedRealmAdapter() throws -> RealmAdapter {
    let realm = try self.realmInitializer()
    
    let refreshResult = realm.refresh()
    print("[PhDownloader] [DEBUG] getRefreshedRealmAdapter refreshResult=\(refreshResult)")
    
    return realm
  }

  private func useRealmAdapter<T>(block: @escaping (RealmAdapter, CheckDisposed) throws -> T) -> Single<T> {
      .create { [realmDispatchQueue, realmInitializer] obsever -> Disposable in
      let disposable = SafeBooleanDisposable()

      let item = DispatchWorkItem {
        if disposable.isDisposed { return }

        autoreleasepool {
          do {
            let realm = try realmInitializer()
            if disposable.isDisposed { return }

            let refreshResult = realm.refresh()
            print("[PhDownloader] [DEBUG] useRealmAdapter refreshResult=\(refreshResult)")
            if disposable.isDisposed { return }

            let result = try block(realm) {
              if disposable.isDisposed {
                throw CancellationError.shared
              }
            }

            obsever(.success(result))
          }
          catch _ as CancellationError {
            // already disposed
          }
          catch {
            obsever(.failure(error))
          }
        }
      }

      realmDispatchQueue.async(execute: item)

      return Disposables.create(disposable, Disposables.create(with: item.cancel))
    }
  }

  func update(id: String, state: PhDownloadState) -> Completable {
    useRealmAdapter { realm, checkDisposed in
      let task = try realm.findDownloadTaskEntity(by: id)

      try checkDisposed()

      guard task.canTransition(to: state) else {
        print("[PhDownloader] [DEBUG] cannot transition from \(task.phDownloadState) to \(state)")
        return
      }
      
      if state == .cancelled, !task.canCancel {
        print("[PhDownloader] [DEBUG] cannot cancel \(id), task.state=\(task.phDownloadState)")
        throw PhDownloaderError.cannotCancel(identifier: id)
      }

      try checkDisposed()

      do {
        try realm.write(withoutNotifying: []) {
          task.update(to: state)
          task.updatedAt = .init()
        }
      } catch {
        throw PhDownloaderError.databaseError(error)
      }
    }.asCompletable()
  }

  func insertOrUpdate(
    identifier: String,
    url: URL,
    destinationURL: URL,
    state: PhDownloadState
  ) -> Completable {
    useRealmAdapter { realm, checkDisposed in
      do {
        try realm.write(withoutNotifying: []) {
          realm.add(
            DownloadTaskEntity(
              identifier: identifier,
              url: url,
              destinationURL: destinationURL,
              state: state,
              updatedAt: .init()
            ),
            update: .modified
          )
        }
      } catch {
        throw PhDownloaderError.databaseError(error)
      }
    }.asCompletable()
  }

  func getResults(by ids: Set<String>) throws -> Results<DownloadTaskEntity> {
    MainScheduler.ensureRunningOnMainThread()
    
    return try self.getRefreshedRealmAdapter()
      .objects(DownloadTaskEntity.self)
      .filter("SELF.identifier IN %@", ids)
  }

  func getResults(by id: String) throws -> Results<DownloadTaskEntity> {
    MainScheduler.ensureRunningOnMainThread()

    return try self.getRefreshedRealmAdapter()
      .objects(DownloadTaskEntity.self)
      .filter("SELF.identifier = %@", id)
  }

  func get(by id: String) throws -> DownloadTaskEntity {
    MainScheduler.ensureRunningOnMainThread()
    
    return try self.getRefreshedRealmAdapter().findDownloadTaskEntity(by: id)
  }

  func cancelAll() -> Completable {
    useRealmAdapter { realm, checkDisposed in
      let entities = realm
        .objects(DownloadTaskEntity.self)
        .filter(
          "SELF.state = %@ OR SELF.state = %@",
          DownloadTaskEntity.RawState.enqueued.rawValue,
          DownloadTaskEntity.RawState.downloading.rawValue
        )

      try checkDisposed()

      do {
        try realm.write(withoutNotifying: []) {
          entities.forEach { entity in
            entity.update(to: .cancelled)
            entity.updatedAt = .init()
          }
        }
      } catch {
        throw PhDownloaderError.databaseError(error)
      }
    }.asCompletable()
  }

  func remove(by id: String) -> Single<DownloadTaskEntity> {
    useRealmAdapter { realm, checkDisposed in
      let task = try realm.findDownloadTaskEntity(by: id)
      let copy = DownloadTaskEntity(value: task)
      
      try checkDisposed()
      
      do {
        try realm.write(withoutNotifying: []) {
          realm.delete(task)
        }
      } catch {
        throw PhDownloaderError.databaseError(error)
      }
      
      return copy
    }
  }

  func removeAll() -> Single<[DownloadTaskEntity]> {
    useRealmAdapter { realm, checkDisposed in
      let entities = Array(
        realm
          .objects(DownloadTaskEntity.self)
          .map { DownloadTaskEntity(value: $0) }
      )

      try checkDisposed()

      do {
        try realm.write(withoutNotifying: []) { realm.deleteAll() }
      } catch {
        throw PhDownloaderError.databaseError(error)
      }

      return entities
    }
  }
}

extension RealmAdapter {
  /// - Throws: `PhDownloaderError.notFound` if not found
  fileprivate func findDownloadTaskEntity(by id: String) throws -> DownloadTaskEntity {
    if let task = self.object(ofType: DownloadTaskEntity.self, forPrimaryKey: id) {
      return task
    }
    throw PhDownloaderError.notFound(identifier: id)
  }
}
