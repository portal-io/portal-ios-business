//
//  WVRHttpArrangeElements.m
//  WhaleyVR
//
//  Created by Xie Xiaojian on 2016/10/28.
//  Copyright © 2016年 Snailvr. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "WVRHttpRecommendPagination.h"
NSString * const kAppTypeRecommendPage = @"ios";
NSString * const kBusiVersionRecommendPage = @"V.1.2";

static NSString *kActionUrl = @"newVR-service/appservice/recommendPage/findElementsByCode/%@/%@/%@/%@/%@/%@";

@implementation WVRHttpRecommendPagination

/* protocol WVRRequestProtocol method */
- (void)onDataSuccess:(id)dataObject
{
    NSMutableDictionary *result = (NSMutableDictionary *)self.originResponse;
    WVRHttpRecommendPaginationModel *resSuccess = [WVRHttpRecommendPaginationModel yy_modelWithDictionary:result];
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
    return [NSString stringWithFormat:kActionUrl, _code, _subCode, kAppTypeRecommendPage, kBusiVersionRecommendPage, _pageNum, _pageSize];
}


@end


@implementation WVRHttpRecommendPaginationModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{ @"data" : [WVRHttpRecommendPaginationContentModel class], };
}

@end


@implementation WVRHttpRecommendPaginationContentModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{ @"content": WVRHttpRecommendElement.class };
}

@end
