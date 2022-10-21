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
  func getResults(by ids: Set<String>) throws -> Results<DownloadTaskEntity>

  /// Get `Results` by single id.
  /// Executing on main thread.
  func getResults(by id: String) throws -> Results<DownloadTaskEntity>

  /// Get single task by id.
  /// Executing on main thread.
  func get(by id: String) throws -> DownloadTaskEntity?

  /// Mask all enqueued or running tasks as cancelled.
  func cancelAll() -> Completable

  /// Remove task from database.
  /// Executing on main thread.
  func remove(by id: String) throws -> DownloadTaskEntity

  /// Remove all tasks
  func removeAll() -> Single<[DownloadTaskEntity]>
}
