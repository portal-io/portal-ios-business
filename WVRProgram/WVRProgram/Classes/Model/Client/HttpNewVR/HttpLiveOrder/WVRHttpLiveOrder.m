//
//  WVRHttpLiveOrder.m
//  WhaleyVR
//
//  Created by qbshen on 2016/12/9.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRHttpLiveOrder.h"

NSString * const kHttpParams_liveOrder_uid = @"uid";
NSString * const kHttpParams_liveOrder_token = @"token";
NSString * const kHttpParams_liveOrder_device_id = @"device_id";
NSString * const kHttpParams_liveOrder_code = @"code";

static NSString *kActionUrl = @"newVR-service/appservice/liveorder/";

@interface WVRHttpLiveOrder ()

@property (nonatomic) NSString* actionStr;

@end


@implementation WVRHttpLiveOrder

- (instancetype)initIsadd:(BOOL)isAdd {
    self = [super init];
    if (self) {
        if (isAdd) {
            self.actionStr = @"add";
        } else {
            self.actionStr = @"cancel";
        }
    }
    return self;
}

/* protocol WVRRequestProtocol method */
- (void)onDataSuccess:(id)dataObject
{
    NSMutableDictionary *result = (NSMutableDictionary*)self.originResponse;
    WVRNewVRBaseResponse *resSuccess = [WVRNewVRBaseResponse yy_modelWithDictionary:result];
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
    return [kActionUrl stringByAppendingString:self.actionStr];
}

@end
