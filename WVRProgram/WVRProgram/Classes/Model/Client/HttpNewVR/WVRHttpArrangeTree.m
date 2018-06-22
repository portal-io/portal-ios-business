//
//  WVRHttpAppArrangeDetail.m
//  WhaleyVR
//
//  Created by Xie Xiaojian on 2016/10/28.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WVRHttpArrangeTree.h"

static NSString *kActionUrl = @"newVR-service/appservice/arrangeTree/findAll/%@/%@/%@";

@implementation WVRHttpArrangeTree

/* protocol WVRRequestProtocol method */
- (void)onDataSuccess:(id)dataObject
{
    NSMutableDictionary *result = (NSMutableDictionary*)self.originResponse;
    WVRHttpArrangeTreeDetailModel *resSuccess = [WVRHttpArrangeTreeDetailModel yy_modelWithDictionary:result];
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
    return [NSString stringWithFormat:kActionUrl, _arrangeCode, kAPI_PLATFORM, [WVRUserModel kAPI_VERSION]];
}


@end


@implementation WVRHttpArrangeTreeDetailModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{ @"data" : [WVRHttpArrangeTreeModel class], };
}

@end
