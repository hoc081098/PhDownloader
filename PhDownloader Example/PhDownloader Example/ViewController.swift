//
//  ViewController.swift
//  PhDownloader Example
//
//  Created by Petrus on 7/4/20.
//  Copyright © 2020 Petrus Nguyễn Thái Học. All rights reserved.
//

import UIKit
import RxSwift
import PhDownloader

struct Item {
  let request: PhDownloadRequest
  var state: PhDownloadState
}

class ViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!

  private let downloader: PhDownloader = PhDownloaderFactory.makeDownloader(with: .init(
    maxConcurrent: 2,
    throttleProgress: .milliseconds(500))
  )

  private let disposeBag = DisposeBag()

  private lazy var items: [Item] = (0..<100).map { i in
      .init(
        request: .init(
          identifier: String(i),
          url: URL(string: "https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_1920_18MG.mp4")!,
          fileName: "test_file_\(i).mp4",
          savedDir: FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("downloads", isDirectory: true)
        ),
        state: .undefined
      )
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = self
    self.tableView.delegate = self

    self.observeDownloader()
  }

  func observeDownloader() {
    print(
      FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)
        .first!
    )

    self.downloader
      .downloadResult$
      .subscribe(onNext: { result in
        switch result {
        case .success(let request):
          print("[Result] Success: id=\(request.identifier)")
        case .failure(let request, let error):
          print("[Result] Failure: id=\(request.identifier), error=\(error)")
        case .cancelled(let request):
          print("[Result] Cancelled: id=\(request.identifier)")
        }
      })
      .disposed(by: self.disposeBag)

    self.downloader
      .observe(by: self.items.map { $0.request.identifier })
      .throttle(.milliseconds(500), latest: true, scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] tasks in
        guard let self = self else { return }

        let newItems: [Item] = self.items.map { item in
          var copy = item
          copy.state = tasks[item.request.identifier]?.state ?? .undefined
          return copy
        }

        let indexPaths = zip(self.items, newItems)
          .enumerated()
          .compactMap { (index, tuple) -> IndexPath? in
            let (old, new) = tuple
            if old.state != new.state {
              return IndexPath(row: index, section: 0)
            }
            return nil
        }

        self.items = newItems
        self.tableView.reloadRows(at: indexPaths, with: .none)
      })
      .disposed(by: self.disposeBag)
  }

  @objc func cancelAll() {
    self.downloader
      .cancelAll()
      .subscribe()
      .disposed(by: self.disposeBag)
  }

  @objc func removeAll() {
    self.downloader
      .removeAll()
      .subscribe()
      .disposed(by: self.disposeBag)
  }

  @objc func remove() {
    let alert = UIAlertController(
      title: "Remove",
      message: "Enter identifier need remove",
      preferredStyle: .alert
    )
    alert.addTextField()
    alert.addAction(.init(title: "Cancel", style: .destructive))
    alert.addAction(.init(title: "OK", style: .default, handler: { [weak alert, weak self] _ in
      if let id = alert?.textFields?.first?.text, let self = self {
        self.downloader
          .remove(identifier: id)
          .subscribe()
          .disposed(by: self.disposeBag)
      }
    }))
    self.present(alert, animated: true)
  }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let buttonCancelAll = UIButton(type: .system)
    buttonCancelAll.setTitle("Cancel all", for: .normal)
    buttonCancelAll.addTarget(self, action: #selector(cancelAll), for: .touchUpInside)

    let buttonRemove = UIButton(type: .system)
    buttonRemove.setTitle("Remove", for: .normal)
    buttonRemove.addTarget(self, action: #selector(remove), for: .touchUpInside)

    let buttonRemoveAll = UIButton(type: .system)
    buttonRemoveAll.setTitle("Remove all", for: .normal)
    buttonRemoveAll.addTarget(self, action: #selector(removeAll), for: .touchUpInside)

    let header = UIStackView()
    header.axis = .horizontal
    header.distribution = .fillEqually
    header.alignment = .center
    header.spacing = 16
    header.addArrangedSubview(buttonCancelAll)
    header.addArrangedSubview(buttonRemove)
    header.addArrangedSubview(buttonRemoveAll)
    header.frame = .init(x: 0, y: 0, width: self.view.frame.width, height: 48)
    header.backgroundColor = .white
    return header
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    48
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    items.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadCell", for: indexPath)
    let item = self.items[indexPath.row]

    cell.textLabel?.text = item.request.url.absoluteString
    cell.textLabel?.font = .systemFont(ofSize: 13)

    cell.detailTextLabel?.text = "\(item.state)"
    cell.detailTextLabel?.textColor = color(for: item.state)
    cell.detailTextLabel?.font = .systemFont(ofSize: 13)

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let item = self.items[indexPath.row]
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
      let url = item.request.savedDir.appendingPathComponent(item.request.fileName)
      if FileManager.default.fileExists(atPath: url.path) {
        print("[Completed] url=\(url)")
      } else {
        fatalError()
      }

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

func color(for state: PhDownloadState) -> UIColor {
  switch state {

  case .undefined:
    return .darkGray
  case .enqueued:
    return .orange
  case .downloading:
    return .init(red: 0x00 / 255.0, green: 0xC8 / 255.0, blue: 0x53 / 255.0, alpha: 1)
  case .completed:
    return .blue
  case .failed:
    return .red
  case .cancelled:
    return .systemPink
  }
}
