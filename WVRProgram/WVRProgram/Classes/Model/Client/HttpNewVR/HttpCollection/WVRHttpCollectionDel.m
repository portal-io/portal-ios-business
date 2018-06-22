//
//  WVRHttpCollectionDel.m
//  WhaleyVR
//
//  Created by qbshen on 2017/1/6.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRHttpCollectionDel.h"
NSString * const kHttpParams_collectionDel_userLoginId = @"userLoginId";
NSString * const kHttpParams_collectionDel_programCode = @"programCodes";

static NSString *kActionUrl = @"newVR-service/userFavorite/pri/deletes";

@implementation WVRHttpCollectionDel
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
    return kActionUrl;
}
@end
