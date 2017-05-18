target 'Parser' do
  use_frameworks!
  inhibit_all_warnings!
  platform :osx, '10.10'
  pod 'FootlessParser'
  target 'ParserTests' do
    inherit! :search_paths
    pod 'Nimble'
    pod 'Quick'
    pod 'SwiftCheck'
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
      config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
      config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
    end
  end
end
