//
//  WVRSmallPlayerToolView.m
//  WhaleyVR
//
//  Created by qbshen on 2017/2/15.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRSmallPlayerBottomToolView.h"
#import "WVRSlider.h"

@interface WVRSmallPlayerBottomToolView ()

@property (nonatomic,readonly) WVRPlayerToolVQuality quality;

@property (nonatomic, weak) UIView *bottomShadow;       // layer

@property (nonatomic) WVRPlayerToolVQuality mWillToQuality;

@property (nonatomic) WVRPlayerToolVStatus mStatus;

@property (nonatomic) CAGradientLayer *gradientLayer;

@end


@implementation WVRSmallPlayerBottomToolView
@synthesize clickDelegate = _clickDelegate;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self bottomShadow];
}

- (void)styleForLaunchBtn {
    
//    [self.launchBtn setTitle:@"手机模式" forState:UIControlStateNormal];
}

- (void)handleGesture {

}

//- (nullable UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event
//{
//    return self;
//}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    CGFloat yOffset = point.y;
    BOOL response = yOffset > 0;
    
    return response;
}


- (UIView *)bottomShadow {

    if (!_bottomShadow) {
        
        UIView *bottomShadow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAX(SCREEN_WIDTH, SCREEN_HEIGHT), HEIGHT_DEFAULT)];
        
        // 设置渐变效果
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = bottomShadow.bounds;
        _gradientLayer.colors = [NSArray arrayWithObjects:
                                (id)[[UIColor colorWithWhite:0 alpha:0] CGColor],
                                (id)[[UIColor colorWithWhite:0 alpha:0.8] CGColor], nil];
        _gradientLayer.startPoint = CGPointMake(0, 0);
        _gradientLayer.endPoint = CGPointMake(0, 1);
        [bottomShadow.layer insertSublayer:_gradientLayer atIndex:0];
        
        bottomShadow.backgroundColor = [UIColor clearColor];
        bottomShadow.userInteractionEnabled = NO;
        [self insertSubview:bottomShadow atIndex:0];
        bottomShadow.bottomY = self.height;
        
        _bottomShadow = bottomShadow;
    }
    return _bottomShadow;
}

- (void)layoutSubviews
{
    self.bottomShadow.frame = self.bounds;
    self.gradientLayer.frame = self.bottomShadow.bounds;
}

- (WVRPlayerToolVStatus )getStatus
{
    return _mStatus;
}

- (WVRPlayerToolVQuality)getQuality
{
    return _quality;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)setClickDelegate:(id<WVRSmallPlayerTVDelegate>)clickDelegate
{
    _clickDelegate = clickDelegate;
    [self initViews];
}

- (void)initViews
{
    [self.startBtn addTarget:self.clickDelegate action:@selector(playBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.fullBtn addTarget:self action:@selector(fullBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.launchBtn addTarget:self.clickDelegate action:@selector(launchBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.processSlider addTarget:self.clickDelegate action:@selector(sliderDragEnd:) forControlEvents:UIControlEventValueChanged];
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
   return CGSizeMake(SCREEN_WIDTH, HEIGHT_DEFAULT);
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
//    self.userInteractionEnabled = YES;
    self.fullBtn.enabled = YES;
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
        case WVRPlayerToolVStatusChangeQuality:
            [self enableChangeQuStatus];
            break;
        case WVRPlayerToolVStatusSliding:
            [self enableSlidingStatus];
            break;
        default:
            break;
    }
}

- (void)updateQuality:(WVRPlayerToolVQuality)quality
{
    _quality = quality;
}

- (void)updateWillToQuality:(WVRPlayerToolVQuality)willQuality
{
    _mWillToQuality = willQuality;
}

- (WVRPlayerToolVQuality)getWillToQuality
{
    return _mWillToQuality;
}

- (void)enableDefaultStatus
{
    self.startBtn.selected = NO;
    self.startBtn.userInteractionEnabled = NO;
    self.processSlider.enabled = NO;
    
}

- (void)enablePrepareStatus
{
    self.startBtn.selected = YES;
    self.startBtn.userInteractionEnabled = YES;
    self.processSlider.enabled = YES;
    self.fullBtn.userInteractionEnabled = YES;
}

- (void)enablePlayingStatus
{
    self.startBtn.selected = YES;
    self.startBtn.userInteractionEnabled = YES;
    self.processSlider.enabled = YES;
    
}

- (void)enablePauseStatus
{
    self.startBtn.selected = NO;
    self.startBtn.userInteractionEnabled = YES;
    self.processSlider.enabled = YES;
    
}

- (void)enableStopStatus
{
    self.startBtn.selected = NO;
    self.startBtn.userInteractionEnabled = YES;
    self.processSlider.enabled = YES;
    
}

- (void)enableErrorStatus
{
    self.startBtn.selected = NO;
    self.startBtn.userInteractionEnabled = NO;
    self.processSlider.enabled = NO;
    
}

- (void)enableChangeQuStatus
{
    self.startBtn.selected = NO;
    self.startBtn.userInteractionEnabled = NO;
    self.processSlider.enabled = NO;
//    self.userInteractionEnabled = NO;
    self.fullBtn.enabled = NO;
}

- (void)enableSlidingStatus
{
    self.startBtn.selected = NO;
    self.startBtn.userInteractionEnabled = NO;
    self.processSlider.enabled = NO;
//    self.userInteractionEnabled = NO;
    self.fullBtn.enabled = NO;
}


- (void)enableHidenStatus
{
    self.hidden = YES;
}

- (void)enableShowStatus
{
    self.hidden = NO;
}

- (void)updatePosition:(CGFloat)curPosition buffer:(CGFloat)buffer duration:(CGFloat)duration
{
    [self.processSlider updatePosition:curPosition buffer:buffer duration:duration];
    self.curTimeL.text = [self numberToTime:curPosition/1000];
    self.totalTimeL.text = [self numberToTime:duration/1000];
}

- (NSString *)numberToTime:(long)time {
    
    return [NSString stringWithFormat:@"%02d:%02d", (int)time/60, (int)time%60];
}

@end
