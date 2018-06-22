//
//  WVRHttpArrangeElements.m
//  WhaleyVR
//
//  Created by Xie Xiaojian on 2016/10/28.
//  Copyright © 2016年 Snailvr. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "WVRHttpArrangeElements.h"

static NSString *kActionUrl = @"newVR-service/appservice/arrangeTree/elements";

@implementation WVRHttpArrangeElements

/* protocol WVRRequestProtocol method */
- (void)onDataSuccess:(id)dataObject
{
    NSMutableDictionary *result = (NSMutableDictionary*)self.originResponse;
    WVRHttpArrangePageModel *resSuccess = [WVRHttpArrangePageModel yy_modelWithDictionary:result];
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
    return [NSString stringWithFormat:kActionUrl, _treeNodeCode, _pageNum, _pageSize];
}


@end


@implementation WVRHttpArrangePageModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{ @"data" : [WVRHttpArrangeElementsPageModel class], };
}

@end
