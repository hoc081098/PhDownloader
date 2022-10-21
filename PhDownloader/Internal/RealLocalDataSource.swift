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

final internal class RealLocalDataSource: LocalDataSource {

  /// Since we use `Realm` in background thread
  private let realmInitializer: () throws -> RealmAdapter

  /// OperationQueue that is used to dispatch blocks that updated realm `Object`
  private let queue: OperationQueue

  /// Scheduler that schedule query works
  private let queryScheduler = ConcurrentDispatchQueueScheduler(
    queue: .init(
      label: "RealLocalDataSource.QueryQueue",
      qos: .userInitiated,
      attributes: .concurrent
    )
  )

  init(realmInitializer: @escaping () throws -> RealmAdapter, queue: OperationQueue) {
    self.realmInitializer = realmInitializer
    self.queue = queue
  }

  func update(id: String, state: PhDownloadState) -> Completable {
      .create { [queue, realmInitializer] obsever -> Disposable in
        let disposable = BooleanDisposable()

        queue.addOperation {
          autoreleasepool {
            do {
              if disposable.isDisposed { return }

              let realm = try realmInitializer()

              guard let task = Self.find(by: id, in: realm) else {
                let error = PhDownloaderError.notFound(identifier: id)
                return obsever(.error(error))
              }

              if disposable.isDisposed { return }

              guard task.canTransition(to: state) else {
                print("[PhDownloader] cannot transition from \(task.phDownloadState) to \(state)")
                obsever(.completed)
                return
              }

              try realm.write(withoutNotifying: []) {
                task.update(to: state)
                task.updatedAt = .init()
              }

              obsever(.completed)
            } catch {
              obsever(.error(error))
            }
          }
        }

        return disposable
    }
  }

  func insertOrUpdate(
    identifier: String,
    url: URL,
    fileName: String,
    savedDir: URL,
    state: PhDownloadState
  ) -> Completable {
      .create { [queue, realmInitializer] observer -> Disposable in
        let disposable = BooleanDisposable()

        queue.addOperation {
          autoreleasepool {
            do {
              if disposable.isDisposed { return }

              let realm = try realmInitializer()

              if disposable.isDisposed { return }

              try realm.write(withoutNotifying: []) {
                realm.add(
                  DownloadTaskEntity(
                    identifier: identifier,
                    url: url,
                    fileName: fileName,
                    savedDir: savedDir,
                    state: state,
                    updatedAt: .init()
                  ),
                  update: .modified
                )
              }

              observer(.completed)
            } catch {
              observer(.error(error))
            }
          }
        }

        return disposable
    }
  }

  func getResults(by ids: Set<String>) throws -> Results<DownloadTaskEntity> {
    MainScheduler.ensureExecutingOnScheduler()

    do {
      return try self.realmInitializer()
        .objects(DownloadTaskEntity.self)
        .filter("SELF.identifier IN %@", ids)
    } catch {
      throw PhDownloaderError.databaseError(error)
    }
  }

  func getResults(by id: String) throws -> Results<DownloadTaskEntity> {
    MainScheduler.ensureExecutingOnScheduler()

    do {
      return try self.realmInitializer()
        .objects(DownloadTaskEntity.self)
        .filter("SELF.identifier = %@", id)
    } catch {
      throw PhDownloaderError.databaseError(error)
    }
  }

  func get(by id: String) throws -> DownloadTaskEntity? {
    MainScheduler.ensureExecutingOnScheduler()

    do {
      return Self.find(by: id, in: try self.realmInitializer())
    } catch {
      throw PhDownloaderError.databaseError(error)
    }
  }

  func cancelAll() -> Completable {
    Completable
      .deferred {
        autoreleasepool {
          do {
            let realm = try self.realmInitializer()
            _ = realm.refresh()

            let entities = realm
              .objects(DownloadTaskEntity.self)
              .filter(
                "SELF.state = %@ OR SELF.state = %@",
                DownloadTaskEntity.RawState.enqueued.rawValue,
                DownloadTaskEntity.RawState.downloading.rawValue
              )

            try realm.write(withoutNotifying: []) {
              entities.forEach { entity in
                entity.update(to: .cancelled)
                entity.updatedAt = .init()
              }
            }

            return .empty()
          } catch {
            return .error(PhDownloaderError.databaseError(error))
          }
        }
      }
      .subscribe(on: self.queryScheduler)
  }

  func remove(by id: String) throws -> DownloadTaskEntity {
    MainScheduler.ensureExecutingOnScheduler()

    do {
      let realm = try self.realmInitializer()

      guard let task = Self.find(by: id, in: realm) else { throw PhDownloaderError.notFound(identifier: id) }
      let copy = DownloadTaskEntity(value: task)

      try realm.write(withoutNotifying: []) {
        realm.delete(task)
      }

      return copy
    } catch let phError as PhDownloaderError {
      throw phError
    } catch {
      throw PhDownloaderError.databaseError(error)
    }
  }

  func removeAll() -> Single<[DownloadTaskEntity]> {
    Single
      .deferred { () -> Single<[DownloadTaskEntity]> in
        autoreleasepool {
          do {
            let realm = try self.realmInitializer()
            _ = realm.refresh()

            let entities = Array(
              realm
                .objects(DownloadTaskEntity.self)
                .map { DownloadTaskEntity(value: $0) }
            )

            try realm.write(withoutNotifying: []) { realm.deleteAll() }

            return .just(entities)
          } catch {
            return .error(PhDownloaderError.databaseError(error))
          }
        }
      }
      .subscribe(on: self.queryScheduler)
  }

  private static func find(by id: String, in realm: RealmAdapter) -> DownloadTaskEntity? {
    _ = realm.refresh()
    return realm.object(ofType: DownloadTaskEntity.self, forPrimaryKey: id)
  }
}
