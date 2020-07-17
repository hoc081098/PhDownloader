//
//  PhDownloadRequest.swift
//  PhDownloader Example
//
//  Created by Petrus on 7/4/20.
//  Copyright © 2020 Petrus Nguyễn Thái Học. All rights reserved.
//

import Foundation

/// Specifying parameters for work that should be enqueued.
public struct PhDownloadRequest: Hashable {

  /// The unique identifier of download request
  public let identifier: String

  /// The download url
  public let url: URL

  /// The local file name of downloaded file
  public let fileName: String

  /// The directory where the downloaded file is saved
  public let savedDir: URL

  public init(
    identifier: String,
    url: URL,
    fileName: String,
    savedDir: URL
  ) {
    self.identifier = identifier
    self.url = url
    self.fileName = fileName
    self.savedDir = savedDir
  }
}
