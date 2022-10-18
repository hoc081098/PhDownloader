# PhDownloader (Petrus Hoc's Downloader)
Simple, reactive and functional downloader for iOS Swift with the power of `RxSwift`, `RxAlamofire`

<!-- [![CI Status](https://img.shields.io/travis/hoc081098/PhDownloader.svg?style=flat)](https://travis-ci.org/hoc081098/PhDownloader) -->
[![Version](https://img.shields.io/cocoapods/v/PhDownloader.svg?style=flat)](https://cocoapods.org/pods/PhDownloader)
[![License](https://img.shields.io/cocoapods/l/PhDownloader.svg?style=flat)](https://cocoapods.org/pods/PhDownloader)
[![Platform](https://img.shields.io/cocoapods/p/PhDownloader.svg?style=flat)](https://cocoapods.org/pods/PhDownloader)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

PhDownloader is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PhDownloader'
```

## Author

Petrus Nguyễn Thái Học, hoc081098@gmail.com

## Usagement

### Create downloader
```swift
let downloader: PhDownloader = PhDownloaderFactory.makeDownloader(
    with: .init(
        maxConcurrent: 2,
        throttleProgress: .milliseconds(500)
    )
)
```

### Obseve download result (for showing snackbar, toast, alert, ...)
```swift
downloader
    .downloadResult$
    .subscribe(onNext: { result in
        switch result {
        case .success(let request):
          ...
        case .failure(let request, let error):
          ...
        case .cancelled(let request):
          ...
        }
    })
    .disposed(by: disposeBag)
```

### Obseve download state (for updating UI)
```swift
downloader
    .observe(by: ["id1", "id2", "id3"])
    .subscribe(onNext: { tasks in
        ...
    })
    .disposed(by: disposeBag)

downloader
    .observe(by: "Request id")
    .subscribe(onNext: { task in 
        ...
    })
    .disposed(by: disposeBag)
```

### Enqueue, cancel, cancelAll, remove:
```swift

let id = "Request id"

downloader
    .enqueue(
        .init(
            identifier: id,
            url: URL(string: "https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_1920_18MG.mp4")!,
            fileName: "test_file_\(id).mp4",
            savedDir: FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent("downloads", isDirectory: true)
        )
    )
    .subscribe()
    .disposed(by: disposeBag)

downloader
    .cancel(by: id)
    .subscribe()
    .disposed(by: disposeBag)

downloader
    .cancelAll()
    .subscribe()
    .disposed(by: disposeBag)
    
downloader
    .remove(identifier: id)
    .subscribe()
    .disposed(by: disposeBag)
```

## License

PhDownloader is available under the MIT license. See the LICENSE file for more info.

