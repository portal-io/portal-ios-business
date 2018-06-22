//
//  WVRHttpCollectionGet.m
//  WhaleyVR
//
//  Created by qbshen on 2017/1/6.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRHttpCollectionGet.h"

/*
 
 page    页码
 size    页大小
 userLoginId 用户id*/
NSString * const kHttpParams_collectionGet_userLoginId = @"userLoginId";
NSString * const kHttpParams_collectionGet_page = @"page";
NSString * const kHttpParams_collectionGet_size = @"size";

static NSString *kActionUrl = @"newVR-service/userFavorite/sec/findByCriteria";


@implementation WVRHttpCollectionGet
/* protocol WVRRequestProtocol method */
- (void)onDataSuccess:(id)dataObject
{
    NSMutableDictionary *result = (NSMutableDictionary*)self.originResponse;
    WVRHttpCollectionGetModel *resSuccess = [WVRHttpCollectionGetModel yy_modelWithDictionary:result];
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
@implementation WVRHttpCollectionGetModel

@end

@implementation WVRHttpCollectionGetDataModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{ @"content": WVRHttpCollectionModel.class };
}

@end
