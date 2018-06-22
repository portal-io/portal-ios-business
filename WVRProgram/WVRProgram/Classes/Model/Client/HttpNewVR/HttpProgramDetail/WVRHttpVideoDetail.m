//
//  WVRHttpVideoDetail.m
//  WhaleyVR
//
//  Created by Bruce on 2017/9/4.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRHttpVideoDetail.h"
#import "WVRNetworkingCMSService.h"

static NSString *kActionUrl = @"newVR-service/appservice/program/findByCode";

@implementation WVRHttpVideoDetail


#pragma mark - WVRAPIManager

- (NSString *)methodName {
    
    return kActionUrl;
}

- (NSString *)serviceType {
    
    return NSStringFromClass([WVRNetworkingCMSService class]);
}

- (WVRAPIManagerRequestType)requestType {
    
    return WVRAPIManagerRequestTypeGet;
}

@end
