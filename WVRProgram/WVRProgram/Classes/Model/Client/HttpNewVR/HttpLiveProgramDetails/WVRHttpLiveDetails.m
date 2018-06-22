//
//  WVRHttpLiveDetails.m
//  WhaleyVR
//
//  Created by Xie Xiaojian on 2016/10/27.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRHttpLiveDetails.h"

NSString * const kHttpParams_liveDetails_code = @"codes";

@implementation WVRHttpLiveDetails

/* protocol WVRRequestProtocol method */
- (void)onDataSuccess:(id)dataObject
{
    NSMutableDictionary *result = (NSMutableDictionary*)self.originResponse;
    WVRHttpLiveDetailsParentModel *resSuccess = [WVRHttpLiveDetailsParentModel yy_modelWithDictionary:result];
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
    return @"newVR-service/appservice/liveProgram/findByCodes";
}

@end


@implementation WVRHttpLiveDetailsParentModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{ @"data" : [WVRHttpLiveDetailModel class] };
}

@end
