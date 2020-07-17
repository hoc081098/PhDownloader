//
//  PhDownloadState.swift
//  PhDownloader Example
//
//  Created by Petrus on 7/4/20.
//  Copyright © 2020 Petrus Nguyễn Thái Học. All rights reserved.
//

import Foundation

/// The current lifecycle state of a `PhDownloadRequest`.
public enum PhDownloadState: CustomDebugStringConvertible, Hashable {
  case undefined

  /// Used to indicate that the `PhDownloadRequest`  is enqueued and eligible to run when its resources are available.
  case enqueued

  /// Used to indicate that the `PhDownloadRequest`  is currently being executed.
  case downloading(bytesWritten: Int64, totalBytes: Int64, percentage: Int)

  /// Used to indicate that the `PhDownloadRequest` has completed in a successful state.
  case completed

  /// Used to indicate that the `PhDownloadRequest` has completed in a failure state.
  case failed

  /// Used to indicate that the `PhDownloadRequest` has been cancelled and will not execute.
  case cancelled

  public var debugDescription: String {
    switch self {
    case .undefined:
      return "undefined"
    case .enqueued:
      return "enqueue"
    case .downloading(let bytesWritten, let totalBytes, let percentage):
      return "downloading: \(percentage)% bytesWritten=\(bytesWritten), totalBytes=\(totalBytes)"
    case .completed:
      return "completed"
    case .failed:
      return "failed"
    case .cancelled:
      return "cancelled"
    }
  }
}
