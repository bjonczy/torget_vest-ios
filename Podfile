require_relative 'Utilities/cocoapods/post_install'

inhibit_all_warnings!
platform :ios, '13.0'
use_frameworks!

project 'App', 'Debug' => :debug, 'Release' => :release, 'Staging' => :debug, 'DebugProduction' => :debug, 'DebugProductionSimulator' => :debug
basePath = 'components'

target 'Main' do
    pod 'MMDrawerController', 	:git => "git@bitbucket.org:boost-development/mmdrawercontroller.git"
    pod 'CarbonKit', 			:git => "git@bitbucket.org:boost-development/ios_carbonkit.git"

    pod 'iOSKit', 				        :path => basePath + '/ioskit'
    pod 'vcs', 					        :path => basePath + '/vcs'
    pod 'Offers', 				        :path => basePath + '/offers'
    pod 'iAnalytics', 			        :path => basePath + '/ianalytics'
    pod 'Analytics', 			        :path => basePath + '/analytics'
    pod 'Identity', 			        :path => basePath + '/identity'
    pod 'WelcomePages', 		        :path => basePath + '/welcomepages'
    pod 'Web', 					        :path => basePath + '/web'
    pod 'Navigation', 			        :path => basePath + '/navigation'
    pod 'Pushr', 				        :path => basePath + '/pushr'
    pod 'Articles', 			        :path => basePath + '/articles'
    pod 'Shops', 				        :path => basePath + '/shops'
    pod 'OpeningHours', 		        :path => basePath + '/openinghours'
    pod 'Translations',                 :path => basePath + '/translations'
    
    target 'AppTests' do
        inherit! :search_paths
    end
end

boost_post_install(post_install)
