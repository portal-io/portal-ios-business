//
//  WVRHttpLiveOrder.h
//  WhaleyVR
//
//  Created by qbshen on 2016/12/9.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRStoreapiBaseGetRequest.h"
#import "WVRHttpAddressModel.h"

extern NSString * const kHttpParams_getAddress_whaleyuid ;

@interface WVRHttpGetAddressModel : WVRStoreapiBaseResponse

@property (nonatomic) WVRHttpAddressModel * member_addressdata;

@end


@interface WVRHttpGetAddress : WVRStoreapiBaseGetRequest

@end
