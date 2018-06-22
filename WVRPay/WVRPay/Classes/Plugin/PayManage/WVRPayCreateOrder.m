//
//  WVRPayCreateOrder.m
//  WhaleyVR
//
//  Created by qbshen on 2017/5/2.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRPayCreateOrder.h"
#import "WVROrderModel.h"
#import "WVRPayModel.h"
#import "WVRApiHttpCreateOrder.h"
#import "WVRPayStatusProtocol.h"
#import "WVRPayHeader.h"
#import "WVRCreateOrderUseCase.h"
#import "WVRErrorViewModel.h"

@interface WVRPayCreateOrder ()

@property (nonatomic, strong) WVRCreateOrderUseCase * gCreateOrderUC;

@property (nonatomic, strong) WVRPayModel * gPayModel;

@property (nonatomic, strong) RACSubject * gSuccessSubject;

@property (nonatomic, strong) RACSubject * gFailSubject;

@property (nonatomic, strong) RACSubject * gIsHaveOrderSubject;

@property (nonatomic, strong) RACSubject * gPayStatusSubject;

@end


@implementation WVRPayCreateOrder
@synthesize successSignal = _successSignal;
@synthesize failSignal = _failSignal;
@synthesize isHaveOrderSignal = _isHaveOrderSignal;
@synthesize payStatusSignal = _payStatusSignal;

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self installRAC];
    }
    return self;
}

-(WVRCreateOrderUseCase *)gCreateOrderUC
{
    if (!_gCreateOrderUC) {
        _gCreateOrderUC = [[WVRCreateOrderUseCase alloc] init];
    }
    return _gCreateOrderUC;
}

-(void)installRAC
{
    RAC(self.gCreateOrderUC, goodCode) = RACObserve(self, gPayModel.goodsCode);
    RAC(self.gCreateOrderUC, goodType) = RACObserve(self, gPayModel.goodsType);
    RAC(self.gCreateOrderUC, goodPrice) = RACObserve(self, gPayModel.goodsPrice);
    RAC(self.gCreateOrderUC, payPlatform) = RACObserve(self, gPayModel.payPlatform);
    
    @weakify(self);
    [[self.gCreateOrderUC buildUseCase] subscribeNext:^(WVROrderModel*  _Nullable x) {
        @strongify(self);
        [self createOrderSuccessBlock:x];
    }];
    [[self.gCreateOrderUC buildErrorCase] subscribeNext:^(WVRErrorViewModel*  _Nullable error) {
        @strongify(self);
        NSLog(@"%@", error.errorMsg);
        [self createOrderFailBlock:@"网络异常，订单创建失败"];
    }];
}

-(void)createOrder:(WVRPayModel*)payModel
{
    if (![self checkCreateOrderParamValid:payModel]) {
        [self.gFailSubject sendNext:kCreateFail];
        return;
    }
    [self.gPayStatusSubject sendNext:kWaiting];
    [[self.gCreateOrderUC createOrderCmd] execute:nil];
}

//- (void)http_createOrder:(WVRPayModel *)payModel {
//
//    if (![self checkCreateOrderParamValid:payModel]) {
//        [self.delegate createOrderFail:kCreateFail];
//        return;
//    }
//    [self.delegate updateStatusMsg:kWaiting];
//    WVRApiHttpCreateOrder *api = [[WVRApiHttpCreateOrder alloc] init];
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//
//    params[kHttpParam_CreateOrder_uid] = payModel.userId;           // @"79260774";
//    params[kHttpParam_CreateOrder_goodsNo] = payModel.goodsCode;    // @"047c7a8ea9c7444fa95590296114c3c3";
//    params[kHttpParam_CreateOrder_goodsType] = payModel.goodsType;           // @"recorded";
//    params[kHttpParam_CreateOrder_price] = [NSString stringWithFormat:@"%ld", payModel.goodsPrice];     // @"1";
//
//    switch (payModel.payPlatform) {
//        case WVRPayPlatformWeixin:
//            params[kHttpParam_CreateOrder_payMethod] = @"weixin";
//            break;
//        case WVRPayPlatformAlipay:
//            params[kHttpParam_CreateOrder_payMethod] = @"alipay";
//            break;
//        default:
//            params[kHttpParam_CreateOrder_payMethod] = @"";
//            break;
//    }
//
//    NSString *unSignStr = [NSString stringWithFormat:@"%@%@%@%@%@%@", params[kHttpParam_CreateOrder_uid], params[kHttpParam_CreateOrder_goodsNo], params[kHttpParam_CreateOrder_goodsType], params[kHttpParam_CreateOrder_price], params[kHttpParam_CreateOrder_payMethod], [WVRUserModel CMCPURCHASE_sign_secret]];
//
//    NSString *signStr = [WVRGlobalUtil md5HexDigest:unSignStr];
//    params[kHttpParam_CreateOrder_sign] = signStr;
//    api.bodyParams = params;
//    kWeakSelf(self);
//    api.successedBlock = ^(WVROrderModel *orderModel) {
//        [weakself createOrderSuccessBlock:orderModel];
//    };
//    api.failedBlock = ^(WVRNetworkingResponse *error) {
//        if ([error respondsToSelector:@selector(contentString)]) {
//            NSLog(@"%@", error.contentString);
//        }
//        [weakself createOrderFailBlock:@"网络异常，订单创建失败"];
//        //[weakself createOrderSuccessBlock:[WVROrderModel new]];
//    };
//    [api loadData];
//}

- (BOOL)checkCreateOrderParamValid:(WVRPayModel *)payModel
{
    if (payModel.payPlatform == WVRPayPlatformUN) {
        DebugLog(@"支付方式未知");
        return NO;
    }
    if(!payModel.userId){
        DebugLog(@"userId 为空");
//        SQToastInKeyWindow(@"订单创建失败");
        return NO;
    }
    if (!payModel.goodsCode) {
        DebugLog(@"goodsCode为空");
//        SQToastInKeyWindow(@"订单创建失败");
        return NO;
    }
    if (!payModel.goodsType) {
        DebugLog(@"goodsType为空");
//        SQToastInKeyWindow(@"订单创建失败");
        return NO;
    }
    if (payModel.goodsPrice == 0) {
        DebugLog(@"goodsPrice == 0");
//        SQToastInKeyWindow(@"订单创建失败");
        return NO;
    }
    return YES;
}

- (void)createOrderSuccessBlock:(WVROrderModel * )orderModel
{
//    self.gOrderModel = orderModel;
    //[self testOrderModel];
    [self.gPayStatusSubject sendNext:kBtnFirstTitle];
//    [self.delegate updateStatusMsg:kBtnFirstTitle];
    [self parseStatusCode:orderModel];
}

//- (void)testOrderModel
//{
//    self.gOrderModel.orderNo = @"1";
//    self.gOrderModel.goodsName = @"goodsName";
//    self.gOrderModel.goodsPrice = 1;
//    self.gOrderModel.orderDetail = @"goodsDetail";
//    self.gOrderModel.orderStartTime = @"100";
//    self.gOrderModel.notifyUrl = @"www.baidu.com";
//    self.gOrderModel.mhtReserved = @"1";
//}

- (void)createOrderFailBlock:(NSString * )errorMsg {
    [self.gFailSubject sendNext:errorMsg];
//    [self.delegate createOrderFail:@"网络异常，订单创建失败"];
}


/*
 code	subCode	msg	remark
 200	000	success	目前系统正常返回都是200
 400	001	用户id为空
 400	002	商品编码为空
 400	004	商品类型为空
 400	005	商品价格为空
 400	007	商品信息不存在
 400	008	商品价格错误
 400	010	商品非付费错误
 400	014	签名参数为空
 400	015	订单已成功支付
 400	016	app已成功支付，第三方未回调
 401	000	auth error	鉴权失败
 500	000	server error	系统异常
 */
- (void)parseStatusCode:(WVROrderModel * )orderModel
{
    NSInteger statusCode = [orderModel.statusCode integerValue];
    
    switch (statusCode) {
        case 200:
            [self parseSubStatusCode_200:orderModel];
            break;
        case 400:
            [self parseSubStatusCode_400:orderModel];
            break;
        case 401:
            [self parseSubStatusCode_401:orderModel];
            break;
        case 500:
            [self parseSubStatusCode_500:orderModel];
            break;
        default:
            break;
    }
    if (statusCode == 200) {
        
    }else if(statusCode > 400){
        [self.gFailSubject sendNext:kCreateFail];
//        [self.delegate createOrderFail:kCreateFail];
        // [self testShowPayAlertView];//模拟成功
        //[self payWithPlatform:self.gPayModel.payPlatform];
    }
}

- (void)parseSubStatusCode_200:(WVROrderModel * )orderModel
{
    NSInteger subStatusCode = [orderModel.subStatusCode integerValue];
    switch (subStatusCode) {
        case 0:
            NSLog(@"订单创建成功");
            //[self showPayAlertView];
            //SQToastInKeyWindow(@"订单创建成功");
//            [self.delegate updateStatusMsg:kBtnFirstTitle];
//             [self.delegate createrOrderSuccess:orderModel];
            [self.gSuccessSubject sendNext:orderModel];
            break;
        default:
            
            break;
    }
    
}

- (void)parseSubStatusCode_400:(WVROrderModel * )orderModel
{
    NSInteger subStatusCode = [orderModel.subStatusCode integerValue];
    switch (subStatusCode) {
        case 1:
            DebugLog(@"用户id为空");
            break;
        case 2:
            DebugLog(@"商品编码为空");
            break;
        case 4:
            DebugLog(@"商品类型为空");
            break;
        case 5:
            DebugLog(@"商品价格为空");
            break;
        case 7:
            DebugLog(@"商品信息不存在");
            break;
        case 8:
            DebugLog(@"商品价格错误");
            break;
        case 10:
            DebugLog(@"商品非付费错误");
            break;
        case 14:
            DebugLog(@"签名参数为空");
            break;
        case 15:
            DebugLog(@"订单已成功支付");
            [self.gIsHaveOrderSubject sendNext:nil];
//            [self.delegate isHaveOrder];
            break;
        case 16:
            DebugLog(@"app已成功支付，第三方未回调");
            [self.gIsHaveOrderSubject sendNext:nil];
//            [self.delegate isHaveOrder];
            break;
        default:
            break;
    }
    if (subStatusCode<15) {
        [self.gFailSubject sendNext:kCreateFail];
//        [self.delegate createOrderFail:kCreateFail];
    }
}



- (void)parseSubStatusCode_401:(WVROrderModel * )orderModel
{
    NSInteger subStatusCode = [orderModel.subStatusCode integerValue];
    switch (subStatusCode) {
        case 000:
            break;
            DebugLog(@"鉴权失败");
        default:
            
            break;
    }
}

- (void)parseSubStatusCode_500:(WVROrderModel * )orderModel
{
    NSInteger subStatusCode = [orderModel.subStatusCode integerValue];
    switch (subStatusCode) {
        case 000:
            break;
            DebugLog(@"系统异常");
        default:
            
            break;
    }
}

-(RACSignal *)successSignal
{
    if (!_successSignal) {
        @weakify(self);
        _successSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self);
            self.gSuccessSubject = subscriber;
            return nil;
        }];
    }
    return _successSignal;
}

-(RACSignal *)failSignal
{
    if (!_failSignal) {
        @weakify(self);
        _failSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self);
            self.gFailSubject = subscriber;
            return nil;
        }];
    }
    return _failSignal;
}

-(RACSignal *)isHaveOrderSignal
{
    if (!_isHaveOrderSignal) {
        @weakify(self);
        _isHaveOrderSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self);
            self.gIsHaveOrderSubject = subscriber;
            return nil;
        }];
    }
    return _isHaveOrderSignal;
}

-(RACSignal *)payStatusSignal
{
    if (!_payStatusSignal) {
        @weakify(self);
        _payStatusSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self);
            self.gPayStatusSubject = subscriber;
            return nil;
        }];
    }
    return _payStatusSignal;
}
@end
