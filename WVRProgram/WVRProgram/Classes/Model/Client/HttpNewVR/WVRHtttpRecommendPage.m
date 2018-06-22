//
//  WVRHttpArrangeElements.m
//  WhaleyVR
//
//  Created by Xie Xiaojian on 2016/10/28.
//  Copyright © 2016年 Snailvr. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "WVRHtttpRecommendPage.h"

NSString * const kHttpParams_RecommendPage_code_movie = @"moviefaxianye";
NSString * const kHttpParams_RecommendPage_code_vr = @"vrfaxianye";

NSString * const kHttpParams_HaveTV = @"v";

static NSString *kActionUrl = @"newVR-service/appservice/recommendPage/findPageByCode/%@/%@/%@";

@implementation WVRHtttpRecommendPage

/* protocol WVRRequestProtocol method */
- (void)onDataSuccess:(id)dataObject
{
    NSMutableDictionary *result = (NSMutableDictionary*)self.originResponse;
    WVRHttpRecommendPageDetailParentModel *resSuccess = [WVRHttpRecommendPageDetailParentModel yy_modelWithDictionary:result];
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
    return [NSString stringWithFormat:kActionUrl, _code, kAPI_PLATFORM, [WVRUserModel kAPI_VERSION]];
}

@end


@implementation WVRHttpRecommendPageDetailParentModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{ @"data" : [WVRHttpRecommendPageDetailModel class], };
}

@end
