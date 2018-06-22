Pod::Spec.new do |s|
    s.name         = 'WVRAccount'
    s.version      = '0.0.8'
    s.summary      = 'WVRAccount files'
    s.homepage     = 'http://git.moretv.cn/whaley-vr-ios-biz/WVRAccount'
    s.license      = 'MIT'
    s.authors      = {'whaleyvr' => 'vr-iosdev@whaley.cn'}
    s.platform     = :ios, '9.0'
    s.source       = {:git => 'http://git.moretv.cn/whaley-vr-ios-biz/WVRAccount.git', :tag => s.version}
    
    s.source_files = 'WVRAccount/Core/**/*.{h,m}'
    s.prefix_header_contents = '#import "WVRAccountHeader.h"'
    s.requires_arc = true
    s.framework = 'UIKit', 'Foundation'

    s.dependency 'AFNetworking'
    s.dependency 'YYModel'
    s.dependency 'ReactiveObjC'
    s.dependency 'FMDB'
    s.dependency 'WVRAppContext'
    s.dependency 'WVRMediator'
    s.dependency 'WVRUIFrame'
    s.dependency 'WVRImage'
    s.dependency 'WVRCache'
    s.dependency 'WVRNet'
    s.dependency 'WVRNetModel'
    s.dependency 'WVRBI'
    s.dependency 'WVRShare'
    s.dependency 'WVRWidget'
    s.dependency 'WVRUtil'
    s.dependency 'WVRAPIService'
    s.dependency 'WVRInteractor'
    
    
    
end