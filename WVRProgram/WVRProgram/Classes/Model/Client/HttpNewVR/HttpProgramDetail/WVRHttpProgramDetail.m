//
//  WVRHttpGetLiveProgramList.m
//  VRManager
//
//  Created by Wang Tiger on 16/6/20.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRHttpProgramDetail.h"

NSString * const kHttpParams_programDetail_code = @"code";

static NSString *kActionUrl = @"newVR-service/appservice/program/findByCode";

@implementation WVRHttpProgramDetail

/* protocol WVRRequestProtocol method */
- (void)onDataSuccess:(id)dataObject
{
    NSMutableDictionary *result = (NSMutableDictionary *)self.originResponse;
    WVRHttpProgramDetailModel *resSuccess = [WVRHttpProgramDetailModel yy_modelWithDictionary:result];
    self.successedBlock(resSuccess);
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


@implementation WVRHttpProgramDetailModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{ @"data" : [WVRHttpProgramModel class], };
}

@end
