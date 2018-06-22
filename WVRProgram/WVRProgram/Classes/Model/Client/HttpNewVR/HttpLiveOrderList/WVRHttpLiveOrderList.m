//
//  WVRHttpLiveOrder.m
//  WhaleyVR
//
//  Created by qbshen on 2016/12/9.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRHttpLiveOrderList.h"

NSString * const kHttpParams_liveOrderList_uid = @"uid";
NSString * const kHttpParams_liveOrderList_token = @"token";
NSString * const kHttpParams_liveOrderList_device_id = @"device_id";

static NSString *kActionUrl = @"newVR-service/appservice/liveorder/list";

@interface WVRHttpLiveOrderList ()

@property (nonatomic) NSString* actionStr;

@end


@implementation WVRHttpLiveOrderList
/* protocol WVRRequestProtocol method */
- (void)onDataSuccess:(id)dataObject
{
    NSMutableDictionary *result = (NSMutableDictionary*)self.originResponse;
    WVRHttpLiveOrderListModel *resSuccess = [WVRHttpLiveOrderListModel yy_modelWithDictionary:result];
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


@implementation WVRHttpLiveOrderListModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{ @"data": WVRHttpLiveDetailModel.class };
}

@end
