//
//  PhDownloaderError.swift
//  PhDownloader
//
//  Created by Petrus Nguyễn Thái Học on 10/21/22.
//  Copyright © 2022 Petrus Nguyễn Thái Học. All rights reserved.
//

import Foundation

/// Represents downloader errors
/// - Tag: PhDownloaderError
public enum PhDownloaderError: Error, CustomDebugStringConvertible {
  /// Realm database error
  case databaseError(Error)

  /// Download error: No internet connection, file writing error, ...
  case downloadError(Error)

  /// Not found download task by identifier.
  case notFound(identifier: String)

  /// Task cannot be cancelled
  case cannotCancel(identifier: String)

  /// Error when deleting file
  case fileDeletingError(Error)

  public var debugDescription: String {
    switch self {
    case .downloadError(let error):
      return "Download failure: \(error)."
    case .databaseError(let error):
      return "Database error: \(error)."
    case .notFound(let identifier):
      return "Not found task with identifier: \(identifier)."
    case .cannotCancel(let identifier):
      return "Cannot cancel task with identifier: \(identifier). Because state of task is finish (completed, failed or cancelled) or undefined."
    case .fileDeletingError(let error):
      return "File deleting error: \(error)."
    }
  }
}
