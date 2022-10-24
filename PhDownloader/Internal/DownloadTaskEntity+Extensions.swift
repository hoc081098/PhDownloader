//
//  DownloadTaskEntity+Extensions.swift
//  PhDownloader
//
//  Created by Petrus Nguyễn Thái Học on 10/21/22.
//  Copyright © 2022 Petrus Nguyễn Thái Học. All rights reserved.
//

import Foundation


// MARK: DownloadTaskEntity + canCancel + canDownload + canTransition(to:)
extension DownloadTaskEntity {
  /// Enqueued or runnning state
  var canCancel: Bool {
    if self.phDownloadState == .enqueued { return true }
    if case .downloading = self.phDownloadState { return true }
    return false
  }

  var canDownload: Bool { self.phDownloadState != .cancelled }

  func canTransition(to newState: PhDownloadState) -> Bool {
    if self.phDownloadState == .cancelled {
      switch newState {
      case .undefined, .enqueued:
        return true
      case .downloading, .completed, .failed, .cancelled:
        // cannot transition from .cancelled to finished states or .cancelled itself.
        return false
      }
    }

    return true
  }
}
