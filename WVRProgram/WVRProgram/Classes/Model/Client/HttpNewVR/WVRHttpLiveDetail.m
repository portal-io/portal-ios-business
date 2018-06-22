//
//  WVRHttjpLiveDetail.m
//  WhaleyVR
//
//  Created by Xie Xiaojian on 2016/10/27.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRHttpLiveDetail.h"

NSString * const kHttpParams_liveDetail_code = @"code";

@implementation WVRHttpLiveDetail

/* protocol WVRRequestProtocol method */
- (void)onDataSuccess:(id)dataObject
{
    NSMutableDictionary *result = (NSMutableDictionary*)self.originResponse;
    WVRHttpLiveDetailParentModel *resSuccess = [WVRHttpLiveDetailParentModel yy_modelWithDictionary:result];
    self.successedBlock(resSuccess);
}

/* protocol WVRRequestProtocol method */
- (void)onDataFailed:(id)dataObject
{
    NSLog(@"%@ request failed", [self class]);
    self.failedBlock(dataObject);
}

/* WVRBaseRequest method*/
- (NSString *)getActionUrl
{
    return @"newVR-service/appservice/liveProgram/findByCode";
}


@end


@implementation WVRHttpLiveDetailParentModel

@end
