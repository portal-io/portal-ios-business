Pod::Spec.new do |s|
    s.name         = 'WVRDanmu'
    s.version      = '0.1.0'
    s.summary      = 'WVRDanmu files'
    s.homepage     = 'https://git.moretv.cn/whaley-vr-ios-biz/WVRDanmu'
    s.license      = 'MIT'
    s.authors      = {'whaleyvr' => 'vr-iosdev@whaley.cn'}
    s.platform     = :ios, '9.0'
    s.source       = {:git => 'https://git.moretv.cn/whaley-vr-ios-biz/WVRDanmu.git', :tag => s.version}
    
    s.source_files = 'WVRDanmu/Classes/**/*.{h,m}'
    s.vendored_frameworks = ['WVRDanmu/Classes/SocketIO/SocketIO.framework']

    s.requires_arc = true
    # s.pod_target_xcconfig = { "OTHER_LDFLAGS" => "-ObjC -all_load" }

    s.dependency 'WVRNet'
    s.dependency 'WVRPlayerUI'
    s.dependency 'WVRAPIService'
    s.dependency 'WVRMediator'
    # .swift-version = "2.3"
    # s.xcconfig = "-l"
    # s.framework = 'SocketIO'
    # s.xcconfig = {
    #     "OTHER_LDFLAGS": "-lz"
    # }
end
