## 0.7.0 - Nov 3, 2022

- Update example, migrated to SwiftUI.
- Update dependencies
    - `'Alamofire', '~> 5.6'`
    - `'RxAlamofire', '~> 6.1'`
    - `'RxSwift', '~> 6.5'`
    - `'RxRelay', '~> 6.5'`
    - `'Realm', '~> 10.32'`
    - `'RealmSwift', '~> 10.32'`
    - `'RxRealm', '~> 5.0'`

- iOS deployment target to `11.0`.

- `PhDownloadRequest`: merged `savedDir` with `fileName` to `destinationURL`.
- `PhDownloadTask`: embedded `PhDownloadRequest`'s fields.
- `PhDownloader`: rename and change signatures
    - `remove(identifier:deleteFile:)` to `remove(by:and:)`.
    - `remove(identifier:)` to `removeAndDeleteFile(by:)`.
    - `removeAll()` to `removeAllAndDeleteFiles()`.

- Internal refactoring.

## 0.6.0 - Jul 22, 2020

*   Fix: wrong `failed` state.
*   Add: `PhDownloadResult.request` and `PhDownloadResult.error` getters.
*   Add: `PhDownloader.removeAll` methods
*   Breaking: `PhDownloader.remove` method now accepts a closure type `@escaping (PhDownloadTask) -> Bool` instead of `Bool` as before.
*   Update: more docs.

## 0.5.0 - Jul 18, 2020

*   Update README.md.
*   Update dependencies version.

## 0.4.0 - Jul 18, 2020

*   Add example.
*   Update dependencies version.

## 0.3.0 - Jul 17, 2020

*   Making PhDownloadTask's property becomes public.

## 0.2.0 - Jul 17, 2020

*   Fix home page url.
*   Update README.md.

## 0.1.0 - Jul 17, 2020

*   Initial publish.