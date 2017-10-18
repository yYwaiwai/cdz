# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'cdzer' do
use_frameworks!
# Uncomment the next line if you're using Swift or would like to use dynamic frameworks
# Pods for cdzer

# SQLite Framework and other Plugin
pod 'FMDB'
# pod 'FMDB/FTS'   # FMDB with FTS
# pod 'FMDB/standalone'   # FMDB with latest SQLite amalgamation source
# pod 'FMDB/standalone/FTS'   # FMDB with latest SQLite amalgamation source and FTS
# pod 'FMDB/SQLCipher'   # FMDB with SQLCipher

# HTTPRequest Framework & extension
#pod 'AFNetworking-RACExtensions', '~> 0.1.6'
pod 'AFNetworking', '~> 3.0'

#ReactiveCocoa
#pod 'ReactiveCocoa'
pod 'ReactiveObjC', '~> 2.1.0'

#CocoaAsyncSocket
#pod 'CocoaAsyncSocket'

#DZNWebViewController
pod 'DZNWebViewController'
#DZNEmptyDataSet
pod 'DZNEmptyDataSet'

#NJKWebViewProgress
pod 'NJKWebViewProgress'

#IQKeyboardManager
pod 'IQKeyboardManager'

#VideoPlayer
pod 'MobileVLCKit'

#BBBadgeBarButtonItem
pod 'BBBadgeBarButtonItem', '~> 1.2'

#M13BadgeView
pod 'M13BadgeView', '~> 1.0.4'

#TWMessageBarManager
pod 'TWMessageBarManager'

#BEMCheckBox
pod 'BEMCheckBox'
#XML
#pod 'KissXML', '~> 5.0.2'
pod 'XMLDictionary', '~> 1.4'
#百度地图SDK
pod 'BaiduMapKit', '~> 3.2.1'

#RegexKitLite
pod 'RegexKitLite', '~> 4.0'

# Graphics Framework
pod 'GPUImage', '~> 0.1.6'

# Animation Framework
pod 'pop', '~> 1.0'

# Chart Framework
pod 'PNChart', '~> 0.7.5'

# ZFPlayer
#pod 'ZFPlayer'
pod 'ZFPlayer', :path => './Frameworks/ZFPlayer/'
podspec :path => "./Frameworks/ZFPlayer/ZFPlayer.podspec"

# GPXParser
pod 'GPXParser', :path => 'Frameworks/gpx-parser-cocoa/'
podspec :path => "Frameworks/gpx-parser-cocoa/GPXParser.podspec"

# RefreshControl
pod 'ODRefreshControl', '~> 1.1.0'
pod 'MJRefresh'

# VENSeparatorView
#pod 'VENSeparatorView', '~> 1.0.0'

# JVFloatLabeledTextField
 pod 'JVFloatLabeledTextField'


# Encryption
#pod 'RNCryptor', '~> 2.2'
pod 'CocoaSecurity', '~> 1.2.4'
# CRChecker
#pod 'CRChecker'

# FXBlurView
pod 'FXBlurView', '~> 1.6.3'


# Network Image Handle 
#pod 'SDWebImage', '~>3.7.5’
#pod 'UIActivityIndicator-for-SDWebImage'

# File Manager
pod 'FCFileManager'

# PinYin4Objc
pod 'PinYin4Objc', '~> 1.1.1'

# HWWeakTimer
pod 'HWWeakTimer', '~> 1.0'

# TWTToast

#Indicator 提示框
# Toast
# pod 'Toast', '~> 3.0'

# MBProgressHUD
pod 'MBProgressHUD', '~> 0.8'
#pod 'MBProgressHUD', :path => '../Frameworks/MBProgressHUD_NBlur/'
#podspec :path => "../Frameworks/MBProgressHUD_NBlur/MBProgressHUD.podspec"

# SVProgressHUD;
pod 'SVProgressHUD'

pod 'SYPhotoBrowser'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end

end

  target 'cdzerTests' do
    inherit! :search_paths
    # Pods for testing
  end