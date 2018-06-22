//
//  WVRPlayerToolVProtocol.h
//  WhaleyVR
//
//  Created by qbshen on 2017/2/17.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,WVRPlayerToolVStatus) {
    WVRPlayerToolVStatusDefault,
    WVRPlayerToolVStatusPrepare,
    WVRPlayerToolVStatusPlaying,
    WVRPlayerToolVStatusPause,
    WVRPlayerToolVStatusStop,
    WVRPlayerToolVStatusError,
    WVRPlayerToolVStatusLive,
    WVRPlayerToolVStatusChangeQuality,
    WVRPlayerToolVStatusSliding,
};

@protocol WVRPlayerToolVDelegate <NSObject>

@required
- (void)playBtnOnClick:(UIButton *)playBtn;

- (void)fullBtnOnClick:(UIButton *)fullBtn;

- (void)launchBtnOnClick:(UIButton *)launchBtn;

- (void)sliderStartScrubbing:(UISlider *)sender;

- (void)sliderEndScrubbing:(UISlider *)sender;

- (void)chooseQuality;

- (void)backOnClick:(UIButton *)sender;

#pragma WVRPlayerLeftToolVDelegate
- (void)clockBtnOnClick:(UIButton *)sender;

#pragma WVRPlayerRightToolVDelegate
- (void)resetBtnOnClick:(UIButton *)sender;

@end


@protocol  WVRPlayerToolVProtocol <NSObject>

@required
- (void)updateFrame:(CGRect)frame;

- (CGSize)getViewSize;

- (void)hiddenV:(BOOL)hidden;

- (BOOL)isHiddenV;

- (WVRPlayerToolVQuality)getQuality;

@optional
- (WVRPlayerToolVStatus )getStatus;

- (void)updateStatus:(WVRPlayerToolVStatus)status;

- (void)updateQuality:(WVRPlayerToolVQuality)quality;

- (void)updateQualityWithTitle:(NSString*)qualityTitle;

- (void)updateWillToQuality:(WVRPlayerToolVQuality)willQuality;

- (WVRPlayerToolVQuality)getWillToQuality;

- (void)updatePosition:(CGFloat)curPosition buffer:(CGFloat)buffer duration:(CGFloat)duration;

- (void)stopLoadingAnimating ;

- (void)startLoadingAnimating;

- (void)updateNetSpeed:(long)speed;

- (void)updateTitle:(NSString *)title;

@end
