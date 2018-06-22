//
//  WVRPlayerVCLive.m
//  WhaleyVR
//
//  Created by Bruce on 2017/5/3.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRPlayerVCLive.h"

#import "WVRUMShareView.h"
#import "WVRLotteryModel.h"

#import <WVRMediator+SettingActions.h>

#import "WVRNavigationController.h"
#import "WVRRecommendItemModel.h"
#import "WVRRewardController.h"

#import "WVRWebSocketMsg.h"

#import "WVRProgramBIModel.h"

#import "WVRLivePlayerCompleteStrategy.h"
#import "WVRLivePlayerStrategyConfig.h"

#import "WVRPlayerUILiveManager.h"

#import "WVRMediator+Danmu.h"
#import "WVRMediator+AccountActions.h"
#import "WVRMediator+PayActions.h"

@interface WVRPlayerVCLive ()<WVRPlayerUILiveManagerDelegate> {
    
    WVRVideoEntityLive *_videoEntity;
    
    BOOL _shouldAutorotate;
    UIInterfaceOrientationMask _supportedInterfaceO;
    
//    BOOL _isFirstIn;
    BOOL _notRecordBI;
}

@property (nonatomic, assign) BOOL lotterySwitch;
@property (nonatomic, assign) BOOL danmuSwitch;

//@property (nonatomic, weak) WVRUMShareView *shareView;

@property (nonatomic, strong) NSNumber *lotteryTime;         // 秒
@property (nonatomic, strong) NSDate *authTime;

//@property (nonatomic, assign) CGFloat mOffsetY;

@property (nonatomic, strong) WVRLivePlayerCompleteStrategy * gCompleteStrategy;

@end


@implementation WVRPlayerVCLive
@synthesize lotterySwitch = _lotterySwitch;
@synthesize danmuSwitch = _danmuSwitch;
@synthesize playerUI = _tmpPlayerUI;

#pragma mark - life cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    if (!_isFirstIn) {
    [self toOrientation];
//    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (!self.navigationController) {
        
        [self invalidNavPanGuesture:NO];
        
    } else if (_videoEntity.displayMode == WVRLiveDisplayModeHorizontal) {
        
        [self invalidNavPanGuesture:YES];   // 如果当前直播是横屏，那么进入下级页面时关闭手势返回  BUG #8560
    }
}

#pragma mark - rotation

- (void)toOrientation {
    
    _shouldAutorotate = YES;
    [self updateSupportedInterfaceO];
    UIInterfaceOrientation ori = UIInterfaceOrientationPortrait;
    
    switch (_videoEntity.displayMode) {
        case WVRLiveDisplayModeVertical:
            ori = UIInterfaceOrientationPortrait;
            break;
        case WVRLiveDisplayModeHorizontal:
            ori = UIInterfaceOrientationLandscapeRight;
            break;
    }
    [WVRAppModel forceToOrientation:ori];
    _shouldAutorotate = NO;
    
    if (_videoEntity.displayMode == WVRLiveDisplayModeHorizontal) {
        [self performSelector:@selector(shouldShowCameraTipV) withObject:nil afterDelay:0.5];
    }
//    _isFirstIn = YES;
}

- (void)shouldShowCameraTipV {
    
    if (!self.navigationController) { return; }
    
    [[self playerUI] shouldShowCameraTipView];
}

- (void)updateSupportedInterfaceO {
    
    switch (_videoEntity.displayMode) {
        case WVRLiveDisplayModeVertical:
            _supportedInterfaceO = UIInterfaceOrientationMaskPortrait;
            break;
        case WVRLiveDisplayModeHorizontal:
            _supportedInterfaceO = UIInterfaceOrientationMaskLandscapeRight;
            break;
    }
}

#pragma mark - setter getter

- (void)setDanmuSwitch:(BOOL)danmuSwitch {
    
    _danmuSwitch = danmuSwitch;
    
    [[self playerUI] execDanmuSwitch:danmuSwitch];
    [[self playerUI] changeDanmuSwitchStatus:danmuSwitch];
}

- (void)setLotterySwitch:(BOOL)lotterySwitch {
    
    _lotterySwitch = lotterySwitch;
    
    [[self playerUI] execLotterySwitch:lotterySwitch];
}

- (void)setVideoEntity:(WVRVideoEntityLive *)videoEntity {
    
    if (![videoEntity isKindOfClass:[WVRVideoEntityLive class]]) {
        DDLogError(@"WVRPlayerVCLive setVideoEntity error");
        return;
    }
    
    _videoEntity = videoEntity;
}

- (WVRVideoEntityLive *)videoEntity {
    
    return _videoEntity;
}

- (WVRPlayerUILiveManager *)playerUI {
    
    if (!_tmpPlayerUI) {
        _tmpPlayerUI = [[WVRPlayerUILiveManager alloc] init];
        _tmpPlayerUI.uiDelegate = self;
    }
    return (WVRPlayerUILiveManager *)_tmpPlayerUI;
}

#pragma mark - WVRLivePlayerCompleteStrategy

- (WVRLivePlayerCompleteStrategy *)gCompleteStrategy {
    
    if (!_gCompleteStrategy) {
        WVRLivePlayerStrategyConfig * config = [WVRLivePlayerStrategyConfig new];
        config.code = self.videoEntity.sid;
        kWeakSelf(self);
        WVRLivePlayerCompleteStrategy * cs = [[WVRLivePlayerCompleteStrategy alloc] initWithConfig:config completeBlock:^{
            [weakself liveCompleteBlock];
        } restartBlock:^(void (^successRestartBlock)(void)) {
            [weakself liveRestartPlayerBlock];
        } overLimitBlock:^{
            [weakself overLimitBlock];
        }];
        _gCompleteStrategy = cs;
    }
    return _gCompleteStrategy;
}

- (void)liveCompleteBlock {
    
    kWeakSelf(self);
    NSString * tip = kToastLiveOver;
    if ([WVRReachabilityModel sharedInstance].isNoNet) {
        tip = @"直播遇到网络问题，请稍后重试:(";
    }
    [UIAlertController alertTitle:@"提示" mesasge:tip preferredStyle:UIAlertControllerStyleAlert confirmHandler:^(UIAlertAction *action) {
        [weakself dismissViewController];
    } viewController:weakself];
}

- (void)dismissViewController {
    [super dismissViewController];
    
//    [[WVRWebSocketCliennt shareInstance] closeWithProgramId:self.videoEntity.sid];
}

- (void)liveRestartPlayerBlock {
    
    [self actionPlay:NO];
    [[self playerUI] execupdateLoadingTip:@"加载直播流中"];
    [[self playerUI] execStalled];
}

- (void)overLimitBlock {
    
    kWeakSelf(self);
    [UIAlertController alertTitle:@"提示" mesasge:@"直播遇到网络问题，请稍后重试:(" preferredStyle:UIAlertControllerStyleAlert confirmHandler:^(UIAlertAction *action) {
        
        [weakself dismissViewController];
        
    } viewController:weakself];
}

#pragma mark - Notification

// 键盘 弹出/消失，事件注册
- (void)registerObserverEvent {
    [super registerObserverEvent];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    // 保护
    if (![self isCurrentViewControllerVisible]) { return; }
    
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat height = keyboardRect.size.height;
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [[self playerUI] execKeyboardOn:YES keyboardHeight:height animateTime:animationDuration];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    // 保护
    if (![self isCurrentViewControllerVisible]) { return; }
    
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [[self playerUI] execKeyboardOn:NO keyboardHeight:0 animateTime:animationDuration];
}

- (void)appWillEnterForeground:(NSNotification *)notification {
    
    // 保护
    if (![self isCurrentViewControllerVisible]) { return; }
    
//    [_shareView removeFromSuperview];
}

#pragma mark - overwrite func

- (void)buildInitData {
    if (![WVRReachabilityModel isNetWorkOK]) {
        SQToastInKeyWindow(kNetError);
        return;
    }
    [super buildInitData];
    
    self.vPlayer.gIngnoreNetStatus = YES;
    [self easterEggAuth:nil];
    
    [self requestForViewCount];
    [self requestForLotterySwitch];
}

- (void)requestForDetailData {
    
    kWeakSelf(self);
    
    [WVRLiveDetailModel requestForLiveDetailWithCode:self.videoEntity.sid block:^(WVRLiveDetailModel *responseObj, NSError *error) {
        
        if (responseObj) {
            
            [weakself dealWithDetailData:responseObj];
        } else if (error.code == 200) {
            
            // 节目已失效
            [weakself screenRotation:NO complate:^{
                
                SQToastInKeyWindow(kToastProgramInvalid);
            }];
        } else if (error.code >= 500) {
            
            SQToastInKeyWindow(kLoadError);
        }
    }];
}

- (void)dealWithDetailData:(WVRLiveDetailModel *)model {
    
    if (model.liveStatus == WVRLiveStatusEnd) {
        [self screenRotationAndBack:NO];
        return;
    }
    
    if (!_notRecordBI) {
        
        [WVRProgramBIModel trackEventForDetailWithAction:BIDetailActionTypeBrowseLivePlay sid:model.code name:model.title];
        _notRecordBI = YES;
    }
    
    if (![self.videoEntity isKindOfClass:[WVRVideoEntityLive class]]) {
        
        self.videoEntity = [[WVRVideoEntityLive alloc] init];
        _videoEntity.sid = model.sid;
        _videoEntity.videoTitle = model.name;
    }
    
    _lotterySwitch = model.isLottery > 0;
    _danmuSwitch = model.isDanmu > 0;
    _videoEntity.intro = model.intrDesc;
    _videoEntity.address = model.address;
    _videoEntity.beginTime = model.beginTime;
    _videoEntity.endTime = model.endTime;
    _videoEntity.mediaDtos = model.mediaDtos;
    _videoEntity.icon = model.poster;
    if (_videoEntity.displayMode != model.displayMode) {
        _videoEntity.displayMode = model.displayMode;
        [self toOrientation];
    }
    
    [self openSocket];
    
    [super dealWithDetailData:model];
}

- (void)openSocket {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    dict[@"programId"] = self.videoEntity.sid;
    dict[@"programName"] = self.videoEntity.videoTitle;
    
    kWeakSelf(self);
    void(^block)(WVRWebSocketMsg *msg) = ^(WVRWebSocketMsg *msg) {
        
        if ([msg.senderUid isEqualToString:[WVRUserModel sharedInstance].showRoomUserID]) {
            
        } else {
            [weakself refreshDanmu:msg];
        }
    };
    
    dict[@"block"] = block;
    
    [[WVRMediator sharedInstance] WVRMediator_ConnectForDanmu:dict];
}

// 无需记录历史
- (void)recordHistory {}

#pragma mark - WVRPlayerHelperDelegate

- (void)onVideoPrepared {
    [super onVideoPrepared];
    
    [self.gCompleteStrategy resetStatus];
}

- (void)onCompletion {
//    [super onCompletion];
    [self.gCompleteStrategy http_liveStatus];
}

- (void)onError:(int)code {
//    [super onError:code];
    [self.gCompleteStrategy http_liveStatus];
}

#pragma mark - timer

- (void)syncScrubber {
    [super syncScrubber];
    
    if (self.syncScrubberNum % 5 == 0) {
        
        [self requestForViewCount];
        
        if (self.syncScrubberNum % 60 == 0) {
            [self requestForLotterySwitch];
        }
    }
    
    if (_lotteryTime && _lotterySwitch) {
        
        [[self playerUI] execEasterEggCountdown:(long)_lotteryTime.longLongValue];
        
        _lotteryTime = [NSNumber numberWithLongLong:(_lotteryTime.longLongValue - 1)];
        if (_lotteryTime.intValue < 0) {
            _lotteryTime = nil;
        }
    }
}

- (void)checkFreeTime {
    // beta 需要测试
    if (!self.isCharged && [self.vPlayer isPrepared]) {
        
        NSNumber *trailTime = [[WVRAppModel sharedInstance].liveTrailDict objectForKey:self.detailBaseModel.code];
        if (!trailTime) { trailTime = @(0); }
        
        if (trailTime.integerValue >= self.detailBaseModel.freeTime) {
            
            [self.vPlayer destroyPlayer];
            self.vPlayer.isFreeTimeOver = YES;
            
            [[self playerUI] execFreeTimeOverToCharge:self.detailBaseModel.freeTime];
            self.curPosition = 0.1;
        }
        trailTime = [NSNumber numberWithInteger:(trailTime.integerValue + 1)];
        [[WVRAppModel sharedInstance].liveTrailDict setValue:trailTime forKey:self.detailBaseModel.code];
        
        [[WVRAppModel sharedInstance] saveLiveTrailDict];
    }
}

#pragma mark - request

- (void)requestForViewCount {
    
    kWeakSelf(self);
    [WVRStatQueryDto requestWithCode:self.videoEntity.sid block:^(WVRStatQueryDto * responseObj, NSError *error) {
        if (responseObj) {
            WVRStatQueryDto *model = responseObj;
            [[weakself playerUI] execPlayCountUpdate:model.playCount];
        }
    }];
}

- (void)requestForLotterySwitch {
    
    kWeakSelf(self);
    [WVRLotteryModel requestLotterySwitchForSid:self.videoEntity.sid block:^(id responseObj, NSError *error) {
        
        weakself.lotterySwitch = ([responseObj[@"lottery"] intValue] == 1);
        weakself.danmuSwitch = ([responseObj[@"danmu"] intValue] == 1);
        [weakself refreshSocketStatus];
    }];
}

#pragma mark - handle data

- (void)refreshSocketStatus {
    
    if (self.danmuSwitch) {
        
    } else {

    }
}

- (void)refreshDanmu:(WVRWebSocketMsg *)msg {
    
    [[self playerUI] execDanmuReceived:@[msg]];
}

/// 广来后端认证
- (void)easterEggAuth:(NSDictionary *)infoDict {
    
    if (self.authTime) {
        NSTimeInterval time = [self.authTime timeIntervalSinceNow];
        time = abs((int)time);
        if (time < 300) {           // 上次认证在5分钟内 不再做认证
            
            [self refreshEasterEggCountdown];
            return;
        }
    }
    
    kWeakSelf(self);
    [WVRLotteryModel requestForAuthLottery:^(id responseObj, NSError *error) {
        
        if ([responseObj[@"status"] intValue] == 1) {
            weakself.authTime = [NSDate date];
        }
        [weakself refreshEasterEggCountdown];
    }];
}

#pragma mark - WVRPlayerUILiveManagerDelegate

- (void)shareBtnClick:(UIButton *)sender {
    
    kWeakSelf(self);
//    [[self playerUI] scheduleHideControls];
//    [self controlOnPause];
    
    WVRUMShareView *shareView = [WVRUMShareView shareWithContainerView:self.view
                                                                  sID:self.videoEntity.sid
                                                              iconUrl:_videoEntity.icon
                                                                title:_videoEntity.videoTitle
                                                                intro:@""
                                                                mobId:nil
                                                            shareType:WVRShareTypeLive];
    shareView.cancleBlock = ^(BOOL isCancle) {
        [weakself controlOnResume];
    };
    
//    _shareView = shareView;
}

- (void)vrModeBtnClick:(UIButton *)sender {
//    [self screenRotation:YES];
    
    [self changeToVRMode];
}

- (BOOL)checkLogin {
    
    [WVRAppModel sharedInstance].shouldContinuePlay = YES;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    @weakify(self);
    RACCommand *successCmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            
            @strongify(self);
            BOOL isLogined = [input boolValue];
            
            if (!isLogined) {
                [self dealWithUserLogin];
            }
            return nil;
        }];
    }];
    dict[@"complationCmd"] = successCmd;
    
    BOOL isLogin = [[WVRMediator sharedInstance] WVRMediator_CheckAndAlertLogin:dict];
    
    return isLogin;
}

- (void)dealWithUserLogin {
    
    if ([[WVRMediator sharedInstance] WVRMediator_ConnectIsActive:nil]) {

        [[WVRMediator sharedInstance] WVRMediator_AuthAfterLogin:nil];
        
    } else {
        [self openSocket];
    }
}

- (void)actionSendDanmu:(NSString *)text {
    
    if (![self danmuSwitch]) {
        SQToastInKeyWindow(@"此节目不支持弹幕");
        return;
    }
    
    kWeakSelf(self);
    void(^successBlock)() = ^() {
        
        WVRWebSocketMsg * msg = [WVRWebSocketMsg new];
        msg.content = text;
        msg.senderNickName = [WVRUserModel sharedInstance].username;
        [weakself refreshDanmu:msg];
    };
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    dict[@"msg"] = text;
    dict[@"successBlock"] = successBlock;
    
    [[WVRMediator sharedInstance] WVRMediator_SendMessage:dict];
}

// fullScreen代表横屏状态
- (void)actionSetFullscreen:(BOOL)isFullScreen {
    
    [self screenRotation:isFullScreen];
}

#pragma mark - WVRPlayerViewDelegate

- (void)actionGotoBuy {
    
    [self.view.window endEditing:NO];
    if (self.vPlayer.isValid) {
        [self controlOnPause];
    }
    
    [self screenRotation:NO complate:^{
        
        @weakify(self);
        RACCommand *cmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary * _Nullable input) {
            
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                
                BOOL success = [input[@"success"] boolValue];
                @strongify(self);
                [self dealWithPaymentResult:success];
                
                return nil;
            }];
        }];
        
        //    @{ @"itemModel":WVRItemModel, @"streamType":WVRStreamType , @"cmd":RACCommand }
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        dict[@"streamType"] = @(self.videoEntity.streamType);
        dict[@"itemModel"] = self.detailBaseModel;
        dict[@"cmd"] = cmd;
        
        [[WVRMediator sharedInstance] WVRMediator_PayForVideo:dict];
    }];
}

- (void)dealWithPaymentResult:(BOOL)success {
    
    [self toOrientation];

    self.isCharged = success;
    
    if (success) {
        [[WVRMediator sharedInstance] WVRMediator_PayReportDevice:nil];
        
        [self dealWithPaymentOver];
    } else {
        if (self.vPlayer.isValid) {
            [self controlOnResume];
        }
    }
}

#pragma mark - WVRPlayerViewLiveDelegate

- (void)actionGoGiftPage {
    
    kWeakSelf(self);
    [self screenRotation:NO complate:^{
        
        WVRRewardController *vc = [[WVRRewardController alloc] init];
        [weakself.navigationController pushViewController:vc animated:YES];
    }];
}

- (BOOL)actionCheckLogin {
    
    [WVRAppModel sharedInstance].shouldContinuePlay = YES;
    
    @weakify(self);
    RACCommand *successCmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            
            BOOL isLogined = [input boolValue];
            @strongify(self);
            if (!isLogined) {
                [self easterEggAuth:nil];
            }
            
            return nil;
        }];
    }];
    
    RACCommand *cancelCmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            
            [WVRAppModel sharedInstance].shouldContinuePlay = NO;
            return nil;
        }];
    }];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    dict[@"completeCmd"] = successCmd;
    dict[@"cancelCmd"] = cancelCmd;
    
    BOOL isLogin = [[WVRMediator sharedInstance] WVRMediator_CheckAndAlertLogin:dict];
    
    return isLogin;
}

- (void)actionEasterEggLottery {
    
    kWeakSelf(self);
    
    [WVRLotteryModel requestForLotteryWithSid:self.videoEntity.sid block:^(id responseObj, NSError *error) {
        
        if ([responseObj[@"status"] intValue] == 1) {
            
            [[WVRMediator sharedInstance] WVRMediator_UpdateRewardDot:YES];
        }
        [[weakself playerUI] execLotteryResult:responseObj];
        
        if ([responseObj[@"countdown"] intValue] > 0) {
            
            self.lotteryTime = [NSNumber numberWithInteger:[responseObj[@"countdown"] intValue]];
        } else if ([responseObj[@"remain"] intValue] == 0) {
            
            [weakself refreshEasterEggCountdown];
        }
    }];
}

- (void)refreshEasterEggCountdown {
    
    kWeakSelf(self);
    [WVRLotteryModel requestForBoxCountdownForSid:self.videoEntity.sid block:^(id responseObj, NSError *error) {
        
        if (responseObj[@"countdown"]) {
            
            weakself.lotteryTime = [NSNumber numberWithLongLong:[responseObj[@"countdown"] longLongValue]];
        } else {
            weakself.lotteryTime = @10;
        }
    }];
}

- (void)actionGoRedeemPage {
    
    [self screenRotation:NO complate:^{
        
        @weakify(self);
        RACCommand *cmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                
                @strongify(self);
                UIViewController *vc = [[WVRMediator sharedInstance] WVRMediator_MyTicketViewController];
                [self.navigationController pushViewController:vc animated:YES];
                return nil;
            }];
        }];
        NSDictionary *dict = @{ @"completeCmd":cmd };
        
        [[WVRMediator sharedInstance] WVRMediator_CheckAndAlertLogin:dict];
    }];
}

#pragma mark - rotation

- (void)screenRotation:(BOOL)isLandspace {
    
//    if (![[self vPlayer] isOnPrepared] && isLandspace) {
//        SQToastInKeyWindow(@"视频播放时才能切换至眼镜模式");
//        return;
//    }
    
    [self.view endEditing:YES];
    
    [[self playerUI] screenWillRotationWithStatus:isLandspace];
    
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    
    [UIView animateWithDuration:duration animations:^{
        
        [self rotaionAnimations:isLandspace];
    } completion:^(BOOL finished) {
        
        [self rotaionAnimatCompletion:isLandspace];
        [[self playerUI] screenRotationCompleteWithStatus:isLandspace];
    }];
}

/// private - rotation and complateBlock
- (void)screenRotation:(BOOL)isLandspace complate:(void (^)())complateBlock {
    
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    
    [UIView animateWithDuration:duration animations:^{
        
        [self rotaionAnimations:isLandspace];
    } completion:^(BOOL finished) {
        
        [self rotaionAnimatCompletion:isLandspace];
        [[self playerUI] screenRotationCompleteWithStatus:isLandspace];
        
        if (complateBlock) {
            complateBlock();
        }
    }];
}

- (void)rotaionAnimations:(BOOL)isLandspace {
    
    _shouldAutorotate = YES;
    _supportedInterfaceO = isLandspace ? UIInterfaceOrientationMaskLandscapeRight : UIInterfaceOrientationMaskPortrait;
    [WVRAppModel forceToOrientation:isLandspace ? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationPortrait];
    _shouldAutorotate = NO;
}

- (void)rotaionAnimatCompletion:(BOOL)isLandspace {
//    [self actionSwitchVR:!isLandspace];
    [[self playerUI] screenRotationCompleteWithStatus:isLandspace];
    
    [self invalidNavPanGuesture:isLandspace];
}

- (void)screenRotationAndBack:(BOOL)isLandspace {
    
    [[self playerUI] screenWillRotationWithStatus:isLandspace];
    
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    
    [UIView animateWithDuration:duration animations:^{
        [self rotaionAnimations:isLandspace];
    } completion:^(BOOL finished) {
        [self rotaionAndBackCompletion:isLandspace];
    }];
}

- (void)rotaionAndBackCompletion:(BOOL)isLandspace {
//    [self actionSwitchVR:!isLandspace];
    
    [self invalidNavPanGuesture:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
    SQToastInKeyWindow(kToastLiveOver);
}

// 横屏状态下要失效掉右划返回功能
/// YES：关闭手势返回 NO：开启手势返回
- (void)invalidNavPanGuesture:(BOOL)isInvalid {
    
    WVRNavigationController *nav = (WVRNavigationController *)self.navigationController;
    nav.gestureInValid = isInvalid;
}

#pragma mark - rotation

- (BOOL)shouldAutorotate {
    
    return YES;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return _supportedInterfaceO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    
    return UIInterfaceOrientationLandscapeRight;
}

@end
