platform :ios, '11.0'

target 'PhDownloader' do
  pod 'Alamofire', '~> 5.6'
  pod 'RxAlamofire', '~> 6.1'
  
  pod 'RxSwift', '~> 6.5'
  pod 'RxRelay', '~> 6.5'
  
  pod 'Realm', '~> 10.32', :modular_headers => true
  pod 'RealmSwift', '~> 10.32'
  pod 'RxRealm', '~> 5.0'

  target 'PhDownloaderTests' do
  end

end

post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
            end
        end
        project.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
        end
    end
end
