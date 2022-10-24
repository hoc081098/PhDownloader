//
//  Utils.swift
//  PhDownloader
//
//  Created by Petrus Nguyễn Thái Học on 10/21/22.
//  Copyright © 2022 Petrus Nguyễn Thái Học. All rights reserved.
//

import Foundation
import RxSwift
import RxAlamofire

@available(*, unavailable, message: "Use single argument print(item: Any) instead")
internal func print(
  _ items: Any...,
  separator: String = " ",
  terminator: String = "\n"
) { }

internal func print(
  _ item: @autoclosure () -> Any,
  terminator: String = "\n"
) {
  #if DEBUG
    Swift.print(item(), terminator: terminator)
  #endif
}

internal func percentage(bytesWritten: Int64, totalBytes: Int64) -> Int {
  guard totalBytes > 0 else { return 0 }
  let percent = Double(bytesWritten) / Double(totalBytes)
  return Int(100 * percent)
}

extension Event where Element == RxProgress {
  func asDownloadState(_ isCompleted: Bool) -> PhDownloadState {
    switch self {
    case .next(let progress):
      let bytesWritten = progress.bytesWritten
      let totalBytes = progress.totalBytes

      return .downloading(
        bytesWritten: bytesWritten,
        totalBytes: totalBytes,
        percentage: percentage(
          bytesWritten: bytesWritten,
          totalBytes: totalBytes
        )
      )
    case .error:
      return .failed
    case .completed:
      return isCompleted ? .completed : .cancelled
    }
  }
}

extension FileManager {
  internal func removeFile(of task: PhDownloadTask, _ deleteFile: (PhDownloadTask) -> Bool) throws {
    let url = task.request.savedDir.appendingPathComponent(task.request.fileName)

    do {
      if deleteFile(task), self.fileExists(atPath: url.path) {
        try self.removeItem(at: url)
      }
    } catch {
      throw PhDownloaderError.fileDeletingError(error)
    }
  }
}

/// Represents a disposable resource that can be checked for disposal status.
internal final class SafeBooleanDisposable: Cancelable {
  private var disposed: Bool
  private let lock = NSLock()

  /// Initializes a new instance of the `BooleanDisposable` class
  public init() {
    disposed = false
  }

  /// - returns: Was resource disposed.
  public var isDisposed: Bool {
    lock.lock()
    defer { lock.unlock() }

    return self.disposed
  }

  /// Sets the status to disposed, which can be observer through the `isDisposed` property.
  public func dispose() {
    lock.lock()
    defer { lock.unlock() }

    self.disposed = true
  }
}

internal func currentDispatchQueueLabel() -> String {
  .init(cString: __dispatch_queue_get_label(nil))
}
