//
//  WVRHttpCollectionOne.m
//  WhaleyVR
//
//  Created by qbshen on 2017/1/6.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRHttpCollectionOne.h"

static NSString *kActionUrl = @"newVR-service/userFavorite/sec/one";


@implementation WVRHttpCollectionOne
/* protocol WVRRequestProtocol method */
- (void)onDataSuccess:(id)dataObject
{
    NSMutableDictionary *result = (NSMutableDictionary*)self.originResponse;
    WVRHttpCollectionOneModel *resSuccess = [WVRHttpCollectionOneModel yy_modelWithDictionary:result];
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
    NSString * url = kActionUrl;
    url = [url stringByAppendingString:@"/"];
    url = [url stringByAppendingString:self.userLoginId ?: @""];
    url = [url stringByAppendingString:@"/"];
    url = [url stringByAppendingString:self.programCode? self.programCode:@""];
    return url;
}

@end

@implementation WVRHttpCollectionOneModel

@end
