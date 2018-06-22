//
//  WVRHttpCollectionOne.h
//  WhaleyVR
//
//  Created by qbshen on 2017/1/6.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRNewVRBaseGetRequest.h"
#import "WVRHttpCollectionModel.h"

@interface WVRHttpCollectionOneModel : WVRNewVRBaseResponse

@property (nonatomic) WVRHttpCollectionModel * data;

@end
@interface WVRHttpCollectionOne : WVRNewVRBaseGetRequest

@property (nonatomic) NSString * userLoginId;
@property (nonatomic) NSString * programCode;

@end
