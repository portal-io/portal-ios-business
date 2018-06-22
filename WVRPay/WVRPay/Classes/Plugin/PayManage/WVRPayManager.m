//
//  WVRPayManager.m
//  WhaleyVR
//
//  Created by qbshen on 17/4/13.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRPayManager.h"

#import "WVROrderActionSheet.h"

#import "WVROrderModel.h"
#import "IPNPreSignMessageUtil.h"
#import "IpaynowPluginDelegate.h"
#import "IPNDESUtil.h"
#import "IpaynowPluginApi.h"
#import "WVRPayCallbackLoadingView.h"

//#import "WVRGotoNextTool.h"
//#import "WVRLoginTool.h"
//#import "WVRTabBarController.h"
//#import "WVRProgramPackageController.h"

#import <WVRMediator+Launcher.h>
#import <WVRMediator+AccountActions.h>
#import <WVRMediator+ProgramActions.h>

#import "WVRMyOrderItemModel.h"
#import "WVRPayHeader.h"
#import "WVRPayStatusProtocol.h"
#import "WVRPayCreateOrder.h"
#import "WVRApiHttpPayCallback.h"

#import "WVRInAppPurchaseManager.h"
#import "WVRPayBIModel.h"
//#import "WVRRequestClient.h"
//#import "WVRSectionModel.h"

#import "WVRPayCallbackHandler.h"
#import "WVRCheckPayHandler.h"

#define kMerchantID @"merchant.cn.ipaynow.applepay"
#define APPID  @"1488357918048444"
#define APPKEY @"Y42LeqkJmQTEv6aczXBtNlnxpn42AEgp"
#define MINE_Scheme (@"whaleyvrIpaynow")

#define kCallbackMaxTime (10)   // sec

@interface WVRPayManager ()<IpaynowPluginDelegate, WVROrderActionSheetDelegate>

@property (nonatomic, readonly) UIViewController * gViewController;
@property (nonatomic, weak) UIViewController *fromVC;       // for BI

@property (nonatomic, strong) WVROrderModel * gOrderModel;
/// 存储节目相关信息（每个节目保持唯一）
@property (nonatomic, strong) WVRPayModel * gPayModel;
/// 支付流程传值（点击重新购买则重置）
@property (nonatomic, strong) WVRPayModel * kPayModel;

@property (nonatomic, assign) NSInteger gCallbackRequestCount;
@property (nonatomic, strong) NSTimer * gCallbackRequestTimer;
@property (nonatomic, assign) NSInteger gCallbackRequestSec;

@property (nonatomic, assign) BOOL isCallbackRequesting;

@property (nonatomic, strong) WVRPayCallbackLoadingView * gCallbackLoadingV;

@property (nonatomic, copy) void(^gResultCallbackBlock)(WVRPayManageResultStatus);

@property (nonatomic, assign) WVRPayManageResultStatus gPayResultStatus;

@property (nonatomic, assign) BOOL gPayCallBackSuccess;

@property (nonatomic, assign) BOOL isAlipaying;

@property (nonatomic, strong) WVRPayCreateOrder * gCreateOrder;

@property (nonatomic, strong) NSArray *gSupportPayType;

@property (atomic, assign) BOOL isRequesting;   // request for payMethod list

@property (nonatomic, strong) NSDate *lastPaymentDate;

@property (nonatomic, strong) WVRPayCallbackHandler * gPayCallbackHandler;

@property (nonatomic, strong) WVRCheckPayHandler * gCheckPayHandler;

//one step 判断是直播还是点播，直播直接购买节目包，点播判断点播详情price是否大于0，等于0直接购买节目包，大于0用户选择是购买节目包还是当前节目。

//two step 弹出微信，支付宝选择支付框

//three step 按用户选择调用相应支付平台

//four step 支付回调界面
@property (nonatomic, copy) void(^payProgramPackageBlock)(void);

@end


@implementation WVRPayManager

+ (instancetype)shareInstance {
    
    static WVRPayManager *payM = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        payM = [[WVRPayManager alloc] init];
    });
    return payM;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self registerObserverEvent];
        
        self.gCallbackLoadingV = (WVRPayCallbackLoadingView *)VIEW_WITH_NIB(NSStringFromClass([WVRPayCallbackLoadingView class]));
        self.gCallbackLoadingV.frame = [UIScreen mainScreen].bounds;
    }
    return self;
}

- (WVRPayCallbackHandler *)gPayCallbackHandler
{
    if (!_gPayCallbackHandler) {
        _gPayCallbackHandler = [[WVRPayCallbackHandler alloc] init];
        @weakify(self);
        [[_gPayCallbackHandler successSignal] subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self cms_pay_callbackRequestSuccessBlock];
        }];
        [[_gPayCallbackHandler failSignal] subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self cms_pay_callbackRequestFailBlock];
        }];
    }
    return _gPayCallbackHandler;
}

- (WVRCheckPayHandler *)gCheckPayHandler
{
    if (!_gCheckPayHandler) {
        _gCheckPayHandler = [[WVRCheckPayHandler alloc] init];
       
    }
    return _gCheckPayHandler;
}

- (UIViewController *)gViewController {
    
    UIViewController * curVC = [UIViewController getCurrentVC];
    return curVC;
}

- (void)addLoadingViewIfLogined {
    
    if ([[WVRUserModel sharedInstance] isisLogined]) {
        [[[[UIApplication sharedApplication] delegate] window] addSubview:self.gCallbackLoadingV];
    }
}


+ (NSString *)messageForStatus:(WVRPayManageResultStatus)status {
    
    return @"";
}


#pragma mark - WVRPayStatusProtocol

- (void)updateStatusMsg:(NSString *)msg {
    
    [self.gCallbackLoadingV updateStatusMsg:msg];
}

#pragma mark - WVRPayCreateOrderDelegate

- (void)isHaveOrder {
    
    [self.gCallbackLoadingV updateStatusMsg:@"订单已存在"];
    self.gPayCallBackSuccess = YES;
    [self performSelector:@selector(ishaveOrderDelayTip) withObject:nil afterDelay:1];
}

- (void)ishaveOrderDelayTip {
    
    [self cms_pay_callbackCheck];
}

- (void)createrOrderSuccess:(WVROrderModel *)orderModel {
    
    self.gOrderModel = orderModel;
    [self payWithPlatform];
}

// 支付流程中有接口出现失败
- (void)createOrderFail:(NSString *)errMsg {
    
    [self.gCallbackLoadingV updateStatusMsg:errMsg];
    [self performSelector:@selector(orderCreateFailDelayTip) withObject:nil afterDelay:1];
}

- (void)orderCreateFailDelayTip {
    
    [self.gCallbackLoadingV removeFromSuperview];
    
    [self showPayAlertViewWithType:OrderAlertTypeResultFailed];
}

#pragma mark - external func

- (void)showPayAlertViewWithPayModel:(WVRPayModel *)payModel viewController:(UIViewController *)viewController resultCallback:(void (^)(WVRPayManageResultStatus status))callback {
    
    // 规避用户多次点击事件
    if (_lastPaymentDate && [[NSDate date] timeIntervalSinceDate:_lastPaymentDate] < 1.2) {
        return;
    }
    _lastPaymentDate = [NSDate date];
    
    //初始化状态量
    self.gPayCallBackSuccess = NO;
    if (viewController == nil) {
        viewController = [UIViewController getCurrentVC];
    }
    self.fromVC = viewController;
    
    self.gPayModel = [payModel copy];       // 防止对传入的payModel中的值进行改动
    self.gResultCallbackBlock = callback;
    
    @weakify(self);
    RACCommand *successCmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self);
            BOOL isLogined = [input boolValue];
            if (!isLogined) {
                [self checking_havePay_http_after_login];
            }
            return nil;
        }];
    }];
    
    RACCommand *cancelCmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self);
            [self cancleBtnClick];
            
            return nil;
        }];
    }];
    
    NSDictionary *dict = @{ @"completeCmd":successCmd, @"cancelCmd":cancelCmd };
    
    if (![[WVRMediator sharedInstance] WVRMediator_CheckAndAlertLogin:dict]) {
        [self.gCallbackLoadingV removeFromSuperview];
        return;
    }
    
    [self startPayment];
}

#pragma mark - private func

- (void)startPayment {
    
    // checkPayType流程耗时小于0.25秒，则不显示loading框
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (self.isRequesting) {
            
            [self addLoadingViewIfLogined];
            [self.gCallbackLoadingV updateStatusMsg:kLoading];
        }
    });
    
    [self checkPayType];
    
    [WVRPayBIModel trackEventForPayWithAction:BIPayActionTypeBrowse payModel:self.gPayModel fromVC:self.fromVC];
}

- (void)checkPayType {
    
    self.isRequesting = YES;
    
    kWeakSelf(self);
    [WVRInAppPurchaseManager requestForPayMethodList:^(NSArray *list) {
        
        weakself.isRequesting = NO;
        [weakself parserPayType:list];
    }];
}

- (void)parserPayType:(NSArray *)list {
    
    self.gCallbackLoadingV.alpha = 0;
    self.gSupportPayType = list;
    
    [self checkGoodsTypeAndShowAlertView];
}

- (void)checkGoodsTypeAndShowAlertView {
    
    WVRPayGoodsType goodsType = [self.gPayModel payGoodsType];
    switch (goodsType) {
        case WVRPayGoodsTypeProgram:
        case WVRPayGoodsTypeProgramPackage:
        case WVRPayGoodsTypeProgramAndPackage:
            [self showPayAlertViewWithType:OrderAlertTypePayment];
            break;
        case WVRPayGoodsTypeFree:
            SQToastInKeyWindow(@"商品价格未定，暂时无法购买");
            break;
        default:
            break;
    }
}

- (void)buyInApp {
    
    [self.gCallbackLoadingV removeFromSuperview];
    WVRInAppPurchaseModel * model = [[WVRInAppPurchaseModel alloc] init];
    
    model.goodsNo = self.kPayModel.goodsCode;
    model.price = self.kPayModel.goodsPrice;
    model.goodsType = self.kPayModel.goodsType;
    
    model.relatedCode = self.kPayModel.relatedCode;
    model.relatedType = self.kPayModel.relatedType;
    
    kWeakSelf(self);
    [[WVRInAppPurchaseManager sharedInstance] buyWithPurchaseModel:model completionHandler:^(NSError *error) {
        if (error) {
            weakself.gPayResultStatus = WVRPayManageResultStatusFail;
        } else {
            weakself.gPayResultStatus = WVRPayManageResultStatusSuccess;
        }
        [weakself performSelector:@selector(dismissPayWindow) withObject:nil afterDelay:1];
    }];
}

- (void)payCancleByUser {
    
    [self showPayAlertViewWithType:OrderAlertTypeResultFailed];
}

- (void)cancleBtnClick {
    
    [self.gCallbackLoadingV removeFromSuperview];
    if (self.gResultCallbackBlock) {
        self.gResultCallbackBlock(WVRPayManageResultStatusCancle);
    }
}

- (void)gotoProgramPackageVC {
    
    if (self.payProgramPackageBlock) {
        self.payProgramPackageBlock();
        self.payProgramPackageBlock = nil;
        
        [self showPayAlertViewWithType:OrderAlertTypePayment];
    } else {
        
        [self jumpToProgramPackageVC];
    }
}

#pragma mark - WVROrderActionSheetDelegate

// MARK: - 节目包_专题_合集
- (void)jumpToProgramPackageVC {
    
    // 从合集回来要能继续观看
    [WVRAppModel sharedInstance].shouldContinuePlay = YES;
    
    Class cls = NSClassFromString(@"WVRProgramPackageController");
    UIViewController * vc = [[cls alloc] init];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"linkArrangeType"] = LINKARRANGETYPE_CONTENT_PACKAGE;
    dict[@"linkArrangeValue"] = self.gPayModel.programPackModel.couponDto.relatedCode ?: self.gPayModel.relatedCode;
    
    Class SectionModel = NSClassFromString(@"WVRSectionModel");
    id createArgs = [SectionModel yy_modelWithDictionary:dict];
    
    [vc performSelector:@selector(setCreateArgs:) withObject:createArgs];
    // 注意：当前版本只有用户有节目或节目包可选时才会有跳转按钮， 所以不需要判断，直接从gPayModel.programPackModel取值
    
//    [vc performSelector:@selector(setPrePayResultBlock:) withObject:self.payProgramPackageBlock];
    
    [self.gViewController.navigationController pushViewController:vc animated:YES];
}

/// OrderAlertTypePayment/OrderAlertTypeResultFailed
- (void)showPayAlertViewWithType:(OrderAlertType)alertType {
    
    [self.gCallbackLoadingV removeFromSuperview];
    
    WVRPayModel *payModel = self.gPayModel;
    if (alertType == OrderAlertTypeResultFailed) {
        payModel = self.kPayModel;
    }
    
    kWeakSelf(self);
    WVROrderActionSheet *actionSheet = [[WVROrderActionSheet alloc] initWithType:alertType payList:self.gSupportPayType dataModel:payModel selectedBlock:^(WVRPayPlatform tag, WVRPayGoodsType goodsType) {
        
        if (alertType == OrderAlertTypePayment) {
            
            [weakself createKPayModelWithType:goodsType];
            
            weakself.kPayModel.payPlatform = tag;
            
            [weakself didSelectPayment];
        } else {
            [weakself showPayAlertViewWithType:OrderAlertTypePayment];
        }
        
    } cancelBlock:^{
        [weakself cancleBtnClick];
    }];
    
    actionSheet.realDelegate = self;
    
    [actionSheet showWithAnimate];
}

// actionSheet did select payPlatform
- (void)didSelectPayment {
    
    if (self.kPayModel.payPlatform == WVRPayPlatformAppIn) {
        
        [self buyInApp];
    } else {
        
        [self http_createOrder:self.kPayModel];
    }
}

- (void)createKPayModelWithType:(WVRPayGoodsType)goodsType {
    
    self.kPayModel = [[WVRPayModel alloc] init];
    if (goodsType == WVRPayGoodsTypeProgramPackage && nil != self.gPayModel.programPackModel) {
        
        self.kPayModel.goodsCode = self.gPayModel.programPackModel.couponDto.code;
        self.kPayModel.goodsName = self.gPayModel.programPackModel.couponDto.displayName;
        self.kPayModel.relatedCode = self.gPayModel.programPackModel.couponDto.relatedCode;
        self.kPayModel.relatedType = GOODS_TYPE_CONTENT_PACKGE;
        self.kPayModel.goodsPrice = [self.gPayModel.programPackModel price];
    } else {
        
        self.kPayModel.goodsCode = self.gPayModel.goodsCode;
        self.kPayModel.goodsName = self.gPayModel.goodsName;
        self.kPayModel.goodsPrice = self.gPayModel.goodsPrice;
        self.kPayModel.relatedCode = self.gPayModel.relatedCode;
        self.kPayModel.relatedType = self.gPayModel.relatedType;
    }
    // for BI
    self.kPayModel.payComeFromType = self.gPayModel.payComeFromType;
    self.kPayModel.liveStatus = self.gPayModel.liveStatus;
    self.kPayModel.fromType = self.gPayModel.fromType;
}

- (void)http_createOrder:(WVRPayModel *)payModel {
    
    [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self.gCallbackLoadingV];
    
    if (!self.gCreateOrder) {
        self.gCreateOrder = [[WVRPayCreateOrder alloc] init];
        @weakify(self);
        [self.gCreateOrder.successSignal subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self createrOrderSuccess:x];
        }];
        [self.gCreateOrder.failSignal subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self createOrderFail:x];
        }];
        [self.gCreateOrder.isHaveOrderSignal subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self isHaveOrder];
        }];
        [self.gCreateOrder.payStatusSignal subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self updateStatusMsg:x];
        }];
//        self.gCreateOrder.delegate = self;
    }
    [self.gCreateOrder createOrder:payModel];
}

- (void)payWithPlatform {
    
    if (![self checkPayModelValid]) {
        [self.gCallbackLoadingV updateStatusMsg:kFailCallback];
        [self performSelector:@selector(orderCreateFailDelayTip) withObject:nil afterDelay:1];
        return;
    }
    [self payWithSign:self.gOrderModel.signDataStr];
}

- (BOOL)checkPayModelValid {
    
    if (!self.gOrderModel.signDataStr) {
        DebugLog(@"签名为空");
        return NO;
    }
    return YES;
}

/**
 *   订单签名由业务服务器完成，此处本地签名仅作为展示使用。presignStr带签名字符串应该由服务器签名后返回客户端
 */
- (void)payWithSign:(NSString *)signStr {
    
    if (!signStr) { return; }
    
    [IpaynowPluginApi setLoadingViewHidden:YES];
    [IpaynowPluginApi setBeforeReturnLoadingHidden:YES];
    if (self.kPayModel.payPlatform == WVRPayPlatformAlipay) {
        self.isAlipaying = YES;
    } else {
        self.isAlipaying = NO;
    }
    
    [IpaynowPluginApi pay:signStr AndScheme:MINE_Scheme viewController:self.gViewController delegate:self];
}

#pragma mark - SDK的回调方法
- (void)iPaynowPluginResult:(IPNPayResult)result errorCode:(NSString *)errorCode errorInfo:(NSString *)errorInfo {
    
    self.isAlipaying = NO;
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    NSString *resultString = @"";
    switch (result) {
        case IPNPayResultFail:
            resultString = [NSString stringWithFormat:@"支付失败:\r\n错误码:%@,异常信息:%@", errorCode, errorInfo];
            self.gPayCallBackSuccess = YES;     // sdk返回失败时，把成功上报标记置为YES，只轮询是否购买成功;
            [self cms_pay_callbackCheck];
            break;
        case IPNPayResultCancel:                // 注释改case break 测试成功支付流程
            [self cancelByUser_delay];
            break;
        case IPNPayResultSuccess:
            resultString = kSuccessCallback;    // @"支付成功";
            [self cms_pay_callbackCheck];
            break;
        case IPNPayResultUnknown:
            resultString = [NSString stringWithFormat:@"支付结果未知:%@", errorInfo];
            self.gPayCallBackSuccess = YES;     // sdk返回失败时，把成功上报标记置为YES，只轮询是否购买成功;
            [self cms_pay_callbackCheck];
            break;
        default:
            break;
    }
    DebugLog(@"%@", resultString);
}

- (void)cancelByUser_delay {
    
    [self.gCallbackLoadingV updateStatusMsg:kCancleCallback];
    [self performSelector:@selector(payCancleByUser) withObject:nil afterDelay:1];
}

- (void)cms_pay_callbackCheck {
    
    self.isCallbackRequesting = YES;
    self.gCallbackRequestSec = 0;
    self.gCallbackRequestCount = 0;
    [self.gCallbackLoadingV updateStatusMsg:kWaitingCallback];
    
    [self cms_pay_callbackChecking];
    [self setupTimer];
}

- (void)setupTimer {
    
    if (!self.gCallbackRequestTimer) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerRuning) userInfo:nil repeats:YES];
        
        //将定时器加到循环池中
        [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSDefaultRunLoopMode];
        self.gCallbackRequestTimer = timer;
    }
}

- (void)invalidTimer {
    
    [self.gCallbackRequestTimer invalidate];
    self.gCallbackRequestTimer = nil;
}

//开始轮询callback上报接口
- (void)timerRuning {
    
    [self.gCallbackLoadingV updateStatusMsg:[NSString stringWithFormat:@"%@%d",kWaitingCallback,(int)self.gCallbackRequestSec]];
    if (self.gCallbackRequestSec >= 10) {   // 10秒后返回
        [self cms_pay_callbackFailAfter_five_request_or_ten_sec];
        return;
    }
    self.gCallbackRequestSec ++;
}

//10秒和5次轮询条件是并发的执行
- (void)cms_pay_callbackChecking {
    
    if (self.gCallbackRequestCount > 2) {     //2次后返回
        [self cms_pay_callbackFailAfter_five_request_or_ten_sec];
        return;
    }
    self.gCallbackRequestCount ++;
    
    //创建延迟时间，从当前时间开始，3秒后执行。 3秒需要转化为纳秒,因为该函数是以纳秒为基础进行的
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC);
    //执行延迟函数
    kWeakSelf(self);
    dispatch_after(delay, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DebugLog(@"gCallbackRequestCount:%d", (int)(self.gCallbackRequestCount));
        [weakself http_successPay_callback];
//        [weakself checking_havePay_http];
    });
    
}

- (void)http_successPay_callback {
    
    if (self.gPayCallBackSuccess) {     // callback 成功了就只轮询是否购买接口
        [self checking_havePay_http];
        return;
    }
    self.gPayCallbackHandler.orderNo = self.gOrderModel.orderNo;
    if (self.kPayModel.payPlatform == WVRPayPlatformAlipay) {
        self.gPayCallbackHandler.payMethod = @"alipay";
    } else if (self.kPayModel.payPlatform == WVRPayPlatformWeixin) {
        self.gPayCallbackHandler.payMethod = @"weixin";
    }
    [[self.gPayCallbackHandler payCallbackCmd] execute:nil];

//    WVRApiHttpPayCallback *api = [[WVRApiHttpPayCallback alloc] init];
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    params[kHttpParam_PayCallback_orderNo] = self.gOrderModel.orderNo;  // @"orderno_8aa0a22de40f4272972e4141e00366b3";
//    if (self.kPayModel.payPlatform == WVRPayPlatformAlipay) {
//        params[kHttpParam_PayCallback_payMethod] = @"alipay";
//    } else if (self.kPayModel.payPlatform == WVRPayPlatformWeixin) {
//        params[kHttpParam_PayCallback_payMethod] = @"weixin";
//    }
//
//    NSString *unsign = [[params[kHttpParam_PayCallback_orderNo] stringByAppendingString:params[kHttpParam_PayCallback_payMethod]] stringByAppendingString:[WVRUserModel CMCPURCHASE_sign_secret]];
//    NSString *sign = [WVRGlobalUtil md5HexDigest:unsign];
//    params[kHttpParam_PayCallback_sign] = sign;
//    api.bodyParams = params;
//    kWeakSelf(self);
//    api.successedBlock = ^(WVRNetworkingResponse *data) {
//        NSLog(@"%@", [data contentString]);
//        [weakself cms_pay_callbackRequestSuccessBlock];
//        //[weakself cms_pay_callbackRequestFailBlock];
//    };
//    api.failedBlock = ^(WVRNetworkingResponse *error) {
//        NSLog(@"%@", [error contentString]);
//        [weakself cms_pay_callbackRequestFailBlock];
//    };
//    [api loadData];
//    [self cms_pay_callbackRequestFailBlock];
}

- (void)cms_pay_callbackRequestSuccessBlock {
    
    self.gPayCallBackSuccess = YES;
    [self checking_havePay_http];
}

- (void)cms_pay_callbackRequestFailBlock {
    
    self.gPayCallBackSuccess = YES;//即使上报失败，也认为上报成功
    [self checking_havePay_http];
}

- (void)cms_pay_callbackFailAfter_five_request_or_ten_sec {
    
    self.isCallbackRequesting = NO;
    [self invalidTimer];
    [self.gCallbackLoadingV updateStatusMsg:kFailCallback];
    self.gPayResultStatus = WVRPayManageResultStatusFail;
    
    [self performSelector:@selector(dismissPayWindow) withObject:nil afterDelay:1];
}

- (void)dismissPayWindow {
    
    [self.gCallbackLoadingV removeFromSuperview];
    
    switch (self.gPayResultStatus) {
        case WVRPayManageResultStatusSuccess: {
            
            [WVRPayBIModel trackEventForPayWithAction:BIPayActionTypeSuccess payModel:self.kPayModel fromVC:self.fromVC];
            
            kWeakSelf(self);
            WVROrderActionSheet *actionSheet = [[WVROrderActionSheet alloc] initWithSuccessType:self.kPayModel cancelBlock:^{
                if (weakself.gResultCallbackBlock) {
                    weakself.gResultCallbackBlock(weakself.gPayResultStatus);
                }
            }];
            
            [actionSheet showWithAnimate];
        }
            break;
        case WVRPayManageResultStatusFail:
        case WVRPayManageResultStatusOverTime: {
            
            [self showPayAlertViewWithType:OrderAlertTypeResultFailed];
        }
            break;
            
        default: {
            if (self.gResultCallbackBlock) {
                self.gResultCallbackBlock(self.gPayResultStatus);
            }
        }
            break;
    }
}

#pragma mark - check pay status http

- (void)checking_havePay_http {
    
//    PurchaseProgramType goodsType = [WVRMyOrderItemModel purchaseTypeForGoodType:self.kPayModel.relatedType];
    self.gCheckPayHandler.gPayModel = self.kPayModel;
    @weakify(self);
    [self.gCheckPayHandler.successSignal subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if ([x boolValue]) {
            [self ishavePayBlock];
        } else {
            DebugLog(@"没有购买");
            [self isNotHavePayBlock];
        }
    }];
    [[self.gCheckPayHandler failSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        DebugLog(@"没有购买");
        [self isNotHavePayBlock];
    }];
    [[self.gCheckPayHandler checkPayCmd] execute:nil];
//    kWeakSelf(self);
//    [WVRMyOrderItemModel requestForQueryProgramCharged:self.kPayModel.relatedCode goodsType:goodsType block:^(BOOL isCharged, NSError *error) {
//        if (isCharged) {
//            [weakself ishavePayBlock];
//        } else {
//
//            DebugLog(@"没有购买");
//            [weakself isNotHavePayBlock];
//        }
//    }];
}

// 已购买返回成功
- (void)ishavePayBlock {
    
    [self invalidTimer];
    self.isCallbackRequesting = NO;
    [self.gCallbackLoadingV updateStatusMsg:kSuccessCallback];
    self.gPayResultStatus = WVRPayManageResultStatusSuccess;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NAME_NOTF_MANUAL_ARRANGE_PROGRAMPACKAGE object:nil];
    [self performSelector:@selector(dismissPayWindow) withObject:nil afterDelay:1];
}

//未购买,再次请求是否购买接口
- (void)isNotHavePayBlock {
    
    [self cms_pay_callbackChecking];
}

#pragma mark - check pay status for after login

- (void)checking_havePay_http_after_login {
    
    [self addLoadingViewIfLogined];
    [self.gCallbackLoadingV updateStatusMsg:kLoading];
    
//    NSString * goodsCode = self.gPayModel.relatedCode;
//    [self.gPayModel payGoodsType];
//    PurchaseProgramType goodsType = [WVRMyOrderItemModel purchaseTypeForGoodType:self.gPayModel.relatedType];
    
    self.gCheckPayHandler.gPayModel = self.gPayModel;
    @weakify(self);
    [self.gCheckPayHandler.successSignal subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if ([x boolValue]) {
            [self ishavePayBlock_after_login];
        } else {
            DebugLog(@"没有购买");
            [self isNotHavePayBlock_after_login];
        }
    }];
    [[self.gCheckPayHandler failSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        DebugLog(@"没有购买");
        [self isNotHavePayBlock_after_login];
    }];
    [[self.gCheckPayHandler checkPayCmd] execute:nil];
//    kWeakSelf(self);
//    [WVRMyOrderItemModel requestForQueryProgramCharged:goodsCode goodsType:goodsType block:^(BOOL isCharged, NSError *error) {
//
//        if (isCharged) {
//            [weakself ishavePayBlock_after_login];
//        } else {
//            //if (self.gCallbackRequestCount<=5) {
//            //            [self cms_pay_callbackChecking];
//            DebugLog(@"没有购买");
//            [weakself isNotHavePayBlock_after_login];
//            //} else {
//
//            //}
//        }
//    }];
}

- (void)havePayBefore {
    
    [self.gCallbackLoadingV removeFromSuperview];
    if (self.gResultCallbackBlock) {
        self.gResultCallbackBlock(WVRPayManageResultStatusSuccess);
    }
}

// 用户登录后检测到已购买，返回成功
- (void)ishavePayBlock_after_login {
    
    NSString *msg = @"视频";
    if ([self.gPayModel payComeFromType] == WVRPayComeFromTypeProgramPackage) {
        if (self.gPayModel.packageType == WVRPackageTypeProgramSet) {
            msg = @"合集";
        } else {
            msg = @"节目包";
        }
    }
    msg = [@"您已购买过此" stringByAppendingString:msg];
    [self.gCallbackLoadingV updateStatusMsg:msg];
    [self performSelector:@selector(havePayBefore) withObject:nil afterDelay:1];
}

//未购买,再次请求是否购买接口
- (void)isNotHavePayBlock_after_login {
    
    if (self.gPayModel.fromType == PayFromTypeUnity) {
#warning 需要调用program useCase
        [self re_requestProgramDetailData];
        
    } else {
        [self.gCallbackLoadingV removeFromSuperview];
        if (self.gResultCallbackBlock) {
            self.gResultCallbackBlock(WVRPayManageResultStatusNotHavePay);
        }
    }
}

/// 用户登录后重新拉取详情数据判断视频是否已经购买
- (void)re_requestProgramDetailData {
    
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    dict[@"code"] = self.gPayModel.relatedCode;
//    dict[@"uid"] = [WVRUserModel sharedInstance].accountId;
//    
//    NSString *urlSufix = @"program/findByCode";
//    if (self.gPayModel.payComeFromType == WVRPayComeFromTypeProgramLive) {
//        urlSufix = @"liveProgram/findByCode";
//    } else if (self.gPayModel.payComeFromType == WVRPayComeFromTypeProgramPackage) {
//        urlSufix = @"pack/findByCode";
//        
//        dict[@"size"] = @"1";
//        dict[@"page"] = @"0";
//    }
//    
//    NSString *url = [NSString stringWithFormat:@"%@%@%@", [WVRUserModel kNewVRBaseURL], kAPI_SERVICE, urlSufix];
//    
//    kWeakSelf(self);
//    [WVRRequestClient GETService:url withParams:dict completionBlock:^(NSDictionary *resObj, NSError *error) {
//        
//        int code = [resObj[@"code"] intValue];
//        
//        NSDictionary *resDict = resObj[@"data"][@"pack"];       // content_package
//        if (!resDict) {
//            resDict = resObj[@"data"];
//        }
//        
//        if (!error && code == 200) {
//            
//            WVRPayModel *payModel = [WVRPayModel createWithDict:resDict];
//            
//            BOOL discount_zero = NO;
//            if (payModel.payComeFromType == WVRPayComeFromTypeProgramPackage) {
//                discount_zero = (payModel.goodsPrice == 0);
//            } else {
//                discount_zero = (payModel.programPackModel && payModel.programPackModel.couponDto.price == 0);
//            }
//            
//            if (discount_zero) {
//                // 折扣价格为0，用户已购买
//                [weakself ishavePayBlock_after_login];
//            } else {
//                weakself.gPayModel = payModel;
//                [weakself startPayment];
//            }
//            
//        } else {
//            NSString *msg = [NSString stringWithFormat:@"%@", resObj[@"msg"]];
//            DDLogError(@"WVRPayManager_re_requestProgramDetailData_error: %@", msg);
//            [weakself createOrderFail:kLoadError];
//        }
//    }];
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
    if ([WVRReachabilityModel sharedInstance].isNoNet) {
        
    } else {
        
    }
}

- (void)appWillEnterBackground:(NSNotification *)notification {
    
    [self invalidTimer];
}

- (void)appWillResignActive:(NSNotification *)notification {
    [self invalidTimer];
}

- (void)appDidBecomeActive:(NSNotification *)notification {
    if (self.kPayModel.payPlatform == WVRPayPlatformWeixin) {
        [IpaynowPluginApi willEnterForeground];
    }
    else if (self.kPayModel.payPlatform == WVRPayPlatformAlipay) {
        if (self.isAlipaying) {
            self.isAlipaying = NO;
            [[self class] cancelPreviousPerformRequestsWithTarget:self];
            [self.gCallbackLoadingV updateStatusMsg:kWaitingCallback];
            [self performSelector:@selector(leftTopBackNoCallbcak_delay) withObject:nil afterDelay:3];
        }
    } else {
        [self.gCallbackLoadingV removeFromSuperview];
    }
    if (self.isCallbackRequesting) {
        [self setupTimer];
    }
}

// 首次打开微信支付宝取消后超时问题
- (void)leftTopBackNoCallbcak_delay {
    
    [self.gCallbackLoadingV updateStatusMsg:kPayOverTime];
    self.gPayResultStatus = WVRPayManageResultStatusOverTime;
    [self performSelector:@selector(dismissPayWindow) withObject:nil afterDelay:1];
}

#pragma mark - helpless func for a singleton object

- (void)dealloc {
    
    DebugLog(@"");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self invalidTimer];
}

@end
