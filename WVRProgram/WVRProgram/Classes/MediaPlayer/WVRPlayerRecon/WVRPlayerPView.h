//
//  WVR360PlayerPView.h
//  WhaleyVR
//
//  Created by Wang Tiger on 17/3/17.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WVRPlayerViewLifeCycle <NSObject>
- (void) showInitLoading;
- (void) removeInitLoading;
- (void) showInitError;
- (void) showLoadingView;
- (void) updateLoadingLabel;
- (void) removeLoadingView;
- (void) showComplete;

@end

@protocol WVRPlayerViewToolbar <NSObject>
- (void) changePlayButtonStatus:(BOOL) isPlaying;
- (void) showControllToolbar;
- (void) hideControllToobar;
- (void) lockScreen;
- (void) unlockScreen;
- (void) seekTo:(long) position;
- (void) setSeekMax:(long) max;
- (void) setSeekBufferPosition:(long) position;
- (void) changeSeekEnable:(BOOL) isEnable;

@end

@protocol WVRPlayerViewLandscape <NSObject>
- (void) showHalfScreen;
- (void) showFullScreen;
- (void) updateFullScreen;

@end

@protocol WVRPlayerViewRender <NSObject>
- (void) showRenderTypePlant;
- (void) hideRenderTypePlant;

@end

@protocol WVRPlayerViewModel <NSObject>
- (void) updateModeLabel;

@end

@protocol WVRPlayerViewResolution <NSObject>
- (void) updateResolutionLabel;
- (void) changeResolutionBtnEnable:(BOOL) isEnable;

@end

@protocol WVRPlayerViewNetwork <NSObject>
- (void) updateNetWorkSpeedLabel;
- (void) showNetworkError;

@end

@protocol WVRPlayerViewSource <NSObject>
- (void) showLocalPlayer;
- (void) showOnlinePlayer;
- (void) showLivePlayer;

@end

@protocol WVRPlayerPView <NSObject, WVRPlayerViewLifeCycle, WVRPlayerViewToolbar, WVRPlayerViewLandscape, WVRPlayerViewRender, WVRPlayerViewModel, WVRPlayerViewResolution, WVRPlayerViewNetwork, WVRPlayerViewSource>

@end
