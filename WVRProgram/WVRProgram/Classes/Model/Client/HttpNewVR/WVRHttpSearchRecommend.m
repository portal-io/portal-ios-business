//
//  WVRHttpSearchRecommend.m
//  WhaleyVR
//
//  Created by Xie Xiaojian on 2016/11/1.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRHttpSearchRecommend.h"

NSString * const kHttpParams_searchRecommend_keyWord = @"keyWord";
NSString * const kHttpParams_searchRecommend_type = @"type";
NSString * const kHttpParams_searchRecommend_code = @"code";
static NSString *kActionUrl = @"newVR-service/appservice/search/recommend";

@implementation WVRHttpSearchRecommend

/* protocol WVRRequestProtocol method */
- (void)onDataSuccess:(id)dataObject
{
    NSMutableDictionary *result = (NSMutableDictionary*)self.originResponse;
    WVRHttpSearchRecommendMainModel *resSuccess = [WVRHttpSearchRecommendMainModel yy_modelWithDictionary:result];
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
    return kActionUrl;
}

@end


@implementation WVRHttpSearchRecommendMainModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{ @"data" : [WVRHttpSearchRecommendModel class], };
}

@end
