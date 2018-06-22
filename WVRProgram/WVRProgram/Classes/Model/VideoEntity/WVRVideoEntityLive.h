//
//  WVRVideoEntityLive.h
//  WhaleyVR
//
//  Created by Bruce on 2017/5/3.
//  Copyright © 2017年 Snailvr. All rights reserved.
//
// VR直播VideoEntity

#import "WVRVideoEntity.h"
#import "WVRSQLiveItemModel.h"
@class WVRMediaDto;

@interface WVRVideoEntityLive : WVRVideoEntity

/**
 需要切换清晰度的直播链接数组
 */
@property (nonatomic, weak) NSArray<WVRMediaDto *> *mediaDtos;

/// 开播时间
@property (nonatomic, assign) long beginTime;
/// 结束时间
@property (nonatomic, assign) long endTime;

@property (nonatomic, copy) NSString *intro;        // 直播描述
@property (nonatomic, copy) NSString *address;      // 直播地址
@property (nonatomic, copy) NSString *icon;         // 直播，视频海报

@property (nonatomic, assign) WVRLiveDisplayMode displayMode;

@end
