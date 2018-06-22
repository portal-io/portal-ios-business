//
//  WVRPostRequest.h
//  VRManager
//
//  Created by Xie Xiaojian on 16/10/27.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRNewVRBaseGetRequest.h"
#import "WVRHttpLiveDetailModel.h"

extern NSString * const kHttpParams_liveDetails_code ;

@interface WVRHttpLiveDetailsParentModel : WVRNewVRBaseResponse

@property (nonatomic) NSArray<WVRHttpLiveDetailModel *>* data;

@end


@interface WVRHttpLiveDetails : WVRNewVRBaseGetRequest

@end
