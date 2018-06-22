//
//  WVRPlayerVC.m
//  WhaleyVR
//
//  Created by Snailvr on 2016/11/18.
//  Copyright © 2016年 Snailvr. All rights reserved.
//
// 全屏播放控制器基类，请勿直接使用
// 目前支持全屏播放的类型有：点播VR全景视频、直播全景视频、本地缓存全景视频

#import "WVRPlayerVC.h"
#import "WVRNavigationController.h"

#import "WVRHistoryModel.h"
#import "WVRPlayerTool.h"

#import "WVRProgramPackageController.h"
#import "WVRVideoEntityLocal.h"
#import "WVRWatchOnlineRecord.h"
#import "WVRDeviceModel.h"

#import <ReactiveObjC/ReactiveObjC.h>
#import "WVRChartletManager.h"

#import "WVRMediator+UnityActions.h"
#import "WVRMediator+PayActions.h"
#import <WVRMediator+AccountActions.h>

@interface WVRPlayerVC () {
    
    long _isLowFps;
    BOOL _isVipBackground;
}

@property (nonatomic, weak  ) NSTimer  *timer;

@property (assign, atomic) BOOL parseURLComplete;         // 解析链接完成
@property (atomic, assign) BOOL requestChargedComplete;   // 请求是否付费完成

@property (nonatomic, strong) WVRWatchOnlineRecord * gwOnlineRecord;

//@property (nonatomic, assign) BOOL gStartForDiddisapper;

@property (nonatomic, strong) WVRChartletManager *chartletManager;

@end


@implementation WVRPlayerVC
@synthesize videoEntity = _tmpVideoEntity;   // set get 方法已经被子类重写，tmpVideoEntity可能为nil
@synthesize playerUI = _tmpPlayerUI;         // 请使用get方法调用

#pragma mark - life cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [WVRAppModel sharedInstance].shouldContinuePlay = YES;
    
    [[WVRMediator sharedInstance] WVRMediator_ReportLostInAppPurchaseOrders];
    
    [self configureSelf];
    [self buildData];
    
    [self createLayoutView];
    [self buildInitData];

    [self registerObserverEvent];       // 只能执行一次
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [(WVRNavigationController *)self.navigationController setGestureInValid:YES];
    [WVRAppModel sharedInstance].preVcisOrientationPortraitl = YES;
    
    if (![WVRAppModel sharedInstance].shouldContinuePlay) { return; }
    [WVRAppModel sharedInstance].shouldContinuePlay = NO;
    
    [self.playerUI execResumeForControllerChanged];
    
    self.view.window.backgroundColor = [UIColor blackColor];
    
    if (self.vPlayer.isValid && self.vPlayer.isPrepared) {
        
        BOOL success = [self.vPlayer onResume];
        if (success) {
            [self.playerUI execPlaying];
        }
        [self startTimer];
        
    } else if (self.vPlayer.isFreeTimeOver) {
        
        // 试看结束后回来，不自动开播
        
    } else if (self.vPlayer.isOnDestroy || self.vPlayer.isReleased) {
        
        [self performSelector:@selector(backFromUnityAndPlay) withObject:nil afterDelay:0.3];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.view.window.backgroundColor = [UIColor whiteColor];
    [(WVRNavigationController *)self.navigationController setGestureInValid:NO];
    
    [self recordHistory];
    [self watch_online_record:NO];
    
    [self.playerUI execSleepForControllerChanged];
//    self.gStartForDiddisapper = YES;
    
    if (self.vPlayer.isValid) {
        if (!self.navigationController && !self.presentingViewController) {
            [_vPlayer onBackForDestroy];
        } else {
            self.vPlayer.dataParam.position = [self.vPlayer getCurrentPosition];
        
            [self.vPlayer destroyPlayer];
            [self.playerUI execSuspend];
        }
    }
    [self stopTimer];
    
    self.view.window.backgroundColor = [UIColor whiteColor];
}

- (void)dealloc {
    
    DDLogInfo(@"WVRPlayerVC - dealloc");
    
    [self stopTimer];
    [_vPlayer onBackForDestroy];
    
    [self.playerUI execDestroy];
    
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
    } @catch (NSException *exception) {
        DDLogError(@"%@", exception.reason);
    }
}

#pragma mark - event

- (void)backFromUnityAndPlay {
    
    if (self.vPlayer.isOnDestroy || self.vPlayer.isReleased) {
        
        [self.playerUI execStalled];
        [self.vPlayer setParamAndPlay:self.vPlayer.dataParam];
        [self startTimer];
        
    } else {
        [self readyToPlay];
    }
}

- (void)watch_online_record:(BOOL)isComin {
    
    NSString * contentType = @"live";
    switch (self.videoEntity.streamType) {
        case STREAM_3D_WASU:
        case STREAM_VR_VOD:
        case STREAM_2D_TV:
            
            contentType = @"recorded";
            break;
            
        case STREAM_VR_LIVE:
            contentType = @"live";
            break;
            
        case STREAM_VR_LOCAL:
            return;
            break;
        default:
            return;
            break;
    }
    WVRWatchOnlineRecordModel * recordModel = [WVRWatchOnlineRecordModel new];
    recordModel.code = self.videoEntity.sid;
    recordModel.contentType = contentType;
    recordModel.type = [NSString stringWithFormat:@"%d",isComin];
    recordModel.deviceNo = [WVRUserModel sharedInstance].deviceId;
    if (isComin) {
        [self.gwOnlineRecord http_watch_online_record:recordModel];
    } else {
        [self.gwOnlineRecord http_watch_online_unrecord:recordModel];
    }
}

#pragma mark - dismiss

- (void)dismissViewController {
    
    [self stopTimer];
    
    [_vPlayer onBackForDestroy];
    [WVRAppModel forceToOrientation:UIInterfaceOrientationPortrait];
    
    if ([self presentingViewController]) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    } else {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - ready to play

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
    
    if ([self checkReadyToPlay]) {
        
        if (_detailBaseModel.isChargeable && self.isCharged) {
            
            [[WVRMediator sharedInstance] WVRMediator_PayReportDevice:nil];
        }
        [self actionPlay:NO];
        
    } else if ([self requestDataOver] && ![self videoCanTrail]) {
        // 该视频付费，且无法试看
        [self.playerUI execFreeTimeOverToCharge:0];
    }
}

/// 检测支付/支付流程结束 调用
- (void)dealWithPaymentOver {
    
    if (self.vPlayer.isValid) {
        
        if (self.isCharged || self.vPlayer.getCurrentPosition/1000.f < _detailBaseModel.freeTime) {
            
            [self.vPlayer start];
            [self startTimer];
            
            if (self.isCharged) {
                [self.playerUI execPaymentSuccess];
            }
            if ([self.vPlayer isPlaying]) {
                [self.playerUI execPlaying];
            }
        }
        
    } else if (self.vPlayer.isOnDestroy || self.vPlayer.isReleased) {
        
        WVRDataParam *dataM = self.vPlayer.dataParam;
        dataM.position = [self.vPlayer getCurrentPosition];
        [self.vPlayer setParamAndPlay:dataM];
        
        if (self.isCharged) {
            [self.playerUI execPaymentSuccess];
        }
        [self.playerUI execWaitingPlay];
        
    } else {
        [self readyToPlay];
    }
}

#pragma mark - getter

- (WVRVideoEntity *)videoEntity {
    
    return _tmpVideoEntity;
}

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
    
    [self.playerUI resetVRMode];
    
    if (!self.gwOnlineRecord) {
        self.gwOnlineRecord = [WVRWatchOnlineRecord new];
    }
    if (!self.vPlayer) {
        
        self.vPlayer = [[WVRPlayerHelper alloc] initWithContainerView:self.view MainController:self];
        self.vPlayer.playerDelegate = self;
        self.vPlayer.biModel.screenType = 1;
    }
    
    if (self.videoEntity.streamType == STREAM_VR_LOCAL) {
        
        _requestChargedComplete = YES;
        self.isCharged = YES;
        
        [self playerInitData];
        
    } else {
        
        [self requestForDetailData];
    }
}

// 付费流程检测
- (void)checkForCharge {
    
    self.isCharged = NO;
    
    BOOL chargeable = self.detailBaseModel.isChargeable;
    BOOL notFree = YES;     // (self.detailBaseModel > 0)
    
    if (chargeable && notFree) {
        
        [self requestForPaied];
    } else {
        _requestChargedComplete = YES;
        self.isCharged = YES;
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
    [self readyToPlay];
}

// 子类重写
- (void)requestForDetailData {
    
}

- (void)dealWithDetailData:(WVRItemModel *)model {
    
    self.videoEntity.biEntity.playCount = (long)model.playCount.longLongValue;
    self.videoEntity.needParserURL = model.playUrl;
    self.videoEntity.needParserURLDefinition = [model definitionForPlayURL];
    self.videoEntity.relatedCode = model.relatedCode;
    self.videoEntity.biEntity.videoTag = model.tags;
    self.videoEntity.needCharge = model.isChargeable;
    self.videoEntity.freeTime = model.freeTime;
    self.videoEntity.price = model.couponDto.price ?: [[model contentPackageQueryDto] price];
    self.videoEntity.behavior = model.behavior;
    self.videoEntity.bgPic = model.bgPic;
    self.videoEntity.contentType = model.type;
    self.videoEntity.biEntity.totalTime = ((WVRVideoDetailVCModel *)model).duration.intValue;
    
    self.isFootball = [model isFootball];
    self.videoEntity.isFootball = self.isFootball;
    
    self.detailBaseModel = model;
    
    [self checkForCharge];
    [self playerInitData];
    
    [self.playerUI setIsFootball:self.isFootball];
}

- (void)playerInitData {
    
    _parseURLComplete = NO;
    
    kWeakSelf(self);
    
    [self.videoEntity parserPlayUrl:^{
        
        if (weakself.vPlayer.isOnBack) { return; }
        
        if (weakself.videoEntity.parserdUrlModelList.count > 0) {
            
            DDLogInfo(@"parserPlayUrl 解析成功");
            weakself.parseURLComplete = YES;
            [weakself.playerUI exeUpdateDefineTitle];
        } else {
            weakself.parseURLComplete = NO;
            
            BOOL netOK = [WVRReachabilityModel isNetWorkOK];
            NSString *err = netOK ? kNoNetAlert : kLinkError;
            [self dealWithError:err code:(netOK ? -3000 : -1000)];
        }
        
        [weakself readyToPlay];
    }];
}

- (void)dealWithError:(NSString *)err code:(int)code {
    
    [self.playerUI execError:err code:code];
    [self.vPlayer playError:err code:code videoEntity:self.videoEntity];
}

#pragma mark - init layoutView

- (void)configureSelf {
    
    self.view.backgroundColor = [UIColor blackColor];
    self.view.window.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)buildData {
    
    _isLowFps = 5;
    _syncScrubberNum = 0;    // 轮询计数
    
    [self playerUI];
    
    [self setupRequestRAC];
}

- (void)setupRequestRAC {
    
    @throw [NSException exceptionWithName:@"error" reason:@"You Must OverWrite This Function In SubClass" userInfo:nil];
}

- (void)createLayoutView {
    
    [self.playerUI createPlayerViewWithContainerView:self.view];
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

// onGLKDealloc 的时候调用
- (void)showUnityView {
    
    if ([self.detailBaseModel isFootball]) {
        [self showFootballUnity];
    } else {
        [self showCommonLiveUnity];
    }
}

- (void)showFootballUnity {
    
    [[WVRMediator sharedInstance] WVRMediator_showU3DView:NO];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
    dict[@"behaviour"] = self.videoEntity.behavior;
    dict[@"matchId"] = @([[[self.videoEntity.behavior componentsSeparatedByString:@"="] lastObject] intValue]);
    dict[@"defaultSlot"] = self.videoEntity.currentStandType;
    
    WVRUnityActionMessageModel *model = [[WVRUnityActionMessageModel alloc] init];
    model.message = @"StartScene";
    model.arguments = @[ @"startSoccerVR", @"MatchInfo", [[dict toJsonString] stringByReplacingOccurrencesOfString:@"\\" withString:@""], ];
    
    [[WVRMediator sharedInstance] WVRMediator_sendMsgToUnity:model];
}

- (void)showCommonLiveUnity {
    
    [[WVRMediator sharedInstance] WVRMediator_showU3DView:NO];
    
    NSString *tag = nil;
    if ([self.detailBaseModel isKindOfClass:[WVRVideoDetailVCModel class]]) {
        WVRVideoDetailVCModel *model = (WVRVideoDetailVCModel *)self.detailBaseModel;
        tag = model.tags;
    }
    
    double progress = [_vPlayer getCurrentPosition] / (double)[_vPlayer getDuration];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (WVRPlayUrlModel *model in self.videoEntity.parserdUrlModelList) {
        [dict setObject:model.url forKey:model.definition];
    }
    [[WVRMediator sharedInstance] WVRMediator_setPlayerHelper:self.vPlayer];
    
    WVRUnityActionPlayModel *model = [[WVRUnityActionPlayModel alloc] init];
    model.sid = self.videoEntity.sid;
    model.title = self.videoEntity.videoTitle;
    model.urlDic = dict;
    model.quality = self.videoEntity.curDefinition;
    model.streamType = self.videoEntity.streamType;
    model.renderType = _vPlayer.getRenderType;
    model.progress = progress;
    model.tags = tag;
    model.renderTypeStr = self.videoEntity.curUrlModel.renderType;
    
    [[WVRMediator sharedInstance] WVRMediator_sendUnityToPlay:model];
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
    
    [self recordHistory];
    [self stopTimer];
    [self watch_online_record:NO];
    
    if (self.videoEntity.streamType != STREAM_VR_LOCAL) {
        BOOL netOK = [WVRReachabilityModel isNetWorkOK];
        if (!netOK) {
            [self.playerUI execSuspend];
            return;
        }
    }
    
    // 专题连播
    if ([self.videoEntity canPlayNext]) {
        
        [self.videoEntity nextVideoEntity];
        [self buildInitData];
        [self.playerUI execWaitingPlay];
    } else {
        
        [self.playerUI execComplete];
    }
}

- (void)onError:(int)what {
    self.curPosition = [self.vPlayer getCurrentPosition];
    NSString *err = [NSString stringWithFormat:@"%d", what];
    
    [self stopTimer];
    
    if (self.videoEntity.canTryNext) {
        
        [self.videoEntity nextVideoEntity];
        [self buildInitData];
        [self.playerUI execWaitingPlay];
        
    } else if (self.videoEntity.streamType == STREAM_VR_LIVE) {
        // 子类已重写该方法
    } else {
        BOOL netOK = [WVRReachabilityModel isNetWorkOK];
        [self dealWithError:err code:(netOK ? -2000 : -1000)];
    }
}

// 播放卡顿
- (void)onBuffering {
    
    [self.playerUI execStalled];
}

- (void)onBufferingOff {
    
    [self startTimer];
    [self.playerUI execPlaying];
}

- (void)onGLKVCdealloc {
    
    [self showUnityView];
}

#pragma mark - timer

- (void)startTimer {
    
    if ([_timer isValid]) { return; }
    
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
    
    // 保护
    if (![self isCurrentViewControllerVisible]) { return; }
    if (nil == [self.vPlayer curPlaySid]) { return; }           // 播放器尚未初始化
    
    long speed = [[WVRAppModel sharedInstance] checkInNetworkflow];
    
    if (![_vPlayer isPlaying]) {
        
        [self.playerUI execDownloadSpeedUpdate:speed];
    } else {
        
        [self checkFreeTime];
        
        if (self.syncScrubberNum % 10 == 0 && self.isCharged && _detailBaseModel.isChargeable) {
            
            [self checkDeviceForVipVideo];
        }
    }
    if ([_vPlayer isPlaying] || [_vPlayer isOnBuffering]) {
        
        float fps = [_vPlayer getFps];
        if (fps < 15 && _isLowFps >= 5) {
            
            self.videoEntity.biEntity.bitrate = fps;
            [_vPlayer trackEventForLowbitrate];
            _isLowFps = 0;      // not track in 5 second
        }
    }
    
    _isLowFps ++;
    _syncScrubberNum ++;
}

- (void)checkDeviceForVipVideo {
//    kWeakSelf(self);
//    [WVRMyOrderItemModel requestForDeviceCheck:^(BOOL signSuccess) {
//        if (!signSuccess) {
//            [weakself.vPlayer stop];
//            [weakself stopTimer];
//            [WVRLoginTool forceLogout:^{
//                [weakself dismissViewController];
//            }];
//        }
//    }];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    RACCommand *cmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            
            [self dealWithDeviceCheckFailed];
            
            return nil;
        }];
    }];
    param[@"cmd"] = cmd;
    
    [[WVRMediator sharedInstance] WVRMediator_CheckDevice:param];
}

- (void)dealWithDeviceCheckFailed {
    
    [self.vPlayer stop];
    [self stopTimer];
    
    @weakify(self);
    RACCommand *cmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            
            @strongify(self);
            [self dismissViewController];
            return nil;
        }];
    }];
    NSDictionary *param = @{ @"cmd":cmd };
    [[WVRMediator sharedInstance] WVRMediator_ForceLogout:param];
}

- (void)checkFreeTime {
    // 子类有需求实现
}

#pragma mark - WVRPlayerUIManagerDelegate

// live中已重写，目前除了直播，其他视频还没有在全屏播放器页支付的需求（20170711）
- (void)actionGotoBuy {
    
    [self.view.window endEditing:YES];
    
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
//         允许继续试看
//        [weakself actionOnExit];
        
        [self actionResume];
    }
}

- (void)actionOnExit {
    
    [self dismissViewController];
}

- (void)actionResume {
    
    [self startTimer];
}

- (void)actionPause {
    
    [self stopTimer];
}

// 是否为播放结束后再次播放
- (void)actionPlay:(BOOL)isRepeat {
    
    if (self.videoEntity.parserdUrlModelList.count == 0) {
        SQToastInKeyWindow(@"播放链接解析为空！");
        return;
    }
    
    long position = 0;
    if (!isRepeat) {
        
        self.vPlayer.dataParam.url = [self.videoEntity playUrlForStartPlay];
        self.vPlayer.dataParam.renderType = [WVRVideoEntity renderTypeForStreamType:self.videoEntity.streamType definition:self.videoEntity.curDefinition renderTypeStr:self.videoEntity.curUrlModel.renderType];
        
        self.vPlayer.dataParam.isMonocular = !self.videoEntity.isDefaultVRMode;
        
        [self.playerUI execChangeDefiBtnTitle:self.videoEntity.curDefinition];
        
        if (self.isCharged) {
            [self.playerUI execPaymentSuccess];
            [self.playerUI execWaitingPlay];
        }
        
        if (self.videoEntity.streamType == STREAM_VR_LOCAL) {
            
//            self.vPlayer.dataParam.framOritation = ((WVRVideoEntityLocal *)self.videoEntity).oritaion;
            self.vPlayer.dataParam.renderType = ((WVRVideoEntityLocal *)self.videoEntity).renderType;
            
        } else {
            
            if (_curPosition > 0) {
                
                position = _curPosition;
                _curPosition = 0;
            }
        }
    }
    
    self.vPlayer.dataParam.position = position;
    self.vPlayer.ve = self.videoEntity;
    
    [self.vPlayer setParamAndPlay:self.vPlayer.dataParam];
}

- (void)actionRetry {
    
    DebugLog(@"");
    [self buildInitData];   // 重新解析URL
}

#pragma mark - Notification

- (void)registerObserverEvent {      // 界面"暂停／激活"事件注册
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged:) name:kNetStatusChagedNoti object:nil];
    
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
    
    // 保护
    if (![self isCurrentViewControllerVisible]) { return; }
    
//    [self.playerUI execNetworkStatusChanged];
}

- (void)appWillEnterForeground:(NSNotification *)notification {
    
    // 保护
    if (![self isCurrentViewControllerVisible] || !self.vPlayer.isValid) { return; }
    
    if (self.videoEntity.streamType != STREAM_VR_LIVE && [self isCurrentViewControllerVisible]) {
        
        [WVRAppModel forceToOrientation:UIInterfaceOrientationLandscapeRight];
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
    
    if (self.videoEntity.streamType == STREAM_VR_LIVE && [self.vPlayer isPaused]) {
        
        // BUG #8594 直播节目播放时，分享到第三方app，回到app，直播会停住
        if ([self isClearInWindow]) {
            
            [self.vPlayer start];
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if ([self.vPlayer isPlaying]) {
            [self.playerUI execPlaying];
            [self startTimer];
        }
    });
}

#pragma mark - 私有方法

- (void)controlOnPause {
    
    [self stopTimer];
    [self.vPlayer onPause];
    [self.playerUI execSuspend];
}

- (void)controlOnResume {
    
    [self startTimer];
    
    BOOL success = [self.vPlayer onResume];
    if (success) {
        [self.playerUI execPlaying];
    }
}

#pragma mark - record history

- (HistoryPlayStatus)playerStatus {
    
    NSInteger status = HistoryPlayStatusUnknow;
    if (self.vPlayer.isComplete) {
        status = HistoryPlayStatusComplate;
    } else if (self.vPlayer.isPlaying) {
        status = HistoryPlayStatusPlaying;
    }
    return status;
}

// 已经将直播类和本地视频播放recordHistory重写为空方法
- (void)recordHistory {
    
    if (!self.vPlayer.isPrepared) {
        return;
    }
    WVRHistoryModel * historyModel = [WVRHistoryModel new];
    historyModel.programCode = self.videoEntity.sid;
    if (self.videoEntity.streamType == STREAM_2D_TV) {
        historyModel.programType = PROGRAMTYPE_MORETV;
    } else {
        historyModel.programType = PROGRAMTYPE_PROGRAM;
    }
    historyModel.playTime = [NSString stringWithFormat:@"%ld", [self playerStatus] == HistoryPlayStatusComplate ? [self.vPlayer getDuration] : [self.vPlayer getCurrentPosition]];
    historyModel.totalPlayTime = [NSString stringWithFormat:@"%ld", [self.vPlayer getDuration]];
    historyModel.playStatus = [NSString stringWithFormat:@"%ld", [self playerStatus]];
    
    [WVRPlayerTool recordPlayHistory:historyModel];
}

#pragma mark - status bar

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

#pragma mark - orientation setting

- (BOOL)shouldAutorotate {
    
    return NO;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    
    return UIInterfaceOrientationLandscapeRight;
}

@end
