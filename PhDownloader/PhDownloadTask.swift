//
//  PhDownloadTask.swift
//  PhDownloader
//
//  Created by Petrus Nguyễn Thái Học on 7/15/20.
//  Copyright © 2020 Petrus Nguyễn Thái Học. All rights reserved.
//

import Foundation

/// A model class encapsulates all information about download task
public struct PhDownloadTask: Hashable {
  /// The unique identifier of download request
  public let identifier: String

  /// The download url
  public let url: URL

  /// The local file URL where the downloaded file will be saved
  public let destinationURL: URL

  /// The latest state of download task
  public let state: PhDownloadState
  
  public init(
    identifier: String,
    url: URL,
    destinationURL: URL,
    state: PhDownloadState
  ) {
    self.identifier = identifier
    self.url = url
    self.destinationURL = destinationURL
    self.state = state
  }
}

// MARK: PhDownloadTask + request
extension PhDownloadTask {
  /// The request that executes this task
  public var request: PhDownloadRequest {
    .init(
      identifier: self.identifier,
      url: self.url,
      destinationURL: self.destinationURL
    )
  }
}
