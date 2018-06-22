//
//  WVRHttpArrangeElements.m
//  WhaleyVR
//
//  Created by Xie Xiaojian on 2016/10/28.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRHttpTVRecommendPage.h"

NSString * const kHttpParams_TVHaveTV = @"v";

static NSString *kActionUrl = @"newVR-service/appservice/recommendPage/findElementsByCode/%@/%@/%@";

@implementation WVRHttpTVRecommendPage

/* protocol WVRRequestProtocol method */
- (void)onDataSuccess:(id)dataObject
{
    NSMutableDictionary *result = (NSMutableDictionary*)self.originResponse;
    WVRHttpTVRecommendPageModel *resSuccess = [WVRHttpTVRecommendPageModel yy_modelWithDictionary:result];
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
    return [[[NSString stringWithFormat:kActionUrl, _code, kAPI_PLATFORM, [WVRUserModel kAPI_VERSION]] stringByAppendingString:self.pageNum] stringByAppendingString:self.pageSize];
}

@end


@implementation WVRHttpTVRecommendPageModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{ @"data" : [WVRHttpTVRecommendElementsModel class], };
}

@end
