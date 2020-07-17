//
//  PhDownloaderOptions.swift
//  PhDownloader
//
//  Created by Petrus Nguyễn Thái Học on 7/4/20.
//  Copyright © 2020 Petrus Nguyễn Thái Học. All rights reserved.
//

import Foundation

public struct PhDownloaderOptions {
  public static let defaultOptions = PhDownloaderOptions(
    maxConcurrent: ProcessInfo.processInfo.processorCount,
    throttleProgress: .milliseconds(200)
  )

  public let maxConcurrent: Int
  public let throttleProgress: DispatchTimeInterval

  public init(
    maxConcurrent: Int,
    throttleProgress: DispatchTimeInterval
  ) {
    self.maxConcurrent = maxConcurrent
    self.throttleProgress = throttleProgress
  }
}
