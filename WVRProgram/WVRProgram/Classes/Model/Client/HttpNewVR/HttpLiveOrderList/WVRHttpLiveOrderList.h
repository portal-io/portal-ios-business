//
//  WVRHttpLiveOrder.h
//  WhaleyVR
//
//  Created by qbshen on 2016/12/9.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRNewVRBaseGetRequest.h"
#import "WVRHttpLiveDetailModel.h"

extern NSString * const kHttpParams_liveOrderList_uid ;
extern NSString * const kHttpParams_liveOrderList_token ;
extern NSString * const kHttpParams_liveOrderList_device_id ;

@interface WVRHttpLiveOrderListModel : WVRNewVRBaseResponse

@property (nonatomic) NSArray<WVRHttpLiveDetailModel *>* data;

@end


@interface WVRHttpLiveOrderList : WVRNewVRBaseGetRequest

@end
