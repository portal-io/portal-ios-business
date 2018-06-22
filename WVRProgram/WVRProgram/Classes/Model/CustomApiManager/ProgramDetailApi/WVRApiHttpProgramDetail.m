//
//  WVRApiHttpProgramDetail.m
//  WhaleyVR
//
//  Created by Wang Tiger on 17/2/27.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRApiHttpProgramDetail.h"
#import "WVRNetworkingCMSService.h"

NSString * const kWVRAPIParamsProgramDetailCode = @"code";

@interface WVRApiHttpProgramDetail () <WVRAPIManagerValidator, WVRAPIManagerCallBackDelegate>

@end

@implementation WVRApiHttpProgramDetail

#pragma mark - life cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.validator = self;
        self.delegate = self;
    }
    return self;
}

#pragma mark - WVRAPIManager
- (NSString *)methodName
{
//    return [NSString stringWithFormat:@"newVR-service/appservice/program/findByCode/%@", [self.urlParams valueForKey:@"code"]];
    return @"newVR-service/appservice/program/findByCode";
}

- (NSString *)serviceType
{
    return NSStringFromClass([WVRNetworkingCMSService class]);
}

- (WVRAPIManagerRequestType)requestType
{
    return WVRAPIManagerRequestTypeGet;
}

- (NSDictionary *)reformParams:(NSDictionary *)params {
    NSMutableDictionary *resultParams = [[NSMutableDictionary alloc] init];
    resultParams[kWVRAPIParamsProgramDetailCode] = @"67552c34eeb64a688b4da611896fbdc1";
    return resultParams;
}

#pragma mark - WVRAPIManagerValidator
- (BOOL)isCorrectWithParamsData:(NSDictionary *)data
{
    if ([data[kWVRAPIParamsProgramDetailCode] isEqualToString:@"test"]) {
        return NO;
    }
    return YES;
}

- (BOOL)isCorrectWithCallBackData:(NSDictionary *)data
{
    if (![data[@"code"] isEqualToString:@"200"]) {
        return NO;
    }
    return YES;
}

#pragma mark - WVRAPIManagerCallBackDelegate
- (void)managerCallAPIDidSuccess:(WVRNetworkingResponse *)response {
    self.successedBlock(response);
}

- (void)managerCallAPIDidFailed:(WVRNetworkingResponse *)response {
    self.failedBlock(response);
}
@end
