//
//  WVRPostRequest.h
//  VRManager
//
//  Created by Xie Xiaojian on 16/10/27.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRNewVRBaseGetRequest.h"
#import "WVRHttpLiveDetailModel.h"

extern NSString * const kHttpParams_liveDetail_code ;

@interface WVRHttpLiveDetailParentModel : WVRNewVRBaseResponse

@property (nonatomic) WVRHttpLiveDetailModel *data;

@end


@interface WVRHttpLiveDetail : WVRNewVRBaseGetRequest

@end
