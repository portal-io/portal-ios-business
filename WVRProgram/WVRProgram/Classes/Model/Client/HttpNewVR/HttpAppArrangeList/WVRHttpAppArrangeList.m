//
//  WVRHttpGetLiveProgramList.m
//  VRManager
//
//  Created by Wang Tiger on 16/6/20.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRHttpAppArrangeList.h"

static NSString *kActionUrl = @"newVR-app-service/app/arrange/list";

@implementation WVRHttpAppArrangeList

/* protocol WVRRequestProtocol method */
- (void)onDataSuccess:(id)dataObject
{
    NSMutableDictionary *result = (NSMutableDictionary*)self.originResponse;
    WVRHttpAppArrangeListModel *resSuccess = [WVRHttpAppArrangeListModel yy_modelWithDictionary:result];
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


@implementation WVRHttpAppArrangeListModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{ @"data" : [WVRHttpArrangeModel class],  };
}

@end
