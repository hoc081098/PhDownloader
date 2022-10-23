//
//  ViewModel.swift
//  PhDownloader Example
//
//  Created by Petrus Nguyễn Thái Học on 10/19/22.
//

import Foundation
import PhDownloader
import Combine
import RxSwift

struct Item {
  let request: PhDownloadRequest
  var state: PhDownloadState
}

enum DIGraph {
  // Singleton
  static let downloader: PhDownloader = PhDownloaderFactory.makeDownloader(with: .init(
    maxConcurrent: 2,
    throttleProgress: .milliseconds(500))
  )
}

@MainActor
class ViewModel: ObservableObject {
  private let disposeBag = DisposeBag()
  
  private var downloader: PhDownloader { DIGraph.downloader }

  private static let saveDir = FileManager.default
    .urls(for: .documentDirectory, in: .userDomainMask)
    .first!
    .appendingPathComponent("downloads", isDirectory: true)

  private static func genItems() -> [Item] {
    (0..<100).map { i in
        .init(
        request: .init(
          identifier: String(i),
          url: URL(string: "https://file-examples.com/storage/fe4b4c6261634c76e91986b/2017/04/file_example_MP4_1920_18MG.mp4")!,
          fileName: "test_file_\(i).mp4",
          savedDir: Self.saveDir
        ),
        state: .undefined
      )
    }
  }

  @Published
  private(set) var items: [Item] = ViewModel.genItems()

  init() {
    print("saveDir=\(Self.saveDir)")
    
    self.downloader
      .downloadResult$
      .subscribe(onNext: {event in
        switch event {
        case .success(let request):
          print("[Result] Success: id=\(request.identifier)")
        case .cancelled(let request):
          print("[Result] Cancelled: id=\(request.identifier)")
        case .failure(let request, let error):
          print("[Result] Failure: id=\(request.identifier), error=\(error)")
        }
      })
      .disposed(by: self.disposeBag)
    
    self.downloader
      .observe(by: self.items.map(\.request.identifier))
      .subscribe(
        onNext: { [weak self] tasks in
          guard let self = self else { return }

          self.items = self.items.map { item in
            var newItem = item
            newItem.state = tasks[item.request.identifier]?.state
              ?? .undefined
            return newItem
          }
        }
      )
      .disposed(by: self.disposeBag)
  }
  
  func cancelAll() {
    self.downloader
      .cancelAll()
      .subscribe(
        onCompleted: { print("[Cancel all] Success") },
        onError: { print("[Cancel all] Failure: error=\($0)") }
      )
      .disposed(by: self.disposeBag)
  }
  
  func removeAll() {
    self.downloader
      .removeAll()
      .subscribe(
        onCompleted: { print("[Remove all] Success") },
        onError: { print("[Remove all] Failure: error=\($0)") }
      )
      .disposed(by: self.disposeBag)
  }

  func onTap(item: Item) {
    let id = item.request.identifier

    switch item.state {
    case .cancelled, .undefined:
      self.downloader
        .enqueue(item.request)
        .subscribe(
          onCompleted: { print("[Enqueue] Success: id=\(id)") },
          onError: { print("[Enqueue] Failure: id=\(id), error=\($0)") }
        )
        .disposed(by: self.disposeBag)

    case .completed:
      self.downloader
        .remove(identifier: id)
        .subscribe(
          onCompleted: { print("[Remove] Success: id=\(id)") },
          onError: { print("[Remove] Failure: id=\(id), error=\($0)") }
        )
        .disposed(by: self.disposeBag)

    default:
      self.downloader
        .cancel(by: id)
        .subscribe(
          onCompleted: { print("[Cancel] Success: id=\(id)") },
          onError: { print("[Cancel] Failure: id=\(id), error=\($0)") }
        )
        .disposed(by: self.disposeBag)
    }
  }
}
