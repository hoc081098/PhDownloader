//
//  PhDownloader.swift
//  PhDownloader
//
//  Created by Petrus Nguyễn Thái Học on 7/4/20.
//  Copyright © 2020 Petrus Nguyễn Thái Học. All rights reserved.
//

import Foundation
import RxSwift

// MARK: - PhDownloader

public protocol PhDownloader {
  // MARK: Observer
  
  /// Observe state of download task by id
  /// - Parameter identifier: request id
  /// - Returns: an `Observable` that emits nil if task does not exist, otherwise it will emit the download task.
  func observe(by identifier: String) -> Observable<PhDownloadTask?>

  /// Observe state of download tasks by multiple ids
  /// - Parameter identifiers: request ids
  /// - Returns: an `Observable` that emits a dictionary with id as key, download task as value
  func observe<T: Sequence>(by identifiers: T) -> Observable<[String: PhDownloadTask]> where T.Element == String

  /// Download result event observable
  /// # Reference:
  /// [PhDownloadResult](x-source-tag://PhDownloadResult)
  var downloadResult$: Observable<PhDownloadResult> { get }

  // MARK: Enqueue

  /// Enqueue a download request
  func enqueue(_ request: PhDownloadRequest) -> Completable

  // MARK: Cancel (also delete files)

  /// Cancel enqueued and running download task by identifier
  func cancel(by identifier: String) -> Completable

  /// Cancel all enqueued and running download tasks
  func cancelAll() -> Completable

  // MARK: Remove (and delete files)

  /// Delete a download task from database.
  /// If the given task is running, it is canceled as well.
  /// If the task is completed and result from invoking `deleteFile` is true, the downloaded file will be deleted.
  func remove(by identifier: String, and deleteFile: @escaping (PhDownloadTask) -> Bool) -> Completable

  /// Delete all tasks from database.
  /// Canceled all running tasks.
  /// If the task is completed and result from invoking `deleteFile` is true, the downloaded file will be deleted.
  func removeAll(deleteFile: @escaping (PhDownloadTask) -> Bool) -> Completable
}

extension PhDownloader {
  /// Delete a download task from database.
  /// If the given task is running, it is canceled as well.
  /// If the task is completed, the downloaded file will be deleted.
  public func removeAndDeleteFile(by identifier: String) -> Completable {
    self.remove(by: identifier) { _ in true }
  }

  /// Delete all tasks from database.
  /// Canceled all running tasks.
  /// If the task is completed, the downloaded files will be deleted.
  public func removeAllAndDeleteFiles() -> Completable {
    self.removeAll { _ in true }
  }
}

/// Provide `PhDownloader` from `PhDownloaderOptions`
public enum PhDownloaderFactory {

  /// Provide `PhDownloader` from `PhDownloaderOptions`
  public static func makeDownloader(with options: PhDownloaderOptions) -> PhDownloader {
    DIGraph.providePhDownloader(options: options)
  }
}
