//
//  WVRHttpPayMethod.m
//  WhaleyVR
//
//  Created by Bruce on 2017/9/12.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRHttpPayMethod.h"
#import "WVRNetworkingStoreService.h"

static NSString *kActionUrl = @"newVR-report-service/payMethod/payMethodList";

@implementation WVRHttpPayMethod

#pragma mark - WVRAPIManager

- (NSString *)methodName {
    
    return kActionUrl;
}

- (NSString *)serviceType {
    
    return NSStringFromClass([WVRNetworkingStoreService class]);
}

- (WVRAPIManagerRequestType)requestType {
    
    return WVRAPIManagerRequestTypePost;
}

@end
