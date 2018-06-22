//
//  WVRHttpGetLiveProgramList.m
//  VRManager
//
//  Created by Wang Tiger on 16/6/20.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRHttpProgramDetails.h"

NSString * const kHttpParams_programDetails_code = @"codes";

static NSString *kActionUrl = @"newVR-service/appservice/program/findByCodes";

@implementation WVRHttpProgramDetails

/* protocol WVRRequestProtocol method */
- (void)onDataSuccess:(id)dataObject
{
    NSMutableDictionary *result = (NSMutableDictionary*)self.originResponse;
    WVRHttpProgramDetailsModel *resSuccess = [WVRHttpProgramDetailsModel yy_modelWithDictionary:result];
    self.successedBlock(resSuccess);
}

/* protocol WVRRequestProtocol method */
- (void)onDataFailed:(id)dataObject
{
    NSLog(@"%@ request failed",[self class]);
    self.failedBlock(dataObject);
}

/* WVRBaseRequest method*/
- (NSString *)getActionUrl
{
    return kActionUrl;
}


@end


@implementation WVRHttpProgramDetailsModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{ @"data" : [WVRHttpProgramModel class], };
}

@end
