Pod::Spec.new do |s|
    s.name         = 'WVRProgram'
    s.version      = '0.1.8'
    s.summary      = 'WVRProgram files'
    s.homepage     = 'http://git.moretv.cn/whaley-vr-ios-biz/WVRProgram'
    s.license      = 'MIT'
    s.authors      = {'whaleyvr' => 'vr-iosdev@whaley.cn'}
    s.platform     = :ios, '9.0'
    s.source       = {:git => 'http://git.moretv.cn/whaley-vr-ios-biz/WVRProgram.git', :tag => s.version}
    
    s.source_files = ['WVRProgram/Classes/*.{h,m}', 'WVRProgram/Classes/**/*.{h,m}']
    s.resources = ['WVRProgram/Classes/**/*.{xib}']
    s.framework = 'UIKit', 'Foundation'

    s.prefix_header_contents = '#import "WVRProgramHeader.h"'
    
    s.requires_arc = true

    s.dependency 'LKDBHelper'
    s.dependency 'HMSegmentedControl'
    s.dependency 'CocoaHTTPServer'
    s.dependency 'RZDataBinding'
    s.dependency 'ReactiveObjC'
    
    s.dependency 'WVRMediator'
    s.dependency 'WVRUIFrame'
    s.dependency 'WVRImage'
    s.dependency 'WVRCache'
    s.dependency 'WVRNet'
    s.dependency 'WVRNetModel'
    s.dependency 'WVRAppContext'
    s.dependency 'WVRBI'
    s.dependency 'WVRPlayer'
    s.dependency 'WVRParser'
    s.dependency 'WVRShare'
    s.dependency 'WVRWidget'
    s.dependency 'WVRUtil'
    s.dependency 'WVRPlayerUI'
    s.dependency 'WVRAPIService'
    s.dependency 'WVRHybrid'
    s.dependency 'WVRInteractor'

end
