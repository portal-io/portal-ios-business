//
//  WVRHttpApiPaymentList.m
//  WhaleyVR
//
//  Created by Wang Tiger on 2017/9/7.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRHttpApiPaymentList.h"
#import "WVRNetworkingCMSService.h"

NSString * const kHttpParam_PaymentList_Appversion = @"appVerion";
NSString * const kHttpParam_CreateOrder_Appsystem = @"appSystem";

@implementation WVRHttpApiPaymentList

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - WVRAPIManager

- (NSString *)methodName {
    return @"newVR-report-service/payMethod/payMethodList";
}

- (NSString *)serviceType {
    return NSStringFromClass([WVRNetworkingCMSService class]);
}

- (WVRAPIManagerRequestType)requestType
{
    return WVRAPIManagerRequestTypeGet;
}

@end
