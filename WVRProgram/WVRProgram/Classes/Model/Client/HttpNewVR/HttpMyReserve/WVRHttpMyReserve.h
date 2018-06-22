//
//  WVRHttpMyReserve.h
//  WhaleyVR
//
//  Created by qbshen on 2017/2/16.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRNewVRBaseGetRequest.h"
#import "WVRHttpLiveDetailModel.h"

extern NSString * const kHttpParams_myReserveList_uid ;
extern NSString * const kHttpParams_myReserveList_token ;
extern NSString * const kHttpParams_myReserveList_device_id ;


@interface WVRHttpMyReserveItemModel : NSObject

@property (nonatomic) NSString * displayName;

@property (nonatomic) NSString * poster;

@property (nonatomic) NSString * beginTime;

@property (nonatomic) int liveStatus;

@property (nonatomic) NSString * code;

@property (nonatomic) NSString * displayMode;

@property (nonatomic) NSString * programType;

@property (nonatomic) NSArray<WVRMediaDto*> * liveMediaDtos;

@property (nonatomic) WVRHttpLiveStatModel * stat;

@end


@interface WVRHttpMyReserveModel : WVRNewVRBaseResponse

@property (nonatomic) NSArray<WVRHttpMyReserveItemModel *>* data;

@end


@interface WVRHttpMyReserve : WVRNewVRBaseGetRequest

@end
