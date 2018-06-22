//
//  WVRLivePlayerBottomToolView.m
//  WhaleyVR
//
//  Created by qbshen on 2017/2/20.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRLivePlayerBottomToolView.h"

#define HEIGHT_DEFAULT (60.f)

@interface WVRLivePlayerBottomToolView ()

@property (nonatomic) CGFloat mSelfHeight ;
@property (nonatomic) WVRPlayerToolVQuality mWillToQuality;
@property (nonatomic) WVRPlayerToolVQuality quality;
@property (nonatomic) WVRPlayerToolVStatus mStatus;

@end


@implementation WVRLivePlayerBottomToolView

- (WVRPlayerToolVQuality)getQuality
{
    return _quality;
}

- (WVRPlayerToolVStatus )getStatus
{
    return _mStatus;
}
- (void)updateWillToQuality:(WVRPlayerToolVQuality)willQuality
{
    _mWillToQuality = willQuality;
}

- (WVRPlayerToolVQuality)getWillToQuality
{
    return _mWillToQuality;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.mSelfHeight = fitToWidth(HEIGHT_DEFAULT);
//    [self addSubview:self.mBarrageV];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.mBarrageV.frame = self.bounds;
    self.mBarrageV.height -= self.textFieldV.height;
}

- (WVRLiveBarrageView *)mBarrageV
{
    if (!_mBarrageV) {
        _mBarrageV = (WVRLiveBarrageView *)VIEW_WITH_NIB(NSStringFromClass([WVRLiveBarrageView class]));
    }
    return _mBarrageV;
}

- (void)setClickDelegate:(id<WVRLivePlayerBTVDelegate>)clickDelegate
{
    _clickDelegate = clickDelegate;
    [self initViews];
}

- (void)initViews
{
    self.textFieldV.realDelegate = self.clickDelegate;
    [self.fullBtn addTarget:self action:@selector(fullBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.launchBtn addTarget:self.clickDelegate action:@selector(launchBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)fullBtnOnClick:(UIButton*)sender
{
    if ([self.clickDelegate respondsToSelector:@selector(fullBtnOnClick:)]) {
        [self.clickDelegate fullBtnOnClick:sender];
    }
}

- (void)updateFrame:(CGRect)frame
{
    self.frame = frame;
    
}

- (CGSize)getViewSize
{
    return CGSizeMake(SCREEN_WIDTH, self.mSelfHeight);
}

- (void)hiddenV:(BOOL)hidden
{
    self.hidden = hidden;
}

- (BOOL)isHiddenV
{
    return self.hidden;
}

- (void)updateStatus:(WVRPlayerToolVStatus)status
{
    _mStatus = status;
    switch (status) {
        case WVRPlayerToolVStatusDefault:
            [self enableDefaultStatus];
            break;
        case WVRPlayerToolVStatusPrepare:
            [self enablePrepareStatus];
            break;
        case WVRPlayerToolVStatusPlaying:
            [self enablePlayingStatus];
            break;
        case WVRPlayerToolVStatusPause:
            [self enablePauseStatus];
            break;
        case WVRPlayerToolVStatusStop:
            [self enableStopStatus];
            break;
        case WVRPlayerToolVStatusError:
            [self enableErrorStatus];
            break;
        
        default:
            break;
    }
}

- (void)updateSubStatus:(WVRPlayerToolVSubStatus)subStatus
{
    
    switch (subStatus) {
        case WVRPlayerToolVSubStatusBanner:
            self.textFieldV.hidden = YES;
            self.fullBtn.hidden = NO;
            self.launchBtn.hidden = NO;
            self.mSelfHeight = fitToWidth(60.f);
            break;
        case WVRPlayerToolVSubStatusFull:
            self.textFieldV.hidden = NO;
            self.fullBtn.hidden = YES;
            self.launchBtn.hidden = YES;
            self.mSelfHeight = fitToWidth(160.f);
            break;
        default:
            break;
    }
}

- (void)updateQuality:(WVRPlayerToolVQuality)quality
{
    _quality = quality;
}

- (void)enableDefaultStatus
{
//    self.startBtn.selected = NO;
//    self.startBtn.userInteractionEnabled = NO;
//    self.processSlider.enabled = NO;
    
}

- (void)enablePrepareStatus
{
//    self.startBtn.selected = YES;
//    self.startBtn.userInteractionEnabled = YES;
//    self.processSlider.enabled = YES;
    
}

- (void)enablePlayingStatus
{
//    self.startBtn.selected = YES;
//    self.startBtn.userInteractionEnabled = YES;
//    self.processSlider.enabled = YES;
    
}

- (void)enablePauseStatus
{
//    self.startBtn.selected = NO;
//    self.startBtn.userInteractionEnabled = YES;
//    self.processSlider.enabled = YES;
    
}

- (void)enableStopStatus
{
//    self.startBtn.selected = NO;
//    self.startBtn.userInteractionEnabled = YES;
//    self.processSlider.enabled = YES;
    
}

- (void)enableErrorStatus
{
//    self.startBtn.selected = NO;
//    self.startBtn.userInteractionEnabled = NO;
//    self.processSlider.enabled = NO;
    
}


- (void)enableHidenStatus
{
    self.hidden = YES;
}

- (void)enableShowStatus
{
    self.hidden = NO;
}

- (void)setVisble
{
    [self.textFieldV setVisibel:YES];
}

- (void)updatePosition:(CGFloat)curPosition buffer:(CGFloat)buffer duration:(CGFloat)duration
{
//    [self.processSlider updatePosition:curPosition buffer:buffer duration:duration];
//    self.curTimeL.text = [self numberToTime:curPosition/1000];
//    self.totalTimeL.text = [self numberToTime:duration/1000];
}

- (NSString *)numberToTime:(long)time {
    
    return [NSString stringWithFormat:@"%02d:%02d", (int)time/60, (int)time%60];
}
@end
