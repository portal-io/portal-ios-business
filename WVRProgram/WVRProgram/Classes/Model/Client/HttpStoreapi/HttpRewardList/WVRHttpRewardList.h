//
//  WVRHttpLiveOrder.h
//  WhaleyVR
//
//  Created by qbshen on 2016/12/9.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRStoreapiBaseGetRequest.h"
#import "WVRHttpAddressModel.h"
#import "WVRHttpRewardModel.h"

extern NSString * const kHttpParams_rewardList_whaleyuid ;


@interface WVRHttpRewardListModel : WVRStoreapiBaseResponse

@property (nonatomic) NSArray<WVRHttpRewardModel *> * prizesdata;
@property (nonatomic) WVRHttpAddressModel * addressdata;

@end


@interface WVRHttpRewardList : WVRStoreapiBaseGetRequest

@end
