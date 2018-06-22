Pod::Spec.new do |s|
    s.name         = 'WVRPay'
    s.version      = '0.0.6'
    s.summary      = 'WVRPay files'
    s.homepage     = 'http://git.moretv.cn/whaley-vr-ios-biz/WVRPay'
    s.license      = 'MIT'
    s.authors      = {'whaleyvr' => 'vr-iosdev@whaley.cn'}
    s.platform     = :ios, '9.0'
    s.source       = {:git => 'http://git.moretv.cn/whaley-vr-ios-biz/WVRPay.git', :tag => s.version}
    
    s.prefix_header_contents = '#import "WVRPayPrefixHeader.h"'
    
    s.source_files = 'WVRPay/Classes/**/*.{h,m}','WVRPay/Classes/*.{h,m}'

    s.vendored_frameworks = ['WVRPay/Classes/Plugin/AliPayPlugin/AlipaySDK.framework']
    s.vendored_libraries = ['WVRPay/Classes/Plugin/IpaynowPlugin/iPhone+Simulator/libIPaynowPlugin.a', 'WVRPay/Classes/Plugin/WechatPlugin/WXWeChatSDK.a']

    s.requires_arc = true

    s.dependency 'WVRMediator'
    s.dependency 'WVRUIFrame'
    s.dependency 'WVRImage'
    s.dependency 'WVRCache'
    s.dependency 'WVRAppContext'
    s.dependency 'WVRNet'
    s.dependency 'WVRWidget'
    s.dependency 'WVRInteractor'
    s.dependency 'WVRNetModel'
    s.dependency 'WVRAPIService'
    s.dependency 'WVRBI'

    s.framework = 'CoreMotion'
    s.libraries = 'c++'

end
