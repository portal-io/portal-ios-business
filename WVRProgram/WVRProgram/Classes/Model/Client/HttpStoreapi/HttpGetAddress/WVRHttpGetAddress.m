//
//  WVRHttpLiveOrder.m
//  WhaleyVR
//
//  Created by qbshen on 2016/12/9.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRHttpGetAddress.h"

NSString * const kHttpParams_getAddress_whaleyuid = @"whaleyuid";

static NSString *kActionUrl = @"user/address";

@interface WVRHttpGetAddress ()
@property (nonatomic) NSString* actionStr;

@end


@implementation WVRHttpGetAddress
/* protocol WVRRequestProtocol method */
- (void)onDataSuccess:(id)dataObject
{
    NSMutableDictionary *result = (NSMutableDictionary*)self.originResponse;
    WVRHttpGetAddressModel *resSuccess = [WVRHttpGetAddressModel yy_modelWithDictionary:result];
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
    return kActionUrl;
}

@end


@implementation WVRHttpGetAddressModel

@end
