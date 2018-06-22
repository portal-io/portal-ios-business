//
//  WVRHttpLiveOrder.m
//  WhaleyVR
//
//  Created by qbshen on 2016/12/9.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRHttpRewardList.h"

NSString * const kHttpParams_rewardList_whaleyuid = @"whaleyuid";

static NSString *kActionUrl = @"user/myprize";

@interface WVRHttpRewardList ()

@property (nonatomic) NSString* actionStr;

@end


@implementation WVRHttpRewardList
/* protocol WVRRequestProtocol method */
- (void)onDataSuccess:(id)dataObject
{
    NSMutableDictionary *result = (NSMutableDictionary*)self.originResponse;
    WVRHttpRewardListModel *resSuccess = [WVRHttpRewardListModel yy_modelWithDictionary:result];
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
    return kActionUrl ;
}

@end


@implementation WVRHttpRewardListModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{ @"prizesdata" : WVRHttpRewardModel.class};
}

@end
