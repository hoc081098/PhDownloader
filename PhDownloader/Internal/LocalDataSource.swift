//
//  LocalDataSource.swift
//  PhDownloader
//
//  Created by Petrus Nguyễn Thái Học on 10/21/22.
//  Copyright © 2022 Petrus Nguyễn Thái Học. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
import Realm

internal protocol LocalDataSource {

  /// Update download state for download task
  func update(id: String, state: PhDownloadState) -> Completable

  /// Insert or update download task
  func insertOrUpdate(
    identifier: String,
    url: URL,
    fileName: String,
    savedDir: URL,
    state: PhDownloadState
  ) -> Completable

  /// Get `Results` by multiple ids.
  /// Executing on main thread.
  /// - Throws: `PhDownloaderError.databaseError`
  func getResults(by ids: Set<String>) throws -> Results<DownloadTaskEntity>

  /// Get `Results` by single id.
  /// Executing on main thread.
  /// - Throws: `PhDownloaderError.databaseError`
  func getResults(by id: String) throws -> Results<DownloadTaskEntity>

  /// Get single task by id.
  /// Executing on main thread.
  /// - Throws: `PhDownloaderError.notFound` if not found or `PhDownloaderError.databaseError`.
  func get(by id: String) throws -> DownloadTaskEntity

  /// Mask all enqueued or running tasks as cancelled.
  func cancelAll() -> Completable

  /// Remove task from database.
  func remove(by id: String) -> Single<DownloadTaskEntity>

  /// Remove all tasks
  func removeAll() -> Single<[DownloadTaskEntity]>
}

extension LocalDataSource {
  /// Get single task by id, or `nil` if not found
  /// Executing on main thread.
  /// - Throws: `PhDownloaderError.databaseError`.
  func getOptional(by id: String) throws -> DownloadTaskEntity? {
    do {
      return try self.get(by: id)
    } catch let error as PhDownloaderError {
      if case .notFound = error {
        return nil
      }
      throw error
    }
  }
}
