//
//  DIGraph.swift
//  PhDownloader
//
//  Created by Petrus Nguyễn Thái Học on 10/21/22.
//  Copyright © 2022 Petrus Nguyễn Thái Học. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

internal enum DIGraph {
  private static let downloadPath = "hoc081098_PhDownloader"
  private static let realmFilePath = "phdownloader_default.realm"
  private static var fileManager: FileManager { FileManager.default }
  
  internal static func providePhDownloaderDirectory() throws -> URL {
    let url = Self.fileManager
      .urls(for: .documentDirectory, in: .userDomainMask)
      .first!
      .appendingPathComponent(Self.downloadPath, isDirectory: true)

    if !Self.fileManager.fileExists(atPath: url.path) {
      try Self.fileManager.createDirectory(at: url, withIntermediateDirectories: true)
    }

    return url
  }
  
  internal static func provideRealmAdapter() throws -> RealmAdapter {
    let fileURL = try Self.providePhDownloaderDirectory()
      .appendingPathComponent(Self.realmFilePath)

    let configuration = Realm.Configuration(
      fileURL: fileURL,
      // Set the new schema version. This must be greater than the previously used
      // version (if you've never set a schema version before, the version is 0).
      schemaVersion: 1,

      // Set the block which will be called automatically when opening a Realm with
      // a schema version lower than the one set above
      migrationBlock: { migration, oldSchemaVersion in
        // We haven’t migrated anything yet, so oldSchemaVersion == 0
        if (oldSchemaVersion < 1) {
          // Nothing to do!
          // Realm will automatically detect new properties and removed properties
          // And will update the schema on disk automatically
        }
      }
    )

    return try Realm(configuration: configuration)
  }
  
  internal static func prodiveLocalDataSource(options: PhDownloaderOptions) -> LocalDataSource {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = options.maxConcurrent * 2

    return RealLocalDataSource(
      realmInitializer: Self.provideRealmAdapter,
      queue: queue
    )
  }
  
  internal static func providePhDownloader(options: PhDownloaderOptions) -> PhDownloader {
    RealDownloader(
      options: options,
      dataSource: Self.prodiveLocalDataSource(options: options)
    )
  }
}
