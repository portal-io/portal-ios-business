#
#  Be sure to run `pod spec lint PortalIosBusiness.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "PortalIosBusiness"
  s.version      = "0.0.1"
  s.summary      = "A short description of PortalIosBusiness."

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
                   DESC

  s.homepage     = "http://EXAMPLE/PortalIosBusiness"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See http://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  s.license      = "MIT (example)"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  s.author             = { "qbshen" => "shen.qingbo@whaley.cn" }
  # Or just: s.author    = "qbshen"
  # s.authors            = { "qbshen" => "shen.qingbo@whaley.cn" }
  # s.social_media_url   = "http://twitter.com/qbshen"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # s.platform     = :ios
  # s.platform     = :ios, "5.0"

  #  When using multiple platforms
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  s.source       = { :git => "http://EXAMPLE/PortalIosBusiness.git", :tag => "#{s.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  # s.source_files  = "Classes", "Classes/**/*.{h,m}"
  # s.exclude_files = "Classes/Exclude"

  # s.public_header_files = "Classes/**/*.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"
  s.subspec 'WVRDanmu' do |cur|
    cur.source_files = 'WVRDanmu/WVRDanmu/Classes/**/*.{h,m}'
    # s.vendored_frameworks = ['WVRDanmu/WVRDanmu/Classes/SocketIO/SocketIO.framework']

    cur.requires_arc = true
    # s.pod_target_xcconfig = { "OTHER_LDFLAGS" => "-ObjC -all_load" }

    cur.dependency 'PortalIosLibrary/WVRNet'
    cur.dependency 'PortalIosMidwareMidware/WVRPlayerUI'
    cur.dependency 'PortalIosMidware/WVRAPIService'
    cur.dependency 'PortalIosMidware/WVRMediator'
  end

  s.subspec 'WVRPay' do |cur|
    cur.prefix_header_contents = '#import "WVRPayPrefixHeader.h"'
    
    cur.source_files = 'WVRPay/WVRPay/Classes/**/*.{h,m}','WVRPay/WVRPay/Classes/*.{h,m}'

    cur.vendored_frameworks = ['WVRPay/WVRPay/Classes/Plugin/AliPayPlugin/AlipaySDK.framework']
    cur.vendored_libraries = ['WVRPay/WVRPay/Classes/Plugin/IpaynowPlugin/iPhone+Simulator/libIPaynowPlugin.a', 'WVRPay/WVRPay/Classes/Plugin/WechatPlugin/WXWeChatSDK.a']

    cur.requires_arc = true

    cur.dependency 'PortalIosMidware/WVRMediator'
    cur.dependency 'PortalIosMidware/WVRUIFrame'
    cur.dependency 'PortalIosLibrary/WVRImage'
    cur.dependency 'PortalIosLibrary/WVRCache'
    cur.dependency 'PortalIosLibrary/WVRAppContext'
    cur.dependency 'PortalIosLibrary/WVRNet'
    cur.dependency 'PortalIosMidwareMidware/WVRWidget'
    cur.dependency 'PortalIosMidware/WVRInteractor'
    cur.dependency 'PortalIosLibrary/WVRNetModel'
    cur.dependency 'PortalIosMidware/WVRAPIService'
    cur.dependency 'PortalIosLibraryMidware/WVRBI'

    cur.framework = 'CoreMotion'
    cur.libraries = 'c++'
  end

  s.subspec 'WVRSetting' do |cur|
    cur.source_files = ['WVRSetting/WVRSetting/Core/*.{h,m}', 'WVRSetting/WVRSetting/Core/**/*.{h,m}']
    cur.resources = ['WVRSetting/WVRSetting/Core/Resource/**/*']
    cur.requires_arc = true

    cur.prefix_header_contents = '#import "WVRSettingHeader.h"'
    
    cur.framework = 'UIKit', 'Foundation'
    
    cur.dependency 'ReactiveObjC'
    

    cur.dependency 'PortalIosMidware/WVRMediator'
    cur.dependency 'PortalIosMidware/WVRUIFrame'
    cur.dependency 'PortalIosLibrary/WVRImage'
    cur.dependency 'PortalIosLibrary/WVRCache'
    cur.dependency 'PortalIosLibrary/WVRAppContext'
    cur.dependency 'PortalIosLibrary/WVRNet'
    cur.dependency 'PortalIosMidwareMidware/WVRWidget'
    cur.dependency 'PortalIosMidware/WVRInteractor'
    cur.dependency 'PortalIosLibrary/WVRNetModel'
    cur.dependency 'PortalIosMidware/WVRAPIService'
    cur.dependency 'PortalIosLibraryMidware/WVRBI'
    cur.dependency 'PortalIosLibrary/WVRShare'
    cur.dependency 'PortalIosLibrary/WVRUtil'
    

  end

  s.subspec 'WVRAccount' do |cur|
    cur.source_files = 'WVRAccount/WVRAccount/Core/**/*.{h,m}'
    cur.prefix_header_contents = '#import "WVRAccountHeader.h"'
    cur.requires_arc = true
    cur.framework = 'UIKit', 'Foundation'

    cur.dependency 'AFNetworking'
    cur.dependency 'YYModel'
    cur.dependency 'ReactiveObjC'
    cur.dependency 'FMDB'
    

    cur.dependency 'PortalIosMidware/WVRMediator'
    cur.dependency 'PortalIosMidware/WVRUIFrame'
    cur.dependency 'PortalIosLibrary/WVRImage'
    cur.dependency 'PortalIosLibrary/WVRCache'
    cur.dependency 'PortalIosLibrary/WVRAppContext'
    cur.dependency 'PortalIosLibrary/WVRNet'
    cur.dependency 'PortalIosMidwareMidware/WVRWidget'
    cur.dependency 'PortalIosMidware/WVRInteractor'
    cur.dependency 'PortalIosLibrary/WVRNetModel'
    cur.dependency 'PortalIosMidware/WVRAPIService'
    cur.dependency 'PortalIosLibraryMidware/WVRBI'
    cur.dependency 'PortalIosLibrary/WVRShare'
    cur.dependency 'PortalIosLibrary/WVRUtil'
    

  end

  # s.dependency 'WVRPlayer'  WVRPlayer framwork 大于100MB，无法上传到git
  # s.subspec 'WVRProgram' do |cur|
  #   cur.source_files = ['WVRProgram/WVRProgram/Classes/*.{h,m}', 'WVRProgram/WVRProgram/Classes/**/*.{h,m}']
  #   cur.resources = ['WVRProgram/WVRProgram/Classes/**/*.{xib}']
  #   cur.framework = 'UIKit', 'Foundation'

  #   cur.prefix_header_contents = '#import "WVRProgramHeader.h"'
    
  #   cur.requires_arc = true

  #   cur.dependency 'LKDBHelper'
  #   cur.dependency 'HMSegmentedControl'
  #   cur.dependency 'CocoaHTTPServer'
  #   cur.dependency 'RZDataBinding'
  #   cur.dependency 'ReactiveObjC'

  #   cur.dependency 'PortalIosMidware/WVRMediator'
  #   cur.dependency 'PortalIosMidware/WVRUIFrame'
  #   cur.dependency 'PortalIosLibrary/WVRImage'
  #   cur.dependency 'PortalIosLibrary/WVRCache'
  #   cur.dependency 'PortalIosLibrary/WVRAppContext'
  #   cur.dependency 'PortalIosLibrary/WVRNet'
  #   cur.dependency 'PortalIosMidwareMidware/WVRWidget'
  #   cur.dependency 'PortalIosMidware/WVRInteractor'
  #   cur.dependency 'PortalIosLibrary/WVRNetModel'
  #   cur.dependency 'PortalIosMidware/WVRAPIService'
  #   cur.dependency 'PortalIosLibraryMidware/WVRBI'
  #   cur.dependency 'PortalIosLibrary/WVRShare'
  #   cur.dependency 'PortalIosLibrary/WVRUtil'
  #   cur.dependency 'PortalIosLibrary/WVRParser'
  #   cur.dependency 'PortalIosMidwareMidware/WVRPlayerUI'
  #   cur.dependency 'PortalIosMidwareMidware/WVRHybrid'

  # end
  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
