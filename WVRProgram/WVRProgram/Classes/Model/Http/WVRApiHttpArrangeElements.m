//
//  WVRApiHttpArrangeElements.m
//  WVRProgram
//
//  Created by qbshen on 2017/9/16.
//  Copyright © 2017年 snailvr. All rights reserved.
//

#import "WVRApiHttpArrangeElements.h"
#import "WVRNetworkingCMSService.h"
#import "WVRAPIBaseManager+ReactiveExtension.h"

NSString * const kHttpParams_ArrangeElements_code = @"code";

@implementation WVRApiHttpArrangeElements
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - WVRAPIManager

#pragma mark - WVRAPIManager
- (NSString *)methodName
{
    NSDictionary * params = [self.dataSource paramsForAPI:self];
    NSString * url = [NSString stringWithFormat:@"newVR-service/appservice/arrangeTree/elements/%@/%@/%@",params[kHttpParams_ArrangeElements_code],@"1",@"10"];
    return url;
}


- (NSDictionary *)reformParams:(NSDictionary *)params {
    NSDictionary * dic = @{@"v" : @"1"};
    return dic;
}

- (NSString *)serviceType {
    return NSStringFromClass([WVRNetworkingCMSService class]);
}

- (WVRAPIManagerRequestType)requestType {
    return WVRAPIManagerRequestTypeGet;
}

#pragma mark - WVRAPIManagerCallBackDelegate

- (void)managerCallAPIDidSuccess:(WVRNetworkingResponse *)response {
    self.successedBlock(response);
}

- (void)managerCallAPIDidFailed:(WVRNetworkingResponse *)response {
    self.failedBlock(response);
}

@end