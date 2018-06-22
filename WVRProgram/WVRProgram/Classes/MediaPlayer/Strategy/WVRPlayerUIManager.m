//
//  WVRPlayerUIManager.m
//  WhaleyVR
//
//  Created by Bruce on 2017/8/17.
//  Copyright © 2017年 Snailvr. All rights reserved.

// PlayerUI与控制器交互的桥梁，解放控制器
// 时间交互，UI点击事件埋点

#import "WVRPlayerUIManager.h"
#import "WVRPlayerViewProtocol.h"
#import "WVRPlayerViewLive.h"

@interface WVRPlayerUIManager() {
    
    long _videoDuration;
    NSDictionary *_veDict;
}

@end


@implementation WVRPlayerUIManager

- (UIView *)createPlayerViewWithContainerView:(UIView *)containerView {
    
    BOOL isFullScreen = [self.uiDelegate isKindOfClass:NSClassFromString(@"WVRPlayerVC")];
    
    // live 已经重写该方法
    WVRPlayerViewStyle style = isFullScreen ? WVRPlayerViewStyleLandscape : WVRPlayerViewStyleHalfScreen;
    float height = containerView.height;
    float width = containerView.width;
    CGRect rect = CGRectMake(0, 0, MAX(width, height), MIN(width, height));
    
    NSDictionary *veDict = [[self videoEntity] yy_modelToJSONObject];
    WVRPlayerView *view = [[WVRPlayerView alloc] initWithFrame:rect style:style videoEntity:veDict delegate:self];
    
    [containerView addSubview:view];
    self.playerView = view;
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.top.equalTo(@0);
        make.size.equalTo(view.superview);
    }];
    
    return view;
}

- (void)setPlayerView:(WVRPlayerView *)playerView {
    _playerView = playerView;
    
    playerView.realDelegate = self;
}

#pragma mark - WVRPlayerViewDelegate

- (BOOL)isOnError {
    
    return [self.vPlayer isPlayError];
}

- (BOOL)isPrepared {
    
    return [self.vPlayer isPrepared];
}

- (NSDictionary *)actionGetVideoInfo:(BOOL)needRefresh {
    
    if (needRefresh || !_veDict) {
        
        _veDict = [self.videoEntity yy_modelToJSONObject];
    }
    
    return _veDict;
}

- (BOOL)currentVideoIsDefaultVRMode {
    
    return [self.videoEntity isDefaultVRMode];
}

- (BOOL)currentIsDefaultSD {
    
    return [self.videoEntity isDefault_SD];
}

- (NSString *)definitionToTitle:(NSString *)defi {
    
    return [WVRVideoEntity definitionToTitle:defi];
}

- (DefinitionType)definitionToType:(NSString *)defi {
    
    return [WVRVideoEntity definitionToType:defi];
}

// live中已重写，目前除了直播，其他视频还没有在全屏播放器页支付的需求（20170711）
- (void)actionGotoBuy {
    
    [self.uiDelegate actionGotoBuy];
}

- (void)actionResume {
    
    if (self.vPlayer.isValid) {
        
        [self.vPlayer start];
        [self.playerView execPlaying];
        
        [self.uiDelegate actionResume];
    }
}

- (void)actionPause {
    
    if (self.vPlayer.isValid) {
        
        [self.vPlayer stop];
    }
    [self.playerView execSuspend];
    
    [self.uiDelegate actionPause];
}

- (BOOL)isPlaying {
    
    return [_vPlayer isPlaying];
}

- (void)actionOrientationReset {
    
    [WVRTrackEventMapping trackingVideoPlay:@"center"];
    
    [_vPlayer orientationReset];
    [self.playerView scheduleHideControls];
}

- (BOOL)actionSwitchVR:(BOOL)isMonocular {
    
    if (![self.uiDelegate isCharged]) {
        [SQToastTool showMessageCenter:self.playerView.wvr_viewController.view withMessage:kToastNotChargeToUnity];
        return NO;
    }
    
    BOOL success = YES;
    
    if (self.videoEntity.streamType != STREAM_VR_LOCAL ) {
        // 非本地视频，进入Launcher
        WVRRenderType type = [self.vPlayer getRenderType];
        BOOL is3D_OCT = (type == MODE_OCTAHEDRON_HALF_LR || type == MODE_OCTAHEDRON_STEREO_LR);
        BOOL not4kSupport = ![WVRDeviceModel is4KSupport];
        
        if (not4kSupport && is3D_OCT) {
            [self.vPlayer setMonocular:isMonocular];
            success = YES;
        } else {
            [self.uiDelegate changeToVRMode];
            success = NO;
        }
        
    } else {
        
        [self.vPlayer setMonocular:isMonocular];
        success = YES;
    }
    
    if (success) {
        
        [WVRTrackEventMapping trackingVideoPlay:@"monocular"];
        
        [self.videoEntity setDefaultVRMode:!isMonocular];
    }
    
    return success;
}

- (void)actionSeekToTime:(float)scale {
    
    if (_videoDuration <= 0) { return; }                 // 未获取到视频总时长，不支持seek
    if (![self.vPlayer isPrepared]) { return; }          // 还未起播，不支持seek
    
    long time = _videoDuration * scale;
    [self.vPlayer seekTo:time];
    
    [self.playerView execStalled];
    [self.playerView scheduleHideControls];
}

// 是否为播放结束后再次播放
- (void)actionPlay:(BOOL)isRepeat {
    
    [self.uiDelegate actionPlay:isRepeat];
}

- (NSString *)actionChangeDefinition {
    
    if (self.videoEntity.isFootball) {
        SQToastInKeyWindow(kToastNoChangeDefinition);
        
        return self.videoEntity.curDefinition;
    }
    
    if (![self.vPlayer isPrepared]) { return self.videoEntity.curDefinition; }
    
    NSArray *list = self.videoEntity.parserdUrlModelList;
    
    if (list.count <= 1 || self.videoEntity.isFootball) {
        
        SQToastInKeyWindow(kToastNoChangeDefinition);
        
        return self.videoEntity.curDefinition;
    }
    
    [WVRTrackEventMapping trackingVideoPlay:@"renderType"];
    
    self.vPlayer.dataParam.url = [self.videoEntity playUrlChangeToNextDefinition];
    self.vPlayer.dataParam.renderType = [WVRVideoEntity renderTypeForStreamType:self.videoEntity.streamType definition:self.videoEntity.curDefinition renderTypeStr:self.videoEntity.curUrlModel.renderType];
    
    if (self.videoEntity.streamType != STREAM_VR_LIVE) {
        long position = [_vPlayer getCurrentPosition];
        self.vPlayer.dataParam.position = (labs(position - _vPlayer.getDuration) <= 1000) ? 0 : position;
    }
    
    [self.vPlayer setParamAndPlay:self.vPlayer.dataParam];
    
    [self.playerView execStalled];
    [self.playerView scheduleHideControls];
    
    return self.videoEntity.curDefinition;
}

- (void)actionRetry {
    
    [self.uiDelegate actionRetry];
}

- (void)actionPanGustrue:(float)x Y:(float)y {
    
    [self.vPlayer viewTouchesMoved:x Y:y];
}

- (void)actionTouchesBegan {
    
    [self.vPlayer viewTouchesStarted];
}

- (void)actionChangeCameraStand:(NSString *)standType {
    
    if ([self.videoEntity.currentStandType isEqualToString:standType]) { return; }
    
    WVRMediaDto *selectDto = nil;
    for (WVRMediaDto *dto in self.detailBaseModel.mediaDtos) {
        
        if ([standType isEqualToString:dto.source]) {
            
            selectDto = dto;
            break;
        }
    }
    
    if (!selectDto) { return; }
    
    if ([standType isEqualToString:@"Public"]) {
        
        self.vPlayer.dataParam.renderType = [WVRVideoEntity renderTypeForRenderTypeStr:selectDto.renderType];
        [self.vPlayer setBottomViewHidden:NO];
    } else {
        
        self.vPlayer.dataParam.renderType = MODE_HALF_SPHERE_VIP;
        [self.vPlayer setBottomViewHidden:YES];
    }
    
    self.videoEntity.currentStandType = standType;
    
    self.vPlayer.dataParam.url = [NSURL URLWithUTF8String:selectDto.playUrl];
    self.vPlayer.dataParam.position = [self.vPlayer getCurrentPosition];
    
    [self.playerView execChangeDefiBtnTitle:selectDto.curDefinition];
    
    [[self vPlayer] setParamAndPlay:self.vPlayer.dataParam];
    [[self playerView] execStalled];
}

- (NSArray<NSDictionary *> *)actionGetCameraStandList {
    
    if (self.detailBaseModel.mediaDtos == nil) {
        return nil;
    }
    
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:8];
    
    for (WVRMediaDto *dto in self.detailBaseModel.mediaDtos) {
        BOOL isSelected = [self.videoEntity.currentStandType isEqualToString:dto.source];
        NSString *standType = dto.source;
        
        if (standType.length > 0) {
            NSDictionary *typeDict = @{ standType : @(isSelected) };
            [arr addObject:typeDict];
        }
    }
    return arr;
}

#pragma mark - WVRPlayerViewDelegate


/**
 点击播放-暂停按钮交互事件
 
 @return 当前是否在播放
 */
- (BOOL)actionPlayBtnClick {
    
    if (self.vPlayer.isOnBuffering) { return NO; }
    
    BOOL playerIsPlaying = [self.vPlayer isPlaying];
    BOOL playStatus = NO;
    
    if (self.vPlayer.isComplete) {
        
        [WVRTrackEventMapping trackingVideoPlay:@"replay"];
        
        [self.uiDelegate actionPlay:YES];
        playStatus = NO;
    } else {
        if (!playerIsPlaying) {          // 暂停 -> 播放
            
            [WVRTrackEventMapping trackingVideoPlay:@"resume"];
            [self.uiDelegate actionResume];
            playStatus = YES;
        } else {                        // 播放 -> 暂停
            
            [WVRTrackEventMapping trackingVideoPlay:@"pause"];
            [self.uiDelegate actionPause];
            playStatus = NO;
        }
    }
    
    [self.playerView scheduleHideControls];
    
    return playStatus;
}

/**
 返回按钮点击事件
 */
- (void)actionBackBtnClick {
    
    // 直播时横屏状态
    BOOL liveBack = (self.playerView.viewStyle == WVRPlayerViewStyleLive && self.playerView.isLandscape);
    // 半屏播放时横屏状态
    BOOL isHalfS = (self.playerView.viewStyle == WVRPlayerViewStyleHalfScreen && self.playerView.isLandscape);
    
    if (isHalfS || liveBack) {
        if ([self.uiDelegate respondsToSelector:@selector(actionSetFullscreen:)]) {
            [self.uiDelegate actionSetFullscreen:NO];
        }
    } else {
        
        [WVRTrackEventMapping trackingVideoPlay:@"back"];
        
        if ([self.uiDelegate respondsToSelector:@selector(actionOnExit)]) {
            [self.uiDelegate actionOnExit];
        }
    }
}

- (void)actionFullscreenBtnClick {
    
    if (self.playerView.viewStyle == WVRPlayerViewStyleHalfScreen) {
        
        [WVRTrackEventMapping trackingVideoPlay:@"fullScreen"];
        
        if ([self.uiDelegate respondsToSelector:@selector(actionSetFullscreen:)]) {
            [self.uiDelegate actionSetFullscreen:YES];
        }
    }
}

- (void)actionSetControlsVisible:(BOOL)isControlsVisible {
    
    [self.uiDelegate actionSetControlsVisible:isControlsVisible];
}

//MARK: - pay

- (BOOL)isCharged {
    
    return [self.uiDelegate isCharged];
}

#pragma mark - Events


/// 表示视频正在起播、已失败、已试看结束
- (BOOL)isHaveStartView {
    
    return [self.playerView isHaveStartView];
}

//MARK: - Player

- (void)execDestroy {
    
    [self.playerView execDestroy];
}

// 重新开始、播放下一个视频，显示startView
- (void)execWaitingPlay {
    
    [self.playerView execWaitingPlay];
}

- (void)execChangeDefiBtnTitle:(NSString *)defi {
    
    [self.playerView execChangeDefiBtnTitle:defi];
}

- (void)execError:(NSString *)message code:(NSInteger)code {
    
    [self.playerView execError:message code:code];
}

- (void)execPreparedWithDuration:(long)duration {
    
    _videoDuration = duration;
    [self.playerView execPreparedWithDuration:duration];
}

- (void)execPlaying {
    
    [self.playerView execPlaying];
}

- (void)execSuspend {
    
    [self.playerView execSuspend];
}
    // 非活跃状态
- (void)execStalled {
    
    [self.playerView execStalled];
}
    // 卡顿
- (void)execComplete {
    
    [self.playerView execComplete];
}

- (void)execPositionUpdate:(long)posi buffer:(long)bu duration:(long)duration {
    
    if (self.vPlayer.isComplete) { return; }
    if (self.videoEntity.streamType == STREAM_VR_LOCAL) { bu = 0; }
    
    _videoDuration = duration;
    [self.playerView execPositionUpdate:posi buffer:bu duration:duration];
}

- (void)execDownloadSpeedUpdate:(long)speed {
    
    [self.playerView execDownloadSpeedUpdate:speed];
}


- (void)execSleepForControllerChanged {
    
    [self.playerView execSleepForControllerChanged];
}

- (void)execResumeForControllerChanged {
    
    [self.playerView execResumeForControllerChanged];
}


//MARK: - payment
// 点播付费节目免费时间结束，需要提示付费
- (void)execFreeTimeOverToCharge:(long)freeTime {
    
    [self.playerView execFreeTimeOverToCharge:freeTime duration:_videoDuration];
}

- (void)execPaymentSuccess {
    
    [self.playerView execPaymentSuccess];
}


//MARK: - Rotation
- (void)screenWillRotationWithStatus:(BOOL)isLandscape {
    
    [self.playerView screenWillRotationWithStatus:isLandscape];
}

- (void)screenRotationCompleteWithStatus:(BOOL)isLandscape {
    
    [self.playerView screenRotationCompleteWithStatus:isLandscape];
}


- (void)execupdateLoadingTip:(NSString *)tip {
    
    [self.playerView execupdateLoadingTip:tip];
}


/// 链接解析完成时更新清晰度button的title
- (void)exeUpdateDefineTitle {
    
    [self.playerView exeUpdateDefineTitle];
}


- (void)execCheckStartViewAnimation {
    
    [self.playerView execCheckStartViewAnimation];
}


- (void)setIsFootball:(BOOL)isFootball {
    
    [self.playerView setIsFootball:isFootball];
}

- (void)shouldShowCameraTipView {
    
    [[self playerView] shouldShowCameraTipView];
}

- (void)resetVRMode {
    
    [self.playerView resetVRMode];
}

@end
