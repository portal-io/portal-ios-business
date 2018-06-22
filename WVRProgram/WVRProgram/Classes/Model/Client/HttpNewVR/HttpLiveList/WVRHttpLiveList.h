//
//  WVRPostRequest.h
//  VRManager
//
//  Created by Xie Xiaojian on 16/10/27.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRNewVRBaseGetRequest.h"
#import "WVRHttpLiveDetailModel.h"

extern NSString * const kHttpParams_liveList_liveStatus;

@interface WVRHttpLiveListParentModel : WVRNewVRBaseResponse

@property (nonatomic) NSArray<WVRHttpLiveDetailModel *>* data;

@end


@interface WVRHttpLiveList : WVRNewVRBaseGetRequest

@end
