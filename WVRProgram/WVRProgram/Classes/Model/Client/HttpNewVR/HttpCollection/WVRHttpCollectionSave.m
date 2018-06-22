//
//  WVRHttpCollectionSave.m
//  WhaleyVR
//
//  Created by qbshen on 2017/1/6.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRHttpCollectionSave.h"

/*
 userLoginId
 userName
 programCode
 videoType
 programType
 status
 duration
 pic
 */

NSString * const kHttpParams_collectionSave_userLoginId = @"userLoginId";
NSString * const kHttpParams_collectionSave_userName = @"userName";
NSString * const kHttpParams_collectionSave_programCode = @"programCode";
NSString * const kHttpParams_collectionSave_programName = @"programName";
NSString * const kHttpParams_collectionSave_videoType = @"videoType";

NSString * const kHttpParams_collectionSave_programType = @"programType";
NSString * const kHttpParams_collectionSave_status = @"status";
NSString * const kHttpParams_collectionSave_duration = @"duration";
NSString * const kHttpParams_collectionSave_picUrl = @"picUrl";

static NSString *kActionUrl = @"newVR-service/userFavorite/pri/save";


@implementation WVRHttpCollectionSave
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
