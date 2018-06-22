Pod::Spec.new do |s|
    s.name         = 'WVRSetting'
    s.version      = '0.0.5'
    s.summary      = 'WVRSetting files'
    s.homepage     = 'http://git.moretv.cn/whaley-vr-ios-biz/WVRSetting'
    s.license      = 'MIT'
    s.authors      = {'whaleyvr' => 'vr-iosdev@whaley.cn'}
    s.platform     = :ios, '9.0'
    s.source       = {:git => 'http://git.moretv.cn/whaley-vr-ios-biz/WVRSetting.git', :tag => s.version}
    
    s.source_files = ['WVRSetting/Core/*.{h,m}', 'WVRSetting/Core/**/*.{h,m}']
    s.resources = ['WVRSetting/Core/Resource/**/*']
    s.requires_arc = true

    s.prefix_header_contents = '#import "WVRSettingHeader.h"'
    
    s.framework = 'UIKit', 'Foundation'
    
    s.dependency 'ReactiveObjC'
    
    s.dependency 'WVRMediator'
    s.dependency 'WVRUIFrame'
    s.dependency 'WVRImage'
    s.dependency 'WVRCache'
    s.dependency 'WVRNet'
    s.dependency 'WVRNetModel'
    s.dependency 'WVRAppContext'
    s.dependency 'WVRBI'
    s.dependency 'WVRShare'
    s.dependency 'WVRWidget'
    s.dependency 'WVRUtil'
    s.dependency 'WVRAPIService'
    s.dependency 'WVRInteractor'

end
