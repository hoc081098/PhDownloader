//
//  PhDownloadResult.swift
//  PhDownloader
//
//  Created by Petrus Nguyễn Thái Học on 10/21/22.
//  Copyright © 2022 Petrus Nguyễn Thái Học. All rights reserved.
//

import Foundation

/// Represents downloader result in three cases: `success`, `cancelled`, `failure`
/// - Tag: PhDownloadResult
public enum PhDownloadResult {
  case success(PhDownloadRequest)
  case cancelled(PhDownloadRequest)
  case failure(PhDownloadRequest, PhDownloaderError)

  /// Returns original request.
  var request: PhDownloadRequest {
    switch self {
    case .success(let request): return request
    case .cancelled(let request): return request
    case .failure(let request, _): return request
    }
  }

  /// If this is a failed result, returns error.
  /// Otherwise, returns `nil`
  var error: PhDownloaderError? {
    switch self {
    case .success: return nil
    case .cancelled: return nil
    case .failure(_, let error): return error
    }
  }
}
