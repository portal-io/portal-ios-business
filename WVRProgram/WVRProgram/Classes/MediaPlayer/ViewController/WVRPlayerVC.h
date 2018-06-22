//
//  WVRPlayerVC.h
//  WhaleyVR
//
//  Created by Snailvr on 2016/11/18.
//  Copyright © 2016年 Snailvr. All rights reserved.
//
// 全屏播放控制器基类，请勿直接使用
// 目前支持全屏播放的类型有：点播VR全景视频、直播全景视频、本地缓存全景视频

#import <UIKit/UIKit.h>
#import "WVRVideoDetailVCModel.h"
#import "WVRLiveDetailModel.h"
#import "WVRPlayerHelper.h"

#import "WVRPlayerUIManager.h"
@class WVRVideoEntity;

@interface WVRPlayerVC : UIViewController<WVRPlayerUIManagerDelegate, WVRPlayerHelperDelegate>

@property (nonatomic, assign) long curPosition;         // use for from other page

#pragma mark - 子类公共属性

/// set get 方法会被子类重写
@property (nonatomic, strong) WVRVideoEntity *videoEntity;

@property (nonatomic, strong) WVRItemModel *detailBaseModel;

@property (nonatomic, assign) BOOL isCharged;                // 已付费

@property (nonatomic, strong) WVRPlayerHelper *vPlayer;
//@property (nonatomic, weak  ) WVRPlayerView   *wPlayerView;

@property (nonatomic, strong, readonly) WVRPlayerUIManager *playerUI;

@property (nonatomic, assign) BOOL lotterySwitch;   // live
@property (nonatomic, assign) BOOL danmuSwitch;     // live

@property (nonatomic, assign) long syncScrubberNum;

@property (nonatomic, assign) BOOL isFootball;

#pragma mark - 暴露给子类的API

/// 初始化播放器数据
- (void)buildInitData;

- (void)createLayoutView;
- (void)registerObserverEvent;

- (void)syncScrubber;

- (void)dealWithDetailData:(WVRItemModel *)model;
- (void)checkFreeTime;
- (void)dealWithPaymentOver;

- (void)controlOnPause;
- (void)controlOnResume;

- (void)changeToVRMode;

- (void)dismissViewController;

#pragma mark - external func

@end
