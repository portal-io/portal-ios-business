//
//  WVRPlayerUIManager.h
//  WhaleyVR
//
//  Created by Bruce on 2017/8/17.
//  Copyright © 2017年 Snailvr. All rights reserved.

// PlayerUI与控制器交互的桥梁，解放控制器

#import <Foundation/Foundation.h>
#import "WVRVideoEntity.h"
#import "WVRItemModel.h"
#import "WVRPlayerView.h"
#import "WVRPlayerHelper.h"

@protocol WVRPlayerUIManagerDelegate <NSObject>

@required
- (void)actionOnExit;

- (void)actionRetry;        // 此代理在startView里面调用

- (void)changeToVRMode;

//MARK: - pay

- (void)actionGotoBuy;
- (BOOL)isCharged;

//MARK: - player

- (void)actionPlay:(BOOL)isRepeat;
- (void)actionPause;
- (void)actionResume;

@optional

- (void)actionSetFullscreen:(BOOL)isFullScreen;
- (void)actionSetControlsVisible:(BOOL)isControlsVisible;

@end


@interface WVRPlayerUIManager : NSObject<WVRPlayerViewDelegate>

/// 当前播放器的控制器或者播放器持有者
@property (nonatomic, weak) id<WVRPlayerUIManagerDelegate> uiDelegate;

/// 当前播放器的数据存储对象
@property (nonatomic, weak) WVRVideoEntity *videoEntity;

/// 当前播放视频的详情数据
@property (nonatomic, weak) WVRItemModel *detailBaseModel;

/// 当前播放器的主要交互控件
@property (nonatomic, weak) WVRPlayerView *playerView;

/// 当前播放过程使用的播放器组件
@property (nonatomic, weak) WVRPlayerHelper *vPlayer;

/// 初始化播放器交互UI
- (UIView *)createPlayerViewWithContainerView:(UIView *)containerView;

//MARK: - getter

/// 表示视频正在起播、已失败、已试看结束
- (BOOL)isHaveStartView;

//MARK: - Player

- (void)execDestroy;
- (void)execWaitingPlay;    // 重新开始、播放下一个视频，显示startView
- (void)execChangeDefiBtnTitle:(NSString *)defi;

- (void)execError:(NSString *)message code:(NSInteger)code;
- (void)execPreparedWithDuration:(long)duration;
- (void)execPlaying;
- (void)execSuspend;    // 非活跃状态
- (void)execStalled;    // 卡顿
- (void)execComplete;
- (void)execPositionUpdate:(long)posi buffer:(long)bu duration:(long)duration;
- (void)execDownloadSpeedUpdate:(long)speed;

- (void)execSleepForControllerChanged;
- (void)execResumeForControllerChanged;

- (void)resetVRMode;

//MARK: - payment
// 点播付费节目免费时间结束，需要提示付费
- (void)execFreeTimeOverToCharge:(long)freeTime;
- (void)execPaymentSuccess;

//MARK: - Rotation
- (void)screenWillRotationWithStatus:(BOOL)isLandscape;
- (void)screenRotationCompleteWithStatus:(BOOL)isLandscape;

- (void)execupdateLoadingTip:(NSString *)tip;

/// 链接解析完成时更新清晰度button的title
- (void)exeUpdateDefineTitle;

- (void)execCheckStartViewAnimation;

- (void)setIsFootball:(BOOL)isFootball;

- (void)shouldShowCameraTipView;

@end

