//
//  WVRDetailVC.m
//  WhaleyVR
//
//  Created by Snailvr on 16/9/9.
//  Copyright © 2016年 Snailvr. All rights reserved.
//
// 详情页基类，请勿直接使用

#import "WVRDetailVC.h"
#import "WVRNavigationController.h"

#import "WVRLiveDetailVC.h"
#import "WVRBIModel.h"
#import "WVRHistoryModel.h"
#import "WVRTVDetailBaseController.h"

#import "WVRProgramPackageController.h"
#import "WVRVideoEntityMoreTV.h"

#import "WVRHttpWatchOnlineRecord.h"
#import "WVRWatchOnlineRecord.h"
#import "WVRParseUrl.h"
#import "WVRDeviceModel.h"

#import <ReactiveObjC/ReactiveObjC.h>
#import "WVRChartletManager.h"

#import "WVRMediator+UnityActions.h"
#import "WVRMediator+PayActions.h"
#import "WVRMediator+AccountActions.h"

@interface WVRDetailVC ()<WVRPlayerUIManagerDelegate, WVRPlayerHelperDelegate> {
    
    long _isLowFps;
    long _pollingNum;
    BOOL _shouldAutorotate;
    UIInterfaceOrientationMask _supportedInterfaceO;
}

@property (nonatomic, weak) NSTimer  *timer;

@property (assign, atomic) BOOL parseURLComplete;         // 解析链接完成
@property (atomic, assign) BOOL requestChargedComplete;   // 请求是否付费完成

@property (nonatomic, assign) BOOL isLandspace;

@property (nonatomic, strong) WVRWatchOnlineRecord * gwOnlineRecord;

@property (nonatomic, strong) WVRChartletManager *chartletManager;

/// 横屏的时候跳转购买
@property (nonatomic, assign) BOOL buyFromLandscape;

@end


@implementation WVRDetailVC
@synthesize bar;
@synthesize playerUI = _tmpPlayerUI;        // 调用请走get方法

#pragma mark - life cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        // 详情页默认不会出现在tab中，所以这个属性默认置为YES
        self.hidesBottomBarWhenPushed = YES;
        
        _supportedInterfaceO = UIInterfaceOrientationMaskPortrait;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.gwOnlineRecord) {
        self.gwOnlineRecord = [WVRWatchOnlineRecord new];
    }
    [[WVRMediator sharedInstance] WVRMediator_ReportLostInAppPurchaseOrders];
    
    [self configSelf];
    
    [self buildData];
    
    [self drawUI];
    
    [self setUpRequestRAC];
    [self requestData];
    
    [self registerObserverEvent];       // 播放器相关，只能执行一次
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [WVRAppModel forceToOrientation:UIInterfaceOrientationPortrait];
    
    if (bar) {
        
        [self.view bringSubviewToFront:bar];
        [bar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self invalidNavPanGuesture:NO];
    self.view.window.backgroundColor = [UIColor blackColor];
    
    if (self.vPlayer.isValid) {
        
        BOOL success = [self.vPlayer onResume];
        if (success) {
            [self.playerUI execPlaying];
        }
        [self startTimer];
        
    } else if (self.vPlayer.isFreeTimeOver) {
        
        // 试看结束后回来，不自动开播
        
    } else if (self.vPlayer.isOnDestroy || self.vPlayer.isReleased) {
        
        if (![self.playerUI isHaveStartView]) {
            [self.playerUI execStalled];
        } else {
            [self.playerUI execCheckStartViewAnimation];
        }
        
        if (self.playerUI.playerView.viewStatus == WVRPlayerViewStatusLandscape) {
            [WVRAppModel changeStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
        }
        
        [self.vPlayer setParamAndPlay:self.vPlayer.dataParam];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self recordHistory];
    [self watch_online_record:NO];
    
    if (self.vPlayer.isValid) {
        if (!self.navigationController) {
            [_vPlayer onBackForDestroy];
        } else {
            self.vPlayer.dataParam.position = [self.vPlayer getCurrentPosition];
            
            [self.vPlayer destroyPlayer];
            [self.playerUI execSuspend];
        }
    }
    
    [self invalidNavPanGuesture:NO];
    self.view.window.backgroundColor = [UIColor whiteColor];
    
    [self stopTimer];
    
    self.view.window.backgroundColor = [UIColor whiteColor];
}

- (void)watch_online_record:(BOOL)isComin {
    NSString * contentType = @"live";
    switch (self.videoEntity.streamType) {
        case STREAM_3D_WASU:
        case STREAM_VR_VOD:
        case STREAM_2D_TV:
            
            contentType = @"recorded";
            break;
        case STREAM_VR_LOCAL:
        case STREAM_VR_LIVE:
            return;
            break;
            
        default:
            return;
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

- (void)dealloc {
    
    [self stopTimer];
    
    [self.vPlayer onBackForDestroy];
    [self.playerUI execDestroy];
    
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
}

#pragma mark - build data

// 初始化数据
- (void)buildData {
    
    _pollingNum = 1;
    
    _isLowFps = 5;
    
    [self playerUI];
}

- (void)configSelf {
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self createNavBar];
}

// 该方法在详情页生命周期内被调用2次
- (void)drawUI {
    
    if (bar) { [self.view bringSubviewToFront:bar]; }
}

- (void)createNavBar {
    
    bar = [[WVRDetailNavigationBar alloc] init];
    
    [self.view addSubview:bar];
}

- (void)navShareSetting {
    
    UINavigationItem *item = [[UINavigationItem alloc] init];
    
    UIImage *backimage = [[UIImage imageNamed:@"icon_manual_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:backimage style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonClick)];
    item.leftBarButtonItems = @[ backItem ];
    
    UIImage *image = [[UIImage imageNamed:@"icon_detail_share"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *ShareItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(rightBarShareItemClick)];
    
    item.rightBarButtonItems = @[ ShareItem ];
    
    [self.bar pushNavigationItem:item animated:NO];
}

- (void)navBackSetting {
    
    UINavigationItem *item = [[UINavigationItem alloc] init];
    
    UIImage *backimage = [[UIImage imageNamed:@"icon_manual_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:backimage style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonClick)];
    
    item.leftBarButtonItems = @[ backItem ];
    
    [self.bar pushNavigationItem:item animated:NO];
}

- (void)purchaseBtnHideWithAnimation {
    // 子类有需求实现
}

#pragma mark - action

// 返回
- (void)leftBarButtonClick {
    
    [self stopTimer];
    
    [self.navigationController popViewControllerAnimated:YES];
}

// 分享 子类中如果有分享按钮，就把此方法实现
- (void)rightBarShareItemClick {
    
    [self.vPlayer stop];
}

- (void)invalidNavPanGuesture:(BOOL)isInvalid {
    
    WVRNavigationController *nav = (WVRNavigationController *)self.navigationController;
    nav.gestureInValid = isInvalid;
}

#pragma mark - request

- (void)setUpRequestRAC {
    
    @throw [NSException exceptionWithName:@"error" reason:@"You Must OverWrite This Function In SubClass" userInfo:nil];
}

- (void)requestData {
    
    @throw [NSException exceptionWithName:@"error" reason:@"You Must OverWrite This Function In SubClass" userInfo:nil];
}

#pragma mark - 半屏播放器

- (void)startToPlay {
    
    if (self.vPlayer.isValid) {
        [self.vPlayer stop];   // 针对连播，点击其他剧集后先把播放器停掉
    }
    
    [self createwPlayerView];
    
    BOOL isReach = [WVRReachabilityModel sharedInstance].isReachNet;
    BOOL isNoNet = [WVRReachabilityModel sharedInstance].isNoNet;
    
    if (isReach)  {     //  && (onlyWifi != 1)
        
        [UIAlertController alertTitle:kAlertTitle mesasge:kReachAlert preferredStyle:UIAlertControllerStyleAlert confirmHandler:^(UIAlertAction *alert) {
            
            [self buildInitData];
            
        } cancleHandler:nil viewController:self.navigationController];
        
    } else if (isNoNet) {
        [UIAlertController alertMessage:kNoNetAlert viewController:self.navigationController];
    } else {
        [self buildInitData];
    }
}

- (NSInteger)playerStatus {
    
    NSInteger status = 0;
    if (self.vPlayer.isComplete) {
        status = 2;
    } else if (self.vPlayer.isPlaying) {
        status = 1;
    } else {
        status = 0;
    }
    return status;
}

- (void)createwPlayerView {
    
    if (![[self playerUI] playerView]) {
        
        [self.playerUI createPlayerViewWithContainerView:self.playerContentView];
        
        [self createPlayerHelperIfNot];
        
    } else {
        
        [self.playerUI execWaitingPlay];
    }
}

#pragma mark - getter

- (WVRChartletManager *)chartletManager {
    if (!_chartletManager) {
        _chartletManager = [[WVRChartletManager alloc] init];
    }
    return _chartletManager;
}

- (WVRPlayerUIManager *)playerUI {
    if (!_tmpPlayerUI) {
        
        _tmpPlayerUI = [[WVRPlayerUIManager alloc] init];
        _tmpPlayerUI.uiDelegate = self;
    }
    return _tmpPlayerUI;
}

#pragma mark - init Data

- (void)buildInitData {
    
    _parseURLComplete = NO;
    
    [self checkForCharge];
    [self dealWithPlayUrl];
}

// 付费流程检测
- (void)checkForCharge {
    
    _isCharged = NO;
    
    BOOL chargeable = self.detailBaseModel.isChargeable;
    BOOL notFree = YES;        // (self.detailBaseModel.price > 0)
    
    if (chargeable && notFree) {
        
        [self requestForPaied];
    } else {
        _requestChargedComplete = YES;
        _isCharged = YES;
    }
}

- (void)requestForPaied {
    
    PurchaseProgramType type = PurchaseProgramTypeVR;
    if (self.videoEntity.streamType == STREAM_VR_LIVE) {
        type = PurchaseProgramTypeLive;
    }
    _requestChargedComplete = NO;
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];

    @weakify(self);
    RACCommand *cmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            
            @strongify(self);
            [self dealWithCheckVideoPaied:[input boolValue]];
            
            return nil;
        }];
    }];
    NSMutableDictionary *item = [NSMutableDictionary dictionary];
    item[@"sid"] = self.videoEntity.sid;
    item[@"goodsType"] = @(type);
    param[@"item"] = item;

    param[@"cmd"] = cmd;

    [[WVRMediator sharedInstance] WVRMediator_CheckVideoIsPaied:param];
}

- (void)dealWithCheckVideoPaied:(BOOL)isCharged {
    
    if (self.vPlayer.isOnBack) { return; }
    
    _requestChargedComplete = YES;
    
    self.isCharged = isCharged;
    [self dealWithPaymentOver];
}

// 检测支付/支付流程结束 调用
- (void)dealWithPaymentOver {
    
    if (_isCharged) { [self purchaseBtnHideWithAnimation]; }
    
    if (self.vPlayer.isValid) {
        
        if (_isCharged || self.vPlayer.getCurrentPosition/1000.f < _detailBaseModel.freeTime) {
            
            [self.vPlayer start];
            [self startTimer];
            
            if (_isCharged) {
                [self.playerUI execPaymentSuccess];
            }
            if ([self.vPlayer isPlaying]) {
                [self.playerUI execPlaying];
            }
        }
        
    } else if (self.vPlayer.isOnDestroy || self.vPlayer.isReleased) {
        
        WVRDataParam *dataM = self.vPlayer.dataParam;
        dataM.position = [self.vPlayer getCurrentPosition];
        if (_buyFromLandscape) {
            
            kWeakSelf(self);
            [self screenRotation:YES completeBlock:^{
                
                weakself.buyFromLandscape = NO;
                
                [weakself.vPlayer setParamAndPlay:dataM];
            }];
            
        } else {
            [self.vPlayer setParamAndPlay:dataM];
        }
        
        if (_isCharged) {
            [self.playerUI execPaymentSuccess];
        }
        [self.playerUI execWaitingPlay];
        
    } else {
        [self readyToPlay];
    }
}

- (void)dealWithPlayUrl {
    
    _parseURLComplete = NO;
    
    kWeakSelf(self);
    
    [_videoEntity parserPlayUrl:^{
        
        if (weakself.vPlayer.isOnBack) { return; }
        
        if (weakself.videoEntity.parserdUrlModelList.count > 0) {
            
            DDLogInfo(@"parserPlayUrl 解析成功");
            weakself.parseURLComplete = YES;
            [weakself readyToPlay];
            [weakself.playerUI exeUpdateDefineTitle];
        } else {
            weakself.parseURLComplete = NO;
            
            if ([weakself reParserPlayUrl]) {
                
                [weakself buildInitData];
                [weakself.playerUI execWaitingPlay];
                
            } else {
                BOOL netOK = [WVRReachabilityModel isNetWorkOK];
                NSString *err = netOK ? kNoNetAlert : kLinkError;
                [weakself dealWithError:err code:(netOK ? -3000 : -1000)];
            }
        }
    }];
}

- (void)dealWithError:(NSString *)err code:(int)code {
    
    [self.playerUI execError:err code:code];
    [self.vPlayer playError:err code:code videoEntity:_videoEntity];
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
    
    kWeakSelf(self);
    
    [[RACObserve(self, videoEntity) skip:1] subscribeNext:^(id  _Nullable x) {
        
        weakself.playerUI.videoEntity = weakself.videoEntity;
    }];
    
    [[RACObserve(self, detailBaseModel) skip:1] subscribeNext:^(id  _Nullable x) {
        
        weakself.playerUI.detailBaseModel = weakself.detailBaseModel;
    }];
    [[RACObserve(self, vPlayer) skip:1] subscribeNext:^(id  _Nullable x) {
        
        weakself.playerUI.vPlayer = weakself.vPlayer;
    }];
}

- (void)networkStatusChanged:(NSNotification *)notification {
    
    if ([self isCurrentViewControllerVisible]) {
        
//        [self.playerUI execNetworkStatusChanged];
    }
}

- (void)appWillEnterBackground:(NSNotification *)notification {
    
    for (UIView *view in self.view.subviews) {
        if ([view isMemberOfClass:[WVRUMShareView class]]) {
            [view removeFromSuperview];
            break;
        }
    }
}

- (void)appWillResignActive:(NSNotification *)notification {
    
    // 保护
    if (![self isCurrentViewControllerVisible] || !self.vPlayer.isValid) { return; }
    
    [self stopTimer];
    [self.playerUI execSuspend];
}

- (void)appDidBecomeActive:(NSNotification *)notification {
    
    // 保护
    if (![self isCurrentViewControllerVisible] || !self.vPlayer.isValid) { return; }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.vPlayer isPlaying]) {
            [self.playerUI execPlaying];
            [self startTimer];
        }
    });
}

#pragma mark - WVRPlayerHelperDelegate

- (void)restartUI {
    
    [self.playerUI execStalled];
}

- (void)pauseUI {
    
    [self stopTimer];
    [self.playerUI execSuspend];
}

- (void)onVideoPrepared {
    
    [self startTimer];
    
    [self createPlayerBottomImage];
    
    [self.playerUI execPreparedWithDuration:[_vPlayer getDuration]];
    [self watch_online_record:YES];
    [self recordHistory];
}

- (void)onCompletion {
    
    [self stopTimer];
    BOOL netOK = [WVRReachabilityModel isNetWorkOK];
    if (!netOK) {
        [self.playerUI execSuspend];
        
        return;
    }
    [self recordHistory];
    [self watch_online_record:NO];
    // 连播
    if (self.videoEntity.streamType == STREAM_2D_TV) {
        WVRVideoEntityMoreTV *ve = (WVRVideoEntityMoreTV *)_videoEntity;
            
        if ([ve canPlayNext]) {
            [self playNextVideo];
            [self.playerUI execWaitingPlay];
            
            return;     // 播放到最后一集就结束
        }
    }
    
    [self.playerUI execComplete];
}

- (void)onError:(int)what {
    self.curPosition = [self.vPlayer getCurrentPosition];
    NSString *err = [NSString stringWithFormat:@"%d", what];
    
    [self stopTimer];
    if (!self.playerUI.playerView.isLandscape) {
        self.bar.hidden = NO;   // 竖屏播放模式下，onError后把导航栏和返回按钮漏出来
    }
    BOOL netOK = [WVRReachabilityModel isNetWorkOK];
    if (!netOK) {
//        [self.playerUI execSuspend];
        [self dealWithError:err code:(netOK ? -2000 : -1000)];
        return;
    }
    if ([self reParserPlayUrl]) {
        
        [self buildInitData];
        [self.playerUI execWaitingPlay];
        
    } else {
        
        BOOL netOK = [WVRReachabilityModel isNetWorkOK];
        [self dealWithError:err code:(netOK ? -2000 : -1000)];
    }
}

// 播放卡顿
- (void)onBuffering {
    
    [self startTimer];
    [self.playerUI execStalled];
}

- (void)onBufferingOff {
    
    [self startTimer];
    [self.playerUI execPlaying];
}

- (void)onGLKVCdealloc {
    
    if ([self.detailBaseModel isFootball]) {
        
        [self showFootballUnity];
    
    } else {
        
        [self showUnityView];
    }
}

#pragma mark - timer

- (void)startTimer {
    
    if ([_timer isValid]) { return; }
    
    //MARK: - 直播详情页目前不播放视频
    if (self.videoEntity.streamType == STREAM_VR_LIVE) { return; }
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(syncScrubber) userInfo:nil repeats:YES];
    _timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    
    [_timer invalidate];
    _timer = nil;
}

// 此刷新函数每隔interval执行一次
- (void)syncScrubber {
    
    long speed = [[WVRAppModel sharedInstance] checkInNetworkflow];
    if (![_vPlayer isPlaying]) {
        
        [self.playerUI execDownloadSpeedUpdate:speed];
        
    } else {
        
        long time = [_vPlayer getCurrentPosition];
        [self checkFreeTime:time];
        
        long buffer = [_vPlayer getPlayableDuration];
        
        [self.playerUI execPositionUpdate:time buffer:buffer duration:[_vPlayer getDuration]];
        
        [self checkFps];
        [self checkChargeDevice];
    }
    _pollingNum ++;
    _isLowFps ++;
}

- (void)checkFps {
    
    float fps = [_vPlayer getFps];
    if (fps < 15 && _isLowFps >= 5) {
        
        _videoEntity.biEntity.bitrate = fps;
        [_vPlayer trackEventForLowbitrate];
        _isLowFps = 0;      // not track in 5 second
    }
}

// time = ms
- (void)checkFreeTime:(long)time {
    
    if (!self.isCharged && time / 1000 >= _detailBaseModel.freeTime) {
        
        [_vPlayer destroyPlayer];
        _vPlayer.isFreeTimeOver = YES;
        
        [self.playerUI execFreeTimeOverToCharge:_detailBaseModel.freeTime];
        _curPosition = 0.1;
        self.vPlayer.dataParam.position = 0;
    }
}

- (void)checkChargeDevice {
    
    if (_pollingNum % 10 == 0 && self.isCharged && _detailBaseModel.isChargeable) {
        
        @weakify(self);
        RACCommand *cmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                @strongify(self);
                [self dealWithPlayDeviceUnsigned];
                return nil;
            }];
        }];
        NSDictionary *dict = @{ @"cmd":cmd };
        
        [[WVRMediator sharedInstance] WVRMediator_CheckDevice:dict];
    }
}

- (void)dealWithPlayDeviceUnsigned {
    
    [self actionPause];
    
    @weakify(self);
    RACCommand *cmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self);
            [self actionOnExit];
            return nil;
        }];
    }];
    NSDictionary *dict = @{ @"cmd":cmd };
    [[WVRMediator sharedInstance] WVRMediator_ForceLogout:dict];
}

#pragma mark - ready

- (BOOL)requestDataOver {
    
    return (_requestChargedComplete && _parseURLComplete);
}

// 只有需要购买并且尚未购买的视频才会走到试看逻辑
- (BOOL)videoCanTrail {
    
    if (self.videoEntity.streamType == STREAM_VR_LIVE) {
        // 直播试看过一次之后就不允许再次试看
        if ([[WVRAppModel sharedInstance].liveTrailDict objectForKey:self.detailBaseModel.code]) {
            return NO;
        }
    }
    
    if (self.detailBaseModel.freeTime > 0) {
        return YES;
    }
    
    return NO;
}

- (BOOL)checkReadyToPlay {
    
    if (![self requestDataOver]) { return NO; }
    
    if (self.isCharged || [self videoCanTrail]) {
        
        return YES;
    }
    return NO;
}

- (void)readyToPlay {
    
    if (self.vPlayer.isOnBack) { return; }
    
    if ([self checkReadyToPlay]) {
        
        if (_detailBaseModel.isChargeable && _isCharged) {
            
            [[WVRMediator sharedInstance] WVRMediator_PayReportDevice:nil];
        }
        [self actionPlay:NO];
        
    } else if ([self requestDataOver] && ![self videoCanTrail]) {
        // 该视频付费，且无法试看
        [self.playerUI execFreeTimeOverToCharge:0];
    }
}

- (void)createPlayerBottomImage {       // 底图
    
    [self createPlayerFootballBackgroundImageWithVIP:[self.videoEntity isCameraStandVIP]];
    
    [self.chartletManager createPlayerBottomImageWithVideoEntity:[self videoEntity] player:self.vPlayer];
}

- (void)createPlayerFootballBackgroundImageWithVIP:(BOOL)isVIP {       // 180背景图
    
    if (!self.isFootball) {
        
        [self.vPlayer setBackImage:[UIImage imageWithColor:[UIColor clearColor] size:CGSizeMake(1, 1)]];
        return;
    }
    
    [self.chartletManager createPlayerFootballBackgroundImageWithVIP:isVIP ve:[self videoEntity] player:self.vPlayer detailModel:self.detailBaseModel];
}

- (void)createPlayerHelperIfNot {
    
    if (nil == self.vPlayer) {
        self.vPlayer = [[WVRPlayerHelper alloc] initWithContainerView:self.playerContentView MainController:self];
        self.vPlayer.playerDelegate = self;
        self.vPlayer.biModel.screenType = 2;
    }
}

#pragma mark - WVRPlayerViewDelegate

- (void)actionGotoBuy {
    
    if (self.playerUI.playerView.viewStatus == WVRPlayerViewStatusLandscape) {
        
        kWeakSelf(self);
        _buyFromLandscape = YES;
        [self screenRotation:NO completeBlock:^{
            [weakself didGoBuy];
        }];
    } else {
        _buyFromLandscape = NO;
        [self didGoBuy];
    }
}

- (void)didGoBuy {
    
    [self actionPause];
    
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
}

- (void)dealWithPaymentResult:(BOOL)isSuccess {
    
    self.isCharged = isSuccess;
    if (isSuccess) {

        [[WVRMediator sharedInstance] WVRMediator_PayReportDevice:nil];

        [self dealWithPaymentOver];

    } else {
//             允许继续试看
//            [weakself actionOnExit];

        [self actionResume];
    }
}

- (void)actionOnExit {
    if (self.playerUI.playerView.viewStatus == WVRPlayerViewStatusLandscape) {
        
        kWeakSelf(self);
        [self screenRotation:NO completeBlock:^{
            [weakself leftBarButtonClick];
        }];
        
    } else {
        [self leftBarButtonClick];
    }
}

- (void)actionResume {
    
    [self startTimer];
}

- (void)actionPause {
    
    [self stopTimer];
}

#pragma mark - goto Launcher

// 切换到沉浸模式
- (void)changeToVRMode {
    
    if (![[WVRMediator sharedInstance] WVRMediator_isUnityEnvironment:nil]) {
        SQToastInKeyWindow(@"当前为非Unity环境");
        return;
    }
    
    self.vPlayer.dataParam.position = [self.vPlayer getCurrentPosition];
    
    [self stopTimer];
    [self.vPlayer destroyForUnity];
}

- (void)showUnityView {

    [self watch_online_record:NO];
    
    [[WVRMediator sharedInstance] WVRMediator_showU3DView:NO];
    
    NSString *tag = nil;
    
    if ([self.detailBaseModel respondsToSelector:@selector(tags)]) {
        id tmp_tags = [self.detailBaseModel performSelector:@selector(tags)];
        if ([tmp_tags isKindOfClass:[NSString class]]) {
            
            tag = tmp_tags;
        }
    }
    
    double progress = [_vPlayer getCurrentPosition] / (double)[_vPlayer getDuration];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (WVRPlayUrlModel *model in _videoEntity.parserdUrlModelList) {
        [dict setObject:model.url forKey:model.definition];
    }
    
    [[WVRMediator sharedInstance] WVRMediator_setPlayerHelper:self.vPlayer];
    
    WVRUnityActionPlayModel *model = [[WVRUnityActionPlayModel alloc] init];
    model.sid = _videoEntity.sid;
    model.title = _videoEntity.videoTitle;
    model.urlDic = dict;
    model.quality = _videoEntity.curDefinition;
    model.streamType = _videoEntity.streamType;
    model.renderType = _vPlayer.getRenderType;
    model.progress = progress;
    model.tags = tag;
    model.renderTypeStr = self.videoEntity.curUrlModel.renderType;
    
    [[WVRMediator sharedInstance] WVRMediator_sendUnityToPlay:model];
}

- (void)showFootballUnity {
    
    [[WVRMediator sharedInstance] WVRMediator_showU3DView:NO];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    dict[@"behaviour"] = self.detailBaseModel.behavior;
    dict[@"matchId"] = @([[[self.detailBaseModel.behavior componentsSeparatedByString:@"="] lastObject] intValue]);
    dict[@"defaultSlot"] = self.videoEntity.currentStandType;
    
    WVRUnityActionMessageModel *model = [[WVRUnityActionMessageModel alloc] init];
    
    model.message = @"StartScene";
    model.arguments = @[ @"startSoccerVR", @"MatchInfo", [[dict toJsonString] stringByReplacingOccurrencesOfString:@"\\" withString:@""], ];
    
    [[WVRMediator sharedInstance] WVRMediator_sendMsgToUnity:model];
}

#pragma mark - start play

- (void)actionPlay:(BOOL)isRepeat {
    
    [self actionPlay:isRepeat needSeek:NO];
}

- (void)actionPlay:(BOOL)isRepeat needSeek:(BOOL)needSeek {
    
    if (_videoEntity.parserdUrlModelList.count == 0) {
        SQToastInKeyWindow(@"播放链接解析为空！");
        return;
    }
    
    [self createPlayerHelperIfNot];
    
    long position = 0;
    
    if (!isRepeat) {
        
        self.vPlayer.dataParam.isMonocular = YES;
        self.vPlayer.dataParam.isLooping = NO;
        
        if (_videoEntity.streamType == STREAM_2D_TV) {
            
            self.vPlayer.dataParam.url = [(WVRVideoEntityMoreTV *)_videoEntity bestDefinitionUrl];
            self.vPlayer.dataParam.renderType = [WVRVideoEntity renderTypeForStreamType:_videoEntity.streamType definition:_videoEntity.curDefinition renderTypeStr:_videoEntity.renderTypeStr];
            
        } else {
            
            self.vPlayer.dataParam.url = [_videoEntity playUrlForStartPlay];
            self.vPlayer.dataParam.renderType = [WVRVideoEntity renderTypeForStreamType:_videoEntity.streamType definition:_videoEntity.curDefinition renderTypeStr:_videoEntity.curUrlModel.renderType];
            
            if (needSeek) {
                position = [_vPlayer getCurrentPosition];
            } else if (_curPosition > 0) {
                
                position = _curPosition;
                _curPosition = 0;
            }
        }
    }
    
    [self.playerUI execChangeDefiBtnTitle:self.videoEntity.curDefinition];
    
    self.vPlayer.dataParam.position = position;
    self.vPlayer.ve = _videoEntity;
    
    [self.vPlayer setParamAndPlay:self.vPlayer.dataParam];
}

- (void)actionRetry {
    
    // 重新解析URL
    [self buildInitData];
}

- (void)actionSetFullscreen:(BOOL)isFullScreen {
    
    kWeakSelf(self);
    [self screenRotation:isFullScreen completeBlock:^{
        if (!isFullScreen && [weakself.playerUI isHaveStartView]) {
            self.bar.hidden = NO;
        }
    }];
}

- (void)actionSetControlsVisible:(BOOL)isControlsVisible {
    
    if (!_isLandspace) { self.bar.hidden = !isControlsVisible; }
}

#pragma mark - 旋转屏幕

- (void)screenRotation:(BOOL)isLandspace completeBlock:(void (^) ())block {
    
    _isLandspace = isLandspace;
    if (!isLandspace) { [self.vPlayer setMonocular:YES]; }
    
    self.bar.hidden = YES;
    [self.playerUI screenWillRotationWithStatus:isLandspace];
    
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    
    [UIView animateWithDuration:duration animations:^{
        
        [self rotaionAnimations:isLandspace];
        
    } completion:^(BOOL finished) {
        
        [self.playerUI screenRotationCompleteWithStatus:isLandspace];
        if (!isLandspace && !self.vPlayer.curPlaySid) {
            [self.bar setHidden:NO];
        }
        if (block) {
            block();
        }
    }];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    [self invalidNavPanGuesture:isLandspace];
}

- (void)rotaionAnimations:(BOOL)isLandspace {
    
    float width = MIN(SCREEN_WIDTH, SCREEN_HEIGHT);
    float height = roundf(width / 18.f * 11);
    if (_videoEntity.streamType == STREAM_VR_VOD) {
        height = width;
    }
    _shouldAutorotate = YES;
    _supportedInterfaceO = isLandspace ? UIInterfaceOrientationMaskLandscapeRight : UIInterfaceOrientationMaskPortrait;
    [WVRAppModel forceToOrientation:isLandspace ? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationPortrait];
    _shouldAutorotate = NO;
    
    self.playerContentView.frame = isLandspace ? self.navigationController.view.bounds : CGRectMake(0, 0, width, height);
}

#pragma mark - status bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;     // _isLandspace
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    
    return UIStatusBarAnimationFade;
}

- (UIView *)playerContentView {
    
    if (!_playerContentView) {
        
        float width = MIN(SCREEN_WIDTH, SCREEN_HEIGHT);
        float height = roundf(width / 18.f * 11);
        
        if ([self.detailBaseModel.videoType isEqualToString:VIDEO_TYPE_VR]) {
            height = width;
        }
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        view.backgroundColor = [UIColor blackColor];
        [self.view addSubview:view];
        
        _playerContentView = view;
        
        if (bar) { [self.view bringSubviewToFront:bar]; };
    }
    
    return _playerContentView;
}

#pragma mark - 子类实现

- (void)uploadViewCount {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)uploadPlayCount {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (BOOL)reParserPlayUrl {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)playNextVideo {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark - history

- (void)recordHistory {
    if (self.videoEntity.streamType == STREAM_VR_LOCAL || self.videoEntity.streamType == STREAM_VR_LIVE) {
        return;
    }
    if (!self.vPlayer.isOnPrepared) {
        return;
    }
    WVRHistoryModel * historyModel = [WVRHistoryModel new];
    historyModel.programCode = self.videoEntity.sid;
    if ([self isKindOfClass:[WVRTVDetailBaseController class]]) {
        historyModel.programType = PROGRAMTYPE_MORETV;
    } else {
        historyModel.programType = PROGRAMTYPE_PROGRAM;
    }
    historyModel.playTime = [NSString stringWithFormat:@"%ld", [self playerStatus] == 2 ? [_vPlayer getDuration] : [_vPlayer getCurrentPosition]];
    historyModel.totalPlayTime = [NSString stringWithFormat:@"%ld", [_vPlayer getDuration]];
    historyModel.playStatus = [NSString stringWithFormat:@"%ld", [self playerStatus]];
    [WVRPlayerTool recordPlayHistory:historyModel];
}

#pragma mark - orientation

- (BOOL)shouldAutorotate {
    return _shouldAutorotate;
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
    return UIInterfaceOrientationPortrait;
}

@end


