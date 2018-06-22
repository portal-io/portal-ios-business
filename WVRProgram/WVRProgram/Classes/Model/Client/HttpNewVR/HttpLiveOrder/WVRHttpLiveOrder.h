//
//  WVRHttpLiveOrder.h
//  WhaleyVR
//
//  Created by qbshen on 2016/12/9.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRNewVRBasePostRequest.h"

extern NSString * const kHttpParams_liveOrder_uid ;
extern NSString * const kHttpParams_liveOrder_token ;
extern NSString * const kHttpParams_liveOrder_device_id ;
extern NSString * const kHttpParams_liveOrder_code ;

@interface WVRHttpLiveOrder : WVRNewVRBasePostRequest

-(instancetype)initIsadd:(BOOL)isAdd;

@end
