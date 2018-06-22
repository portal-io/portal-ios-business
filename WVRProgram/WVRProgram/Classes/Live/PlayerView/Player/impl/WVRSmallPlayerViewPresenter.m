//
//  WVRSmallPlayerView.m
//  WhaleyVR
//
//  Created by qbshen on 2017/2/15.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRSmallPlayerViewPresenter.h"
#import "WVRGotoNextTool.h"
#import "WVRPlayerStartView.h"
#import "WVRSmallPlayerPresenter.h"
#import "WVRVideoEntity.h"
#import "WVRLiveShowModel.h"

#import "WVRMyReservationController.h"
#import "WVRLiveController.h"
#import "WVRMediaModel.h"
#import "WVRWatchOnlineRecord.h"
#import "WVRDeviceModel.h"
//#import "WVRLoginTool.h"
#import "WVRVideoDetailVCModel.h"
#import "WVRCameraStandTipView.h"

#import "WVRChartletManager.h"

#import "WVRMediator+UnityActions.h"

@interface WVRSmallPlayerViewPresenter ()<UIGestureRecognizerDelegate>{
    
    BOOL _isVipBackground;
}

@property (nonatomic) WVRDataParam * mPlayerDataParam;
@property (nonatomic, strong) WVRVideoEntity *videoEntity;

//@property (nonatomic) UIView * mPlayerContainerV;
@property (nonatomic, weak) WVRPlayerStartView *mStartView;

@property (nonatomic) BOOL isDefinitionHD;

@property (nonatomic) BOOL isStop;

@property (nonatomic) long curPostion;

@property (nonatomic, strong) WVRPlayerHelper * mPlayer;

@property (nonatomic, strong) UIView * mBackV;

@property (nonatomic, strong) WVRLaunchModel *tmpUnityModel;
@property (nonatomic, strong) WVRWatchOnlineRecord * gwOnlineRecord;

@property (nonatomic, assign) long gPlayAbaleDurtion;

@property (nonatomic, assign) BOOL isMonocular;

@property (nonatomic, copy) NSString *currentStandType;

@property (nonatomic, strong) WVRChartletManager *chartletManager;

@end


@implementation WVRSmallPlayerViewPresenter

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _currentStandType = @"Public";
        
        _videoEntity = [[WVRVideoEntity alloc] init];
        
        if (!self.gwOnlineRecord) {
            self.gwOnlineRecord = [WVRWatchOnlineRecord new];
        }
        self.isDefinitionHD = [WVRUserModel sharedInstance].defaultDefinition;
        [self registerObserverEvent];
        self.type = WVRSmallPlayerViewBanner ;
        [self loadBottomToolV];
        [self loadTopToolV];
        [self loadLeftToolV];
        [self loadRightToolV];
        [self setUpNetSpeedTimer];
        [self addSubview:self.mLoadingV];
        [self addTapG];
        
//        [self addSubview:self.mStartView];
//        [self.mStartView dismiss];
    }
    
    [WVRPlayerManager sharedInstance].sPlayer = self;
    return self;
}

+ (instancetype)createPresenter:(id)createArgs {
    
    return nil;
}

- (UIView *)getView {

    return nil;
}

- (void)reloadData {

}

- (void)initWithInfo:(WVRPlayerInfo *)info {
    
}

- (void)updateInfo:(WVRPlayerInfo *)newInfo {

}

- (void)changeWithType:(WVRSmallPlayerViewType)viewType {
    
}

#pragma mark - Notification

- (void)registerObserverEvent {      // 界面"暂停／激活"事件注册
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkStatusChanged:)
                                                 name:kNetStatusChagedNoti
                                               object:nil];
}

- (void)networkStatusChanged:(NSNotification *)notification {
//    if ([WVRReachabilityModel sharedInstance].isWifi) {
//        if (self.isStop) {
//            [self didStart];
//        } else {
//            self.mPlayerDataParam.position = [self.mPlayer getCurrentPosition];
//            [self restart];
//        }
//    } else {
//        if (self.mPlayer.isPlaying) {
//            self.mPlayerDataParam.position = [self.mPlayer getCurrentPosition];
////            [UIAlertController alertMesasge:@"非wifi网络，已为你暂定播放" confirmHandler:^(UIAlertAction *action) {
////                
////            } viewController:self.controller];
//            [self stop];
//        } else {
//            
//        }
//    }
}

- (void)appWillEnterBackground:(NSNotification *)notification {
    
//    [self.shareView removeFromSuperview];
}

- (void)appWillResignActive:(NSNotification *)notification {
    
    // 保护
    if (![self.curViewController isCurrentViewControllerVisible] || !self.mPlayer.isValid) { return; }
    
    [self stopPlayingStatus];
}

- (void)appDidBecomeActive:(NSNotification *)notification {
    
    // 保护
    if (![self.curViewController isCurrentViewControllerVisible] || !self.mPlayer.isValid) { return; }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.mPlayer isPlaying]) {
            
            [self startPlayingStatus];
        }
    });
}

#pragma mark - init

- (void)loadBottomToolV {
    
    if (!self.mSmallPlayerToolV) {
        self.mSmallPlayerToolV = (WVRSmallPlayerBottomToolView *)VIEW_WITH_NIB(NSStringFromClass([WVRSmallPlayerBottomToolView class]));
        self.mSmallPlayerToolV.clickDelegate = self;
        self.mSmallPlayerToolV.processSlider.realDelegate = self;
        [self.mSmallPlayerToolV updateStatus:WVRPlayerToolVStatusDefault];
        [self addSubview:self.mSmallPlayerToolV];
    }
    if (!self.mFullSPlayToolV) {
        self.mFullSPlayToolV = (WVRFullSPlayerBottomToolView *)VIEW_WITH_NIB(NSStringFromClass([WVRFullSPlayerBottomToolView class]));
        self.mFullSPlayToolV.clickDelegate = self;
        self.mFullSPlayToolV.processSlider.realDelegate = self;
        self.mFullSPlayToolV.hidden = YES;
        [self.mFullSPlayToolV updateStatus:WVRPlayerToolVStatusDefault];
        [self addSubview:self.mFullSPlayToolV];
    }
    
    self.mBottomToolV = self.mSmallPlayerToolV;
}

- (void)loadTopToolV {
    
    if (!self.mTopToolV) {
        self.mTopToolV = (WVRPlayerTopToolView*)VIEW_WITH_NIB(NSStringFromClass([WVRPlayerTopToolView class]));
        self.mTopToolV.clickDelegate = self;
        [self addSubview:self.mTopToolV];
        self.mTopToolV.hidden = YES;
    }
}

- (void)loadLeftToolV {
    
    if (!self.mLeftToolV) {
        self.mLeftToolV = (WVRPlayerLeftToolView *)VIEW_WITH_NIB(NSStringFromClass([WVRPlayerLeftToolView class]));
        self.mLeftToolV.clickDelegate = self;
        [self addSubview:self.mLeftToolV];
        self.mLeftToolV.hidden = YES;
    }
}

- (void)loadRightToolV {
    
    if (!self.mRightToolV) {
        self.mRightToolV = (WVRPlayerRightToolView*)VIEW_WITH_NIB(NSStringFromClass([WVRPlayerRightToolView class]));
        self.mRightToolV.clickDelegate = self;
        [self addSubview:self.mRightToolV];
        self.mRightToolV.hidden = YES;
    }
}

- (WVRPlayerLoadingView *)mLoadingV {
    
    if (!_mLoadingV) {
        WVRPlayerLoadingView *loading = [[WVRPlayerLoadingView alloc] initWithContentView:self isVRMode:NO];
        
        _mLoadingV = loading;
    }
    return _mLoadingV;
}

- (void)updatePlayTool:(WVRPlayerToolVStatus)status {
    
    [self.mBottomToolV updateStatus:status];

}

- (void)layoutSubviews {
    
//    self.mPlayerContainerV.frame = self.bounds;
    CGFloat bottomToolVHeight = [self.mBottomToolV getViewSize].height;
    CGRect frame = CGRectMake(0, self.height-[self.mBottomToolV getViewSize].height, self.width, bottomToolVHeight);
    [self.mBottomToolV updateFrame:frame];
    self.mLoadingV.center = CGPointMake(self.center.x, self.center.y);
    self.mTopToolV.frame = self.bounds;
    self.mTopToolV.height = [self.mTopToolV getViewSize].height;;
    self.mLeftToolV.frame = self.bounds;
    self.mLeftToolV.y = HEIGHT_DEFAULT;
    self.mLeftToolV.height -= HEIGHT_DEFAULT*2;
    self.mLeftToolV.width = HEIGHT_DEFAULT;
    self.mRightToolV.frame = self.bounds;
    self.mRightToolV.y = HEIGHT_DEFAULT;
    self.mRightToolV.height -= HEIGHT_DEFAULT*2;
    self.mRightToolV.x = self.width-HEIGHT_DEFAULT;
    self.mRightToolV.width = HEIGHT_DEFAULT;
}

- (WVRChartletManager *)chartletManager {
    if (!_chartletManager) {
        _chartletManager = [[WVRChartletManager alloc] init];
    }
    return _chartletManager;
}

#pragma mark - action

- (void)screenRotation {
    
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    
    [UIView animateWithDuration:duration animations:^{
        
        [self rotaionAnimations];
    } completion:^(BOOL finished) {
        [self rotaionAnimatCompletion];
//        if (self.isMonocular) {
        self.isMonocular = NO;
        [self.mPlayer setMonocular:YES];
//        }
    }];
}

- (void)screenRotationWithCompletBlock:(void(^)())completBlock {
    
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    
    [UIView animateWithDuration:duration animations:^{
        
        [self rotaionAnimations];
    } completion:^(BOOL finished) {
        [self rotaionAnimatCompletion];
        if (completBlock) {
            completBlock();
        }
    }];
}

- (void)saveOriginFrame {
    
    if (self.mOriginFrame.size.width==0) {
        self.mOriginFrame = self.frame;
    }
    if ([NSStringFromClass([self.superview class]) isEqualToString:@"UIImageView"]) {
        self.mParentV = self.superview;
//        [self.mParentV addSubview:self.mPlayerContainerV];
    }
}

- (WVRSmallPlayerViewType)checkCurViewType {
    
    BOOL isRight = [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait;
    return isRight? WVRSmallPlayerViewBanner:WVRSmallPlayerViewFull;
}

- (void)changeViewFrameForBanner {
    
//    self.controller.view.bounds = CGRectMake(0, 0, self.controller.view.bounds.size.height, self.controller.view.bounds.size.width);
    [self.mSmallPlayerToolV updateQuality:[self.mBottomToolV getQuality]];
    self.mBottomToolV = self.mSmallPlayerToolV;
//    [WVRAppModel changeStatusBarOrientation:UIInterfaceOrientationPortrait];
//    self.controller.view.transform = CGAffineTransformIdentity;
    [(WVRBaseViewController *)self.curViewController setGShouldAutorotate:YES];
    [(WVRBaseViewController *)self.curViewController setGSupportedInterfaceO:UIInterfaceOrientationMaskPortrait];
    [WVRAppModel forceToOrientation:UIInterfaceOrientationPortrait];
    [(WVRBaseViewController *)self.curViewController setGShouldAutorotate:NO];
    
    self.type = WVRSmallPlayerViewBanner;
}

- (void)changeViewFrameForFull {
    
//    self.controller.view.bounds = CGRectMake(0, 0, self.controller.view.bounds.size.height, self.controller.view.bounds.size.width);
    [self.mFullSPlayToolV updateQuality:[self.mBottomToolV getQuality]];
    self.mBottomToolV = self.mFullSPlayToolV;
    ;
//    [WVRAppModel changeStatusBarOrientation: UIInterfaceOrientationLandscapeRight];
//    self.controller.view.transform = CGAffineTransformMakeRotation(M_PI_2);
    [(WVRBaseViewController *)self.curViewController setGShouldAutorotate:YES];
    [(WVRBaseViewController *)self.curViewController setGSupportedInterfaceO:UIInterfaceOrientationMaskLandscapeRight];
    [WVRAppModel forceToOrientation:UIInterfaceOrientationLandscapeRight];
    
    [(WVRBaseViewController *)self.curViewController setGShouldAutorotate:NO];
    
    self.type = WVRSmallPlayerViewFull;
}

- (void)didRotaionAnima {
    
    [self.mBottomToolV hiddenV:YES];
    switch ([self checkCurViewType]) {
         case WVRSmallPlayerViewFull:
            [self changeViewFrameForBanner];
            
            self.frame = self.mOriginFrame;
            [self.mBottomToolV hiddenV:NO];
            [self.mParentV addSubview:self];
            [self addPlayerViewCont:self inSec:self.mParentV];
            [self stopPerformWithHiddenV:NO];
            [self.mTopToolV hiddenV:YES];
            [self.mLeftToolV hiddenV:YES];
            [self.mRightToolV hiddenV:YES];
            self.curViewController.tabBarController.tabBar.hidden = NO;
            self.type = WVRSmallPlayerViewBanner;
            break;
        case WVRSmallPlayerViewBanner:
            [self changeViewFrameForFull];
            
            self.frame = self.curViewController.view.bounds;
            [self.mBottomToolV hiddenV:NO];
            [self.curViewController.view addSubview:self];
            [self addPlayerViewCont:self inSec:self.curViewController.view];
            [self startPerformWithHiddenV:NO];
            self.curViewController.tabBarController.tabBar.hidden = YES;
            self.type = WVRSmallPlayerViewFull;
            break;
        default:
            break;
    }
    if ([self.curViewController respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        
        [self.curViewController prefersStatusBarHidden];
        [self.curViewController performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}

-(UIViewController*)curViewController {
    
    return [UIViewController getCurrentVC];
}

- (void)rotaionAnimations {
    
    [self saveOriginFrame];
    
    WVRPlayerToolVStatus curStatus = [self.mBottomToolV getStatus];
    [self didRotaionAnima];
    [self.mBottomToolV updateStatus:curStatus];
    if ([self.mBottomToolV respondsToSelector:@selector(updateQualityWithTitle:)]) {
        [self.mBottomToolV updateQualityWithTitle:self.mCurMediaModel.resolution];
    }
}

- (void)addPlayerViewCont:(UIView *)firstsView inSec:(UIView *)secondView {
    
    //view_1(红色)top 距离self.view的top
    NSLayoutConstraint *view_1TopToSuperViewTop = [NSLayoutConstraint constraintWithItem:firstsView
                                                                               attribute:NSLayoutAttributeTop
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:secondView
                                                                               attribute:NSLayoutAttributeTop
                                                                              multiplier:1
                                                                                constant:0];
    //view_3(蓝色)left 距离 self.view left
    NSLayoutConstraint *view_3LeftToSuperViewLeft = [NSLayoutConstraint constraintWithItem:firstsView
                                                                                 attribute:NSLayoutAttributeLeft
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:secondView
                                                                                 attribute:NSLayoutAttributeLeft
                                                                                multiplier:1
                                                                                  constant:0];
    
    //view_3(蓝色)right 距离 self.view right
    NSLayoutConstraint *view_3RightToSuperViewRight = [NSLayoutConstraint constraintWithItem:firstsView
                                                                                   attribute:NSLayoutAttributeRight
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:secondView
                                                                                   attribute:NSLayoutAttributeRight
                                                                                  multiplier:1
                                                                                    constant:0];
    
    //    NSLayoutConstraint * heightCons = [NSLayoutConstraint constraintWithItem:firstsView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:50];
    //    [firstsView addConstraints:@[heightCons]];
    //    [firstsView layoutIfNeeded];
    //    //view_3(蓝色)Bottom 距离 self.view bottom
    NSLayoutConstraint *view_3BottomToSuperViewBottom = [NSLayoutConstraint constraintWithItem:firstsView
                                                                                     attribute:NSLayoutAttributeBottom
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:secondView
                                                                                     attribute:NSLayoutAttributeBottom
                                                                                    multiplier:1
                                                                                      constant:0];
    //添加约束，因为view_1、2、3是同层次关系，且他们公有的父视图都是self.view，所以这里把约束都添加到self.view上即可
    [secondView addConstraints:@[view_1TopToSuperViewTop,view_3LeftToSuperViewLeft,view_3RightToSuperViewRight,view_3BottomToSuperViewBottom]];
    
    [secondView layoutIfNeeded];
}


- (void)addTapG {
    
    self.mTapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateToolVHiden)];
    self.mTapG.delegate = self;
    [self addGestureRecognizer:self.mTapG];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([touch.view isKindOfClass:[UISlider class]] || [touch.view isKindOfClass:[WVRFullSPlayerBottomToolView class]]) {
        
        return NO;
        
    } else {
        return YES;
    }
}

- (void)removeTapG {
    
    [self removeGestureRecognizer:self.mTapG];
}

- (void)updateToolVHiden {
    
    if (self.isClockScreen) {
        switch (self.mLeftToolV.isHiddenV) {
            case YES:
                [self startPerformWithHiddenV:YES];
                switch (self.type) {
                    case WVRSmallPlayerViewBanner:
                        [self.mLeftToolV hiddenV:YES];
                        break;
                    case WVRSmallPlayerViewFull:
                        [self.mLeftToolV hiddenV:NO];
                        break;
                    default:
                        break;
                }
                
                break;
            case NO:
                [self stopPerformWithHiddenV:YES];
                [self.mLeftToolV hiddenV:YES];
                break;
            default:
                break;
        }
        
    } else {
        switch ([self.mBottomToolV isHiddenV]) {
            case YES:
                [self startPerformWithHiddenV:NO];
                break;
            case NO:
                [self stopPerformWithHiddenV:YES];
                break;
                
            default:
                break;
        }
    }
}

- (void)curpagePerform {
    
    [self stopPerformWithHiddenV:YES];
}

- (void)stopPerformWithHiddenV:(BOOL)hidden {
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self];//可以成功取消全部。
    switch (self.type) {
        case WVRSmallPlayerViewBanner:
            [self.mBottomToolV hiddenV:hidden];
            [self.mTopToolV hiddenV:YES];
            [self.mLeftToolV hiddenV:YES];
            [self.mRightToolV hiddenV:YES];
            break;
        case WVRSmallPlayerViewFull:
            [self.mBottomToolV hiddenV:hidden];
            [self.mTopToolV hiddenV:hidden];
            [self.mLeftToolV hiddenV:hidden];
            [self.mRightToolV hiddenV:hidden];
            break;
        default:
            break;
    }
    
}

- (void)stopPerformWithHiddenVForSliding:(BOOL)hidden {
    
    switch (self.type) {
        case WVRSmallPlayerViewBanner:
            [[self class] cancelPreviousPerformRequestsWithTarget:self];//可以成功取消全部。
            [self.mBottomToolV hiddenV:hidden];
            [self.mTopToolV hiddenV:!hidden];
            [self.mLeftToolV hiddenV:!hidden];
            [self.mRightToolV hiddenV:!hidden];
            break;
        case WVRSmallPlayerViewFull:
            [self stopPerformWithHiddenV:NO];
            break;
        default:
            break;
    }
}

- (void)startPerformWithHiddenV:(BOOL)hidden {
    
    [self performSelector:@selector(curpagePerform) withObject:nil afterDelay:5];
    switch (self.type) {
        case WVRSmallPlayerViewBanner:
            [self.mBottomToolV hiddenV:hidden];
            [self.mTopToolV hiddenV:YES];
            [self.mLeftToolV hiddenV:YES];
            [self.mRightToolV hiddenV:YES];
            break;
        case WVRSmallPlayerViewFull:
            [self.mBottomToolV hiddenV:hidden];
            [self.mTopToolV hiddenV:hidden];
            [self.mLeftToolV hiddenV:hidden];
            [self.mRightToolV hiddenV:hidden];
            break;
        default:
            break;
    }
}

- (void)startPerformWithHiddenVForPerpare:(BOOL)hidden {
    

    switch (self.type) {
        case WVRSmallPlayerViewBanner:
            [[self class] cancelPreviousPerformRequestsWithTarget:self];//可以成功取消全部。
            [self.mBottomToolV hiddenV:hidden];
            [self.mTopToolV hiddenV:!hidden];
            [self.mLeftToolV hiddenV:!hidden];
            [self.mRightToolV hiddenV:!hidden];
            break;
        case WVRSmallPlayerViewFull:
            [self startPerformWithHiddenV:NO];
            self.isClockScreen = NO;
            [self.mLeftToolV updateClockStatus:NO];
            break;
        default:
            break;
    }
}

- (void)rotaionAnimatCompletion {
    
    switch (self.type) {
        case WVRSmallPlayerViewBanner:
            
            break;
        case WVRSmallPlayerViewFull:
            
            [self performSelector:@selector(shouldShowCameraTipView) withObject:nil afterDelay:0.2];
            break;
            
        default:
            break;
    }
    [self updateSlider];
}

- (void)shouldShowCameraTipView {
    
    if (_isFootball && ![WVRAppModel sharedInstance].footballCameraTipIsShow) {
//        [self toggleControls];
        CGPoint point = [self.mFullSPlayToolV cameraPoint];
        WVRCameraStandTipView *view = [[WVRCameraStandTipView alloc] initWithX:point.x y:(self.height - point.y)];
        [self addSubview:view];
//        _cameraStandTipView = view;
        [WVRAppModel sharedInstance].footballCameraTipIsShow = YES;
    }
}

- (void)setUpTimer {
    
    if (!self.mToolUpdateTimer) {
        self.mToolUpdateTimer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.mToolUpdateTimer forMode:NSDefaultRunLoopMode];
    }
}

- (void)invalidTimer {
    
    [self.mToolUpdateTimer invalidate];
    self.mToolUpdateTimer = nil;
}

- (void)setUpNetSpeedTimer {
    
    if (!self.mNetSpeedUpdateTimer) {
        self.mNetSpeedUpdateTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updateNetSpeed) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.mNetSpeedUpdateTimer forMode:NSDefaultRunLoopMode];
    }
}

- (void)invalidNetSpeedTimer {
    
    [self.mNetSpeedUpdateTimer invalidate];
    self.mNetSpeedUpdateTimer = nil;
}

- (void)updateNetSpeed {
    
    long speed = [[WVRAppModel sharedInstance] checkInNetworkflow];
    [self.mLoadingV updateNetSpeed:speed];
}


- (void)updateSlider {
    
    if (![WVRSmallPlayerPresenter shareInstance].canPlay) {
        [self destroy];
        return;
    }
    if (self.mPlayer.isComplete) {
        long curPosition = 0;
        long bufferPosition = 0;
        long duration = [self.mPlayer getDuration];
        [self.mBottomToolV updatePosition:curPosition buffer:bufferPosition duration:duration];
    } else if ([self.mPlayer isPrepared]) {
        long curPosition = [self.mPlayer getCurrentPosition];
        
        if (self.gPlayAbaleDurtion <= 0) {
            self.gPlayAbaleDurtion = 0;
        }
        long bufferPosition = self.gPlayAbaleDurtion;
        if (bufferPosition > 0) {
            
        }else{
            bufferPosition = [self.mPlayer getPlayableDuration];
        }
        long duration = [self.mPlayer getDuration];
        [self.mBottomToolV updatePosition:curPosition buffer:bufferPosition duration:duration];
    }
}

- (void)prepare {
    
    self.mTopToolV.titleL.text = self.itemModel.srcDisplayName;
    [self createPlayerParamData];
    [self createPlayer];
}

- (void)createPlayerParamData {
    
    if (!self.mPlayerDataParam) {
        
        if (self.isFootball) {
            
            for (WVRMediaModel * cur in self.itemModel.palyMediaModels) {
                if ([cur.resolution isEqualToString:@"Public"]) {
                    self.mCurMediaModel = cur;
                    break;
                }
            }
            
        } else {
            
            NSString * defiStr = @"";
            if ([WVRUserModel sharedInstance].defaultDefinition == 0) {
                defiStr = @"高清";
            } else if ([WVRUserModel sharedInstance].defaultDefinition == 1) {
                defiStr = @"超清";
            }
            for (WVRMediaModel * cur in self.itemModel.palyMediaModels) {
                if ([cur.resolution isEqualToString:defiStr]) {
                    self.mCurMediaModel = cur;
                    break;
                }
            }
        }
        if (!self.mCurMediaModel) {
            self.mCurMediaModel = [self.itemModel.palyMediaModels firstObject];
        }
        self.mPlayerDataParam = [[WVRDataParam alloc] initWithPath:[NSURL URLWithString:self.mCurMediaModel.playUrl] Position:0 UseHardDecoder:YES RenderType:self.mCurMediaModel.renderTyper IsMonocular:YES IsLooping:NO];
        if ([self.mBottomToolV respondsToSelector:@selector(updateQualityWithTitle:)]) {
            [self.mBottomToolV updateQualityWithTitle:self.mCurMediaModel.resolution];
        }
    }
}

- (void)createPlayer {
    
    if (!self.mPlayer) {
        kWeakSelf(self);
        self.mPlayer = [[WVRPlayerHelper alloc] initWithContainerView:weakself MainController:self.curViewController];
        self.mPlayer.playerDelegate = weakself;
        self.mPlayer.biModel.screenType = 3;
    }
}

- (void)restart {
    
    self.mPlayer.ve = self.videoEntity;
    if (self.mPlayerDataParam)
        [self.mPlayer setParamAndPlay:self.mPlayerDataParam];
}

- (BOOL)checkNetCanPlayType {
    
    kWeakSelf(self);
    if ([WVRReachabilityModel sharedInstance].isReachNet) {
        [UIAlertController alertTitle:kReachAlert mesasge:@"" preferredStyle:UIAlertControllerStyleAlert confirmHandler:^(UIAlertAction *action) {
            [weakself didStart];
        } cancleHandler:^(UIAlertAction *action) {
            [weakself updatePlayTool:WVRPlayerToolVStatusPause];
        }
        viewController:self.curViewController];
        return NO;
    } else {
        return YES;
    }
}

- (void)start {
    
    if ([self checkNetCanPlayType]) {
        [self didStart];
    }
}

- (void)didStart {
    
    if (!self.mPlayer.isPlaying) {
        if (self.mPlayer.isComplete || self.mPlayer.isPlayError) {
            
            self.mPlayer.ve = self.videoEntity;
            if(self.mPlayerDataParam)
                [self.mPlayer setParamAndPlay:self.mPlayerDataParam];
        } else {
            [self.mPlayer start];
        }
    } else {
        DebugLog(@"player is playing ...");
    }
    [self startPlayingStatus];
    self.isStop = NO;
}

- (void)startPlayingStatus {
    
    [self setUpTimer];
    [self.mLoadingV stopAnimating];
    [self.mBottomToolV updateStatus:WVRPlayerToolVStatusPlaying];
}

- (void)stopPlayingStatus {
    
    [self invalidTimer];
    [self.mLoadingV stopAnimating];
    [self.mBottomToolV updateStatus:WVRPlayerToolVStatusPause];
}

- (void)completePlayingStatus {
    
    [self invalidTimer];
    [self.mLoadingV stopAnimating];
    [self.mBottomToolV updateStatus:WVRPlayerToolVStatusPause];
    BOOL netOK = [WVRReachabilityModel isNetWorkOK];
    if (!netOK) {
        
        return;
    }
    long curPosition = 0;
    long bufferPosition = 0;
    long duration = [self.mPlayer getDuration];
    [self.mBottomToolV updatePosition:curPosition buffer:bufferPosition duration:duration];
}

#pragma mark - setter

- (void)setIsFootball:(BOOL)isFootball {
    _isFootball = isFootball;
    
    [self.mFullSPlayToolV setIsFootball:isFootball];
}

#pragma mark - getter

- (WVRVideoEntity *)videoEntity {
    
    _videoEntity.sid = _detailBaseModel.sid;
    _videoEntity.videoTitle = _detailBaseModel.name;
    _videoEntity.biEntity.videoTag = _detailBaseModel.tags;
    
    if (self.detailBaseModel.linkType_ == WVRLinkTypeLive) {
        _videoEntity.streamType = STREAM_VR_LIVE;
    } else {
        _videoEntity.streamType = STREAM_VR_VOD;
    }
    
    return _videoEntity;
}

#pragma mark - delegate

- (void)onPause {
    
    [self.mPlayer onPause];
    [self stopPlayingStatus];
}

- (void)onResume {
    
    if ([self.mPlayer onResume]) {
        [self startPlayingStatus];
    }
}

- (void)stop {
    
    if ([self isPlaying]) {
        [self.mPlayer stop];
        [self stopPlayingStatus];
        self.isStop = YES;
    }
//    NSLog(@"mCurPlayerStatus:%d", self.mCurPlayerStatus);
}

- (BOOL)isPlaying {
    
    return self.mPlayer.isPlaying;
}

- (BOOL)isPaused {
    
    return !self.mPlayer.isPaused;
}
- (void)seekTo:(long)time {
    
    [self.mPlayer seekTo:time];
}

- (void)destroy {
    [self watch_online_record:NO];
    if ([WVRSmallPlayerPresenter shareInstance].isLaunch) {
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self invalidTimer];
    [self invalidNetSpeedTimer];
    [self.mPlayer onBackForDestroy];
    self.gPlayAbaleDurtion = 0;
    self.mPlayer = nil;
    self.mPlayerDataParam = nil;
    if (_mStartView) {
        [_mStartView dismiss];
    }
    self.alpha = 0;
    for (UIView * view in [self subviews]) {
        [view removeFromSuperview];
    }
    [self removeFromSuperview];
    
    [[WVRSmallPlayerPresenter shareInstance] setPrepared:NO];
}

- (void)destroyForUnityBtnClick {
    
    if ([WVRSmallPlayerPresenter shareInstance].isLaunch) {
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self invalidTimer];
    [self invalidNetSpeedTimer];
    [self.mPlayer destroyForUnity];
    
    self.mPlayerDataParam = nil;
    if (_mStartView) {
        [_mStartView dismiss];
    }
    for (UIView * view in [self subviews]) {
        [view removeFromSuperview];
    }
    [self removeFromSuperview];
    [[WVRSmallPlayerPresenter shareInstance] setPrepared:NO];
}

- (void)destroyForLauncher {
    
    self.curPostion = [self.mPlayer getCurrentPosition];
    [self stopPlayingStatus];
    self.isStop = YES;
    [self stopPerformWithHiddenVForSliding:NO];
    [self.mBottomToolV updateStatus:WVRPlayerToolVStatusPrepare];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self invalidTimer];
    
    [self.mPlayer destroyForUnity];
    
//    self.mPlayerDataParam = nil;
    if (!self.mBackV) {
        self.mBackV = [[UIView alloc] initWithFrame:self.bounds];
        self.mBackV.backgroundColor= [UIColor blackColor];
    }
    [self.curViewController.view addSubview:self.mBackV];
    [self removeFromSuperview];
//    self.backgroundColor = [UIColor blackColor];
    for (UIView * subV in self.subviews) {
        if ([subV isKindOfClass:[GLKView class]]) {
            [subV removeFromSuperview];
        }
    }
    [[WVRSmallPlayerPresenter shareInstance] setPrepared:NO];
}

- (void)restartForLaunch {
    
    [self.mBackV removeFromSuperview];
    [self registerObserverEvent];
//    [WVRAppModel changeStatusBarOrientation: UIInterfaceOrientationLandscapeRight];
//    [(WVRLiveController *)self.controller setHidenStatusBar:YES];
    if ([self.curViewController respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        
        [self.curViewController prefersStatusBarHidden];
        [self.curViewController performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
//    [(WVRLiveController *)self.controller setHidenStatusBar:NO];
    self.frame = self.curViewController.view.bounds;
    [self.mBottomToolV hiddenV:NO];
    [self.curViewController.view addSubview:self];
    [self addPlayerViewCont:self inSec:self.curViewController.view];
    [self startPerformWithHiddenV:NO];

    [self createPlayer];
    self.mPlayerDataParam.position = self.curPostion;
    self.mPlayer.ve = self.videoEntity;
    if(self.mPlayerDataParam)
        [self.mPlayer setParamAndPlay:self.mPlayerDataParam];
    [self setUpTimer];
    [self.mLoadingV startAnimating:NO];
    [self.mBottomToolV updateStatus:WVRPlayerToolVStatusPause];
    self.isStop = NO;
    self.curViewController.tabBarController.tabBar.hidden = YES;
}

#pragma mark - VRPlayerDelegate
- (void)restartUI {
    
    self.mPlayerDataParam.position = [self.mPlayer getCurrentPosition];
    [self restart];
    [self.mLoadingV startAnimating:NO];
}

- (void)onVideoPrepared {
    DebugLog(@"");
    [self.mLoadingV stopAnimating];
    if ([WVRSmallPlayerPresenter shareInstance].canPlay) {
//        [self.mParentV bringSubviewToFront:self];
        self.alpha = 1;
//        if ([self.mBottomToolV getStatus] == WVRPlayerToolVStatusChangeQuality) {
//            [self.mBottomToolV updateQuality:[self.mBottomToolV getWillToQuality]];
//        }
        [self updatePlayTool:WVRPlayerToolVStatusPlaying];
        [self startPerformWithHiddenVForPerpare :NO];
        if (self.mStartView) {
            [self.mStartView dismiss];
        }
        [[WVRSmallPlayerPresenter shareInstance] setPrepared:YES];
        if ([[WVRSmallPlayerPresenter shareInstance] shouldPause]) {
            NSLog(@"shouldpause to stop");
            [self stop];
        } else {
            NSLog(@"not shouldpause to start");
            [self performSelector:@selector(start) withObject:nil afterDelay:0.5];
        }
        [self createPlayerBottomImage];
        
//        if (self.type == WVRSmallPlayerViewFull) {
//            
//            [self.mFullSPlayToolV shouldShowCameraTipView];
//        }
    } else {
        [self destroy];
    }
    [self watch_online_record:YES];
}

- (void)onCompletion {
    DebugLog(@"banner");
    [self completePlayingStatus];
    [self watch_online_record:NO];
}

- (void)onError:(int)what {
    DebugLog(@"banner");
    [self invalidTimer];
    [self.mLoadingV stopAnimating];
    [self.mBottomToolV updateStatus:WVRPlayerToolVStatusPause];
    
//    NSString *err = [NSString stringWithFormat:@"%d", what];
    
//    if (self.type == WVRSmallPlayerViewBanner) {
//        
//        [self destroy];
//    } else {
        BOOL netOK = [WVRReachabilityModel isNetWorkOK];
        if (!netOK) {
            
            return;
        }
        if (![WVRReachabilityModel isNetWorkOK]) {
            [self showErrorView:@"网络异常" code:-1000];
        } else {
            [self showErrorView:@"请重试" code:-2000];
        }
        [self.mBottomToolV updateStatus:WVRPlayerToolVStatusError];
//    }
}

- (void)watch_online_record:(BOOL)isComin {
    
    NSString * contentType = @"live";
    switch (self.detailBaseModel.linkType_) {
        case WVRLinkTypeLive:
            
            break;
            
        default:
            contentType = @"recorded";
            break;
    }
    WVRWatchOnlineRecordModel * recordModel = [WVRWatchOnlineRecordModel new];
    recordModel.code = self.videoEntity.sid;
    recordModel.contentType = contentType;
    recordModel.type = [NSString stringWithFormat:@"%d", isComin];
    recordModel.deviceNo = [WVRUserModel sharedInstance].deviceId;
    if (isComin) {
        [self.gwOnlineRecord http_watch_online_record:recordModel];
    } else {
        [self.gwOnlineRecord http_watch_online_unrecord:recordModel];
    }
}


- (void)showErrorView:(NSString *)errMsg code:(NSInteger)code {
    
    [self.mStartView onErrorWithMsg:errMsg code:code];
    [self.mPlayer playError:errMsg code:(int)code videoEntity:self.videoEntity];
}

- (WVRPlayerStartView *)mStartView {
    
    if (!_mStartView) {
        
        WVRPlayerStartView *startView = [[WVRPlayerStartView alloc] initWithFrame:self.bounds titleText:self.detailBaseModel.name containerView:self];
        kWeakSelf(self);
        startView.retryBtnBlock = ^{
            [weakself.mStartView dismiss];
            weakself.mPlayerDataParam.position = [weakself.mPlayer getCurrentPosition];
            [weakself restart];
        };
        [self addPlayerViewCont:startView inSec:self];
        _mStartView = startView;
    }
    return _mStartView;
}

- (void)backBtnClick:(UIButton *)sender {
    
    sender.hidden = YES;
    [self backOnClick:sender];
}

- (void)onBuffering {
    
    [self.mLoadingV startAnimating:NO];
}

- (void)onBufferingOff {
    
    [self.mLoadingV stopAnimating];
    [self startPlayingStatus];
    [self startPerformWithHiddenVForPerpare:NO];
}

- (void)onGLKVCdealloc {
    
    [WVRGotoNextTool gotoNextVC:_tmpUnityModel nav:self.curViewController.navigationController];
}

#pragma mark - WVRSmallPlayerTVDelegate

- (void)actionChangeCameraStand:(NSString *)standType {
    
    if ([self.videoEntity.currentStandType isEqualToString:standType]) { return; }
    
    self.videoEntity.currentStandType = standType;
    
    WVRVideoDetailVCModel *detailModel = (WVRVideoDetailVCModel *)self.detailBaseModel;
    NSArray *mediaDtos = detailModel.mediaDtos;
    
    if ([self.detailBaseModel isKindOfClass:[WVRSQLiveItemModel class]]) {
        WVRSQLiveItemModel *liveModel = (WVRSQLiveItemModel *)self.detailBaseModel;
        mediaDtos = liveModel.mediaDtos;
    }
    
    WVRMediaDto *selectDto = nil;
    for (WVRMediaDto *dto in mediaDtos) {
        
        if ([standType isEqualToString:dto.source]) {
            
            selectDto = dto;
            break;
        }
    }
    
    if (!selectDto) { return; }
    
    if ([standType isEqualToString:@"Public"]) {
        
        self.mPlayer.dataParam.renderType = [WVRVideoEntity renderTypeForRenderTypeStr:selectDto.renderType];
        [self.mPlayer setBottomViewHidden:NO];
//        [self setIsCameraStandVIP:NO];
        
    } else {
        
        self.mPlayer.dataParam.renderType = MODE_HALF_SPHERE_VIP;
        [self.mPlayer setBottomViewHidden:YES];
//        [self setIsCameraStandVIP:YES];
    }
    self.mPlayer.dataParam.url = [NSURL URLWithUTF8String:selectDto.playUrl];
    
    [self.mFullSPlayToolV updateQualityWithTitle:[WVRVideoEntity definitionToTitle:selectDto.curDefinition]];
    
    if (![self.detailBaseModel isKindOfClass:[WVRSQLiveItemModel class]]) {
        self.mPlayer.dataParam.position = [self.mPlayer getCurrentPosition];
    }
    
    [[self mPlayer] setParamAndPlay:self.mPlayer.dataParam];
    [[self mLoadingV] startAnimating:NO];
}

- (NSArray<NSDictionary *> *)actionGetCameraStandList {
    
    BOOL isLive = [self.detailBaseModel isKindOfClass:[WVRSQLiveItemModel class]];
    BOOL isRecorded = [self.detailBaseModel isKindOfClass:[WVRVideoDetailVCModel class]];
    
    if (!isLive && !isRecorded) {
        
        return nil;
    }
    // 只要上面条件符合就会到下面来
    
    NSArray *mediaDtos = self.detailBaseModel.mediaDtos;
    
    if (mediaDtos.count < 1) {
        return nil;
    }

    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:8];
    
    for (WVRMediaDto *dto in mediaDtos) {
        BOOL isSelected = [self.videoEntity.currentStandType isEqualToString:dto.source];
        NSString *standType = dto.source;
        
        if (standType.length > 0) {
            NSDictionary *typeDict = @{ standType : @(isSelected) };
            [arr addObject:typeDict];
        }
    }
    
    return arr;
}

- (void)playBtnOnClick:(UIButton *)playBtn {
    
    if (!self.mPlayer.isPlaying) {
        [self start];
    } else {
        [self stop];
    }
}

- (void)fullBtnOnClick:(UIButton *)fullBtn{
    
    [self screenRotation];
}

- (void)chooseQuality {
    
    NSInteger curIndex = [self.itemModel.palyMediaModels indexOfObject:self.mCurMediaModel];
    if (curIndex < self.itemModel.palyMediaModels.count - 1) {
        self.mCurMediaModel = self.itemModel.palyMediaModels[curIndex + 1];
        [self chooseNextQuality];
        
//        if ([self.mBottomToolV getStatus] == WVRPlayerToolVStatusChangeQuality) {
//            [self.mBottomToolV updateQuality:[self.mBottomToolV getWillToQuality]];
//        }
    } else if(curIndex == self.itemModel.palyMediaModels.count-1 && curIndex > 0){
        self.mCurMediaModel = self.itemModel.palyMediaModels[0];
        [self chooseNextQuality];
    } else {
    
    }
}

- (void)chooseNextQuality {
    
    [self.mBottomToolV updateStatus:WVRPlayerToolVStatusChangeQuality];
    [self.mLoadingV startAnimating:NO];
    [self stopPerformWithHiddenV:NO];
    [self.mBottomToolV updateQualityWithTitle:self.mCurMediaModel.resolution];
    [self restartForChangeResloution];
}

- (void)restartForChangeResloution {
    
    self.mPlayerDataParam.url = [NSURL URLWithString:self.mCurMediaModel.playUrl];
    self.mPlayerDataParam.renderType = self.mCurMediaModel.renderTyper;
    self.mPlayerDataParam.position = [self.mPlayer getCurrentPosition];
    [self restart];
}

- (BOOL)actionSwitchVR:(BOOL)isMonocular {
    self.isMonocular = !self.isMonocular;
    WVRRenderType type = [self.mPlayer getRenderType];
    BOOL is3D_OCT = (type == MODE_OCTAHEDRON_HALF_LR || type == MODE_OCTAHEDRON_STEREO_LR);
    BOOL not4kSupport = ![WVRDeviceModel is4KSupport];
    
    if (not4kSupport && is3D_OCT) {
        if (self.type==WVRSmallPlayerViewBanner) {
            [self screenRotationWithCompletBlock:^{
                [self.mPlayer setMonocular:isMonocular];
            }];
        }else{
            [self.mPlayer setMonocular:isMonocular];
        }
        
    } else {
        
        [self gotoLaunch];
        return NO;
    }
    
    return YES;
}

- (void)launchBtnOnClick:(UIButton *)launchBtn {
    [self actionSwitchVR:self.isMonocular];
}

- (void)gotoLaunch {
    
    WVRLaunchModel* model = [[WVRLaunchModel alloc] init];
    
    model._renderType = self.mPlayer.getRenderType;
    model.defiKey = self.mCurMediaModel.defiKey;
    model.playUrl = self.mPlayerDataParam.url.absoluteString;
    model.name = self.detailBaseModel.name;
    model.code = self.detailBaseModel.sid;
//    model.sid = self.detailBaseModel.sid;
    model.linkArrangeType = LINKARRANGETYPE_LAUNCH;
    model.position = [self.mPlayer getCurrentPosition];
    model.videoDuration = [self.mPlayer getDuration];
    model.renderTypeStr = self.detailBaseModel.renderType;
    model.type = self.detailBaseModel.type;
    
    if ([self.detailBaseModel respondsToSelector:@selector(displayName)]) {
        model.name = [self.detailBaseModel performSelector:@selector(displayName)];
    }
    
    // 以下两行代码兼容足球
    [model setIsFootball:[self.detailBaseModel isFootball]];
    model.type = self.detailBaseModel.contentType;
    model.behavior = self.detailBaseModel.behavior ?: self.detailBaseModel.sid;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"defaultSlot"] = self.videoEntity.currentStandType;
    model.jumpParamsDic = dict;
    
    switch (self.detailBaseModel.linkType_) {
        case WVRLinkTypeLive:
            model.streamType = STREAM_VR_LIVE;
            break;
            
        default:
            model.streamType = STREAM_VR_VOD;
            break;
    }
    NSMutableDictionary * curDic = [NSMutableDictionary dictionary];
    for (WVRMediaModel * cur in self.itemModel.palyMediaModels) {
        if ([cur.defiKey isEqualToString:kDefinition_ST]) {
            curDic[kDefinition_ST] = cur.playUrl;
        } else if ([cur.defiKey isEqualToString:kDefinition_SD]) {
            curDic[kDefinition_SD] = cur.playUrl;
        } else if ([cur.defiKey isEqualToString:kDefinition_HD]) {
            curDic[kDefinition_HD] = cur.playUrl;
        } else if ([cur.defiKey isEqualToString:kDefinition_SDA]) {
            curDic[kDefinition_SDA] = cur.playUrl;
        } else if ([cur.defiKey isEqualToString:kDefinition_SDB]) {
            curDic[kDefinition_SDB] = cur.playUrl;
        } else if ([cur.defiKey isEqualToString:kDefinition_TDA]) {
            curDic[kDefinition_TDA] = cur.playUrl;
        } else if ([cur.defiKey isEqualToString:kDefinition_TDB]) {
            curDic[kDefinition_TDB] = cur.playUrl;
        }
    }
    model.playUrlDic = curDic;
    
    self.tmpUnityModel = model;
    
    if (self.type == WVRSmallPlayerViewFull) {
        
        [WVRSmallPlayerPresenter shareInstance].isLaunch = YES;
        [self destroyForLauncher];
        
    } else {
        
        [self destroyForUnityBtnClick];
    }
    
    [[WVRMediator sharedInstance] WVRMediator_setPlayerHelper:self.mPlayer];
    
    // 此代码已经放在onGLKVCdealloc方法里执行
//    [WVRGotoNextTool gotoNextVC:model nav:self.controller.navigationController];
}

- (void)sliderDragEnd:(UISlider *)slider {
    
    NSLog(@"slider.value %f", slider.value);
}

#pragma WVRSliderDelegate

- (void)sliderStartScrubbing:(UISlider *)sender {
    DebugLog(@"");
    [self stopPerformWithHiddenVForSliding:NO];
    [self invalidTimer];
    [self.mBottomToolV updateStatus:WVRPlayerToolVStatusPrepare];
}

- (void)sliderEndScrubbing:(UISlider *)sender {
    DebugLog(@"");
//    if ([self isPlaying]) {
//    [self pause];
    [self seekTo:sender.value*[self.mPlayer getDuration]];
    [self.mLoadingV startAnimating:NO];
    [self.mBottomToolV updateStatus:WVRPlayerToolVStatusSliding];
    long curPosition = sender.value*[self.mPlayer getDuration];
    long bufferPosition = [self.mPlayer getPlayableDuration];
    long duration = [self.mPlayer getDuration];
    [self.mBottomToolV updatePosition:curPosition buffer:bufferPosition duration:duration];
//    }
}

#pragma WVRPlayerTopToolVDelegate
- (void)backOnClick:(UIButton *)sender {
    
    [self screenRotation];
}

#pragma WVRPlayerLeftToolVDelegate
- (void)clockBtnOnClick:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    self.isClockScreen = sender.selected;
    [self stopPerformWithHiddenV:sender.selected];
    [self.mLeftToolV hiddenV:NO];
}

#pragma WVRPlayerRightToolVDelegate
- (void)resetBtnOnClick:(UIButton *)sender {
    
    [self.mPlayer orientationReset];
}

#pragma mark - bottom image

- (void)createPlayerBottomImage {       // 底图
    
    [self createPlayerFootballBackgroundImageWithVIP:[self.videoEntity isCameraStandVIP]];
    
    [self.chartletManager createPlayerBottomImageWithVideoEntity:[self videoEntity] player:self.mPlayer];
}

- (void)createPlayerFootballBackgroundImageWithVIP:(BOOL)isVIP {       // 180背景图
    
    if (!self.isFootball) {
        
        [self.mPlayer setBackImage:[UIImage imageWithColor:[UIColor clearColor] size:CGSizeMake(1, 1)]];
        return;
    }
    
    [self.chartletManager createPlayerFootballBackgroundImageWithVIP:isVIP ve:[self videoEntity] player:self.mPlayer detailModel:self.detailBaseModel];
}

- (void)dealloc {
    
    [self destroy];
}

@end
