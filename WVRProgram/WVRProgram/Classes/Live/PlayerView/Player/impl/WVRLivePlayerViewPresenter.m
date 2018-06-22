//
//  WVRLivePlayerViewPresenter.m
//  WhaleyVR
//
//  Created by qbshen on 2017/2/20.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRLivePlayerViewPresenter.h"
#import "WVRLiveBarrageView.h"
#import "WVRVideoEntity.h"
#import "WVRLivePlayerBottomToolView.h"
#import "WVRUMShareView.h"

#import "WVRRewardController.h"
#import "WVRLotteryModel.h"
#import "WVRLivePlayerTopToolView.h"
#import "WVRRecommendItemModel.h"

#import "WVRGotoNextTool.h"

@interface WVRLivePlayerViewPresenter ()<WVRLivePlayerBTVDelegate>

@property (nonatomic, strong) NSNumber *lotteryTime;         // 秒
@property (nonatomic, strong) NSDate *authTime;
@property (nonatomic, assign) BOOL lotterySwitch;
@property (nonatomic, assign) BOOL danmuSwitch;

@property (nonatomic, weak  ) NSTimer  *timer;

@end


@implementation WVRLivePlayerViewPresenter
//static long syncScrubberNum = 0;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.type = WVRSmallPlayerViewBanner ;
        [self.mTopToolV removeFromSuperview];
        self.mTopToolV = (WVRLivePlayerTopToolView*)VIEW_WITH_NIB(NSStringFromClass([WVRLivePlayerTopToolView class]));
        [self.mTopToolV setClickDelegate:self];
        [(WVRLivePlayerTopToolView*)self.mTopToolV resetWithTitle:@"直播" curWatcherCount:@"1000人"];
        self.mTopToolV.hidden = YES;
        [self addSubview:self.mTopToolV];
        
        [(UIView*)self.mBottomToolV removeFromSuperview];
        self.mBottomToolV = (id<WVRPlayerToolVProtocol>)VIEW_WITH_NIB(NSStringFromClass([WVRLivePlayerBottomToolView class]));
        [(WVRLivePlayerBottomToolView*)self.mBottomToolV setClickDelegate:self];
        [(WVRLivePlayerBottomToolView*)self.mBottomToolV updateSubStatus:WVRPlayerToolVSubStatusBanner];
        [self addSubview:(UIView*)self.mBottomToolV];
        
        self.mLeftToolV.hidden = YES;
        self.mRightToolV.hidden = YES;
//        [self registerKeyNot];
    }
    return self;
}

- (void)didRotaionAnima
{

    switch ([self checkCurViewType]) {
        case WVRSmallPlayerViewFull:
            [(WVRLivePlayerBottomToolView*)self.mBottomToolV updateSubStatus:WVRPlayerToolVSubStatusBanner];
            
            break;
        case WVRSmallPlayerViewBanner:
            [(WVRLivePlayerBottomToolView*)self.mBottomToolV updateSubStatus:WVRPlayerToolVSubStatusFull];
            
            break;
        default:
            break;
    }
    [super didRotaionAnima];
}

- (void)fullBtnOnClick:(UIButton *)fullBtn {
    
    [WVRGotoNextTool gotoNextVC:self.itemModel nav:[UIViewController getCurrentVC].navigationController];
}

@end
