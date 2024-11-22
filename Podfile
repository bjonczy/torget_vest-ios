require_relative "scripts/update_loco"

inhibit_all_warnings!
platform :ios, '13.0'
use_frameworks!
install! 'cocoapods', :disable_input_output_paths => true

project 'TorgetVest', 'TorgetVestDebug' => :debug, 'TorgetVestDebugSimulator' => :debug, 'TorgetVestRelease' => :release
basePath = 'components'

target 'TorgetVest' do

  pod 'MMDrawerController',         :git => "git@bitbucket.org:boost-development/mmdrawercontroller.git"
  pod 'CarbonKit',                  :git => "git@bitbucket.org:boost-development/ios_carbonkit.git"
  pod 'IQKeyboardManager',          '6.5.10'
  pod 'IGListKit',                  '4.0.0'
  pod 'SwiftyBeaver',               '1.9.5'
  pod 'iOSKit',                     :path => basePath + '/ioskit'
  pod 'vcs',                        :path => basePath + '/vcs'
  pod 'Offers',                     :path => basePath + '/offers'
  pod 'iAnalytics',                 :path => basePath + '/ianalytics'
  pod 'Analytics',                  :path => basePath + '/analytics'
  pod 'Identity',                   :path => basePath + '/identity'
  pod 'WelcomePages',               :path => basePath + '/welcomepages'
  pod 'Web',                        :path => basePath + '/web'
  pod 'Navigation',                 :path => basePath + '/navigation'
  pod 'Pushr',                      :path => basePath + '/pushr'
  pod 'Articles',                   :path => basePath + '/articles'
  pod 'Shops',                      :path => basePath + '/shops'
  pod 'Parking',                    :path => basePath + '/parking'
  pod 'OpeningHours',               :path => basePath + '/openinghours'
  pod 'Translations',               :path => basePath + '/translations'
  pod 'NotificationCenter',         :path => basePath + '/notificationcenter'
  pod 'Games',                      :path => basePath + '/games'
  pod 'Cars',                       :path => basePath + '/cars'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '5.5'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      if config.name.end_with?("Debug")
        config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
      else
        config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
      end
      config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['$(inherited)', '-D FORCE_PRODUCTION_CREDENTIALS']
      if config.name.end_with?("Simulator")
        config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
      end
    end
  end
  
  LocoUpdater.new('TorgetVest').update
end
