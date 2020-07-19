//
//  PhDownloaderOptions.swift
//  PhDownloader
//
//  Created by Petrus Nguyễn Thái Học on 7/4/20.
//  Copyright © 2020 Petrus Nguyễn Thái Học. All rights reserved.
//

import Foundation

/// The options that used to build a `PhDownloader`.
/// Passing a `PhDownloaderOptions` to `PhDownloaderFactory.makeDownloader(with:)` to get downloader.
public struct PhDownloaderOptions {

  /// Default options with
  /// * `maxConcurrent` is the number of processing cores available on the computer
  /// * `throttleProgress` is 200 milliseconds
  public static let defaultOptions = PhDownloaderOptions(
    maxConcurrent: ProcessInfo.processInfo.processorCount,
    throttleProgress: .milliseconds(200)
  )

  /// Maximum number of download request being running to concurrently.
  public let maxConcurrent: Int

  /// Throttling duration for each progress element.
  /// Because the current process status updates quite quickly, use this value to limit number updates in a time window.
  public let throttleProgress: DispatchTimeInterval

  public init(
    maxConcurrent: Int,
    throttleProgress: DispatchTimeInterval
  ) {
    self.maxConcurrent = maxConcurrent
    self.throttleProgress = throttleProgress
  }
}
