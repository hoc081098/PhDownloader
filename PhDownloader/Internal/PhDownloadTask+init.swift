//
//  PhDownloadTask+init.swift
//  PhDownloader
//
//  Created by Petrus Nguyễn Thái Học on 10/21/22.
//  Copyright © 2022 Petrus Nguyễn Thái Học. All rights reserved.
//

import Foundation

extension PhDownloadTask {
  internal init(from entity: DownloadTaskEntity) {
    self.init(
      request: .init(
        identifier: entity.identifier,
        url: URL(string: entity.url)!,
        fileName: entity.fileName,
        savedDir: URL(fileURLWithPath: entity.savedDir)
      ),
      state: entity.phDownloadState
    )
  }
}
