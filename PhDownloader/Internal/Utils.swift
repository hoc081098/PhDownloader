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

internal func removeFile(of task: PhDownloadTask, _ deleteFile: (PhDownloadTask) -> Bool) throws {
  let url = task.request.savedDir.appendingPathComponent(task.request.fileName)

  do {
    if deleteFile(task), FileManager.default.fileExists(atPath: url.path) {
      try FileManager.default.removeItem(at: url)
    }
  } catch {
    throw PhDownloaderError.fileDeletingError(error)
  }
}
