//
//  WVRHttpLiveList.m
//  WhaleyVR
//
//  Created by Xie Xiaojian on 2016/10/27.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRHttpLiveList.h"

NSString * const kHttpParams_liveList_liveStatus = @"liveStatus";

static NSString *kActionUrl = @"newVR-service/appservice/liveProgram/findByCriteria";

@implementation WVRHttpLiveList

/* protocol WVRRequestProtocol method */
- (void)onDataSuccess:(id)dataObject
{
    NSMutableDictionary *result = (NSMutableDictionary*)self.originResponse;
    WVRHttpLiveListParentModel *resSuccess = [WVRHttpLiveListParentModel yy_modelWithDictionary:result];
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
    return kActionUrl;
}

@end


@implementation WVRHttpLiveListParentModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{ @"data": WVRHttpLiveDetailModel.class };
}

@end
