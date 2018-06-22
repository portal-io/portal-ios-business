//
//  WVRHttpCollectionGet.h
//  WhaleyVR
//
//  Created by qbshen on 2017/1/6.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRNewVRBasePostRequest.h"
#import "WVRHttpCollectionModel.h"

extern NSString * const kHttpParams_collectionGet_userLoginId ;
extern NSString * const kHttpParams_collectionGet_page ;
extern NSString * const kHttpParams_collectionGet_size ;

/*
 "last": true,
 "totalPages": 1,
 "totalElements": 5,
 "first": true,
 "numberOfElements": 5,
 */

@interface WVRHttpCollectionGetDataModel : NSObject

@property (nonatomic) NSArray<WVRHttpCollectionModel*> *content;
@property (nonatomic) NSString* totalPages;

@end
@interface WVRHttpCollectionGetModel : WVRNewVRBaseResponse

@property (nonatomic) WVRHttpCollectionGetDataModel * data;
@end
@interface WVRHttpCollectionGet : WVRNewVRBasePostRequest

@end
