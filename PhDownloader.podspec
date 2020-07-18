Pod::Spec.new do |spec|
  spec.name         = "PhDownloader"
  spec.version      = "0.5.0"
  spec.summary      = "Simple, reactive and functional downloader for iOS Swift with the power of RxSwift, RxAlamofire"
  spec.homepage     = "https://github.com/hoc081098/PhDownloader"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "Petrus Nguyễn Thái Học" => "hoc081098@gmail.com" }
  spec.social_media_url   = "https://twitter.com/hoc081098"

  spec.platform     = :ios
  spec.ios.deployment_target = "10.0"
  spec.swift_version = "5.1"
  spec.source       = { :git => "https://github.com/hoc081098/PhDownloader.git", :tag => "#{spec.version}" }

  spec.source_files  = "PhDownloader/**/*.{swift}"
  spec.requires_arc = true

  spec.framework = "Foundation"
  spec.dependency 'Alamofire', '~> 5.1'
  spec.dependency 'RxAlamofire', '~> 5.2'
  spec.dependency 'RxSwift', '~> 5.1'
  spec.dependency 'RxRelay', '~> 5.1'
  spec.dependency 'Realm', '~> 5.2', :modular_headers => true
  spec.dependency 'RealmSwift', '~> 5.2'
  spec.dependency 'RxRealm', '~> 3.1'
end
