//
//  WVRHttpFindStat.m
//  WhaleyVR
//
//  Created by Xie Xiaojian on 2016/10/31.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRHttpFindStat.h"
NSString * const kHttpParams_findStat_srcCode = @"srcCode";
static NSString *kActionUrl = @"newVR-service/appservice/stat/findBySrcCode";

@implementation WVRHttpFindStat

/* protocol WVRRequestProtocol method */
- (void)onDataSuccess:(id)dataObject
{
    NSMutableDictionary *result = (NSMutableDictionary*)self.originResponse;
    WVRHttpFindStatParentModel *resSuccess = [WVRHttpFindStatParentModel yy_modelWithDictionary:result];
    self.successedBlock(resSuccess);
}

/* protocol WVRRequestProtocol method */
- (void)onDataFailed:(id)dataObject
{
    NSLog(@"%@ request failed", [self class]);
    self.failedBlock(dataObject);
}

/* WVRBaseRequest method*/
- (NSString*)getActionUrl
{
    return kActionUrl;
}


@end


@implementation WVRHttpFindStatParentModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{ @"data" : [WVRHttpFindStatModel class], };
}

@end
