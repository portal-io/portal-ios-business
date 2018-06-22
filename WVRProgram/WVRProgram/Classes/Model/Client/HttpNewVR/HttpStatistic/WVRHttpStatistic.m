//
//  WVRHttpGetLiveProgramList.m
//  VRManager
//
//  Created by Wang Tiger on 16/6/20.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRHttpStatistic.h"

NSString * const kHttpParams_statistic_id = @"id";
NSString * const kHttpParams_statistic_ip = @"ip";
NSString * const kHttpParams_statistic_model = @"model";
NSString * const kHttpParams_statistic_type = @"type";



static NSString *kActionUrl = @"newVR-app-service/app/statistic";

@implementation WVRHttpStatistic

/* protocol WVRRequestProtocol method */
- (void)onDataSuccess:(id)dataObject
{
    NSMutableDictionary *result = (NSMutableDictionary*)self.originResponse;
    
    WVRHttpStatisticModel *resSuccess = [WVRHttpStatisticModel yy_modelWithDictionary:result];
    self.successedBlock(resSuccess.msg);
}

/* protocol WVRRequestProtocol method */
- (void)onDataFailed:(id)dataObject
{
    NSLog(@"%@ request failed",[self class]);
    self.failedBlock(dataObject);
}

/* WVRBaseRequest method*/
- (NSString*)getActionUrl
{
    return kActionUrl;
}


@end
@implementation WVRHttpStatisticModel

@end
