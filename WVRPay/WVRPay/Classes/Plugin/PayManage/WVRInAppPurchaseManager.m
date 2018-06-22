//
//  WVRInAppPurchaseManager.m
//  WhaleyVR
//
//  Created by Bruce on 2017/5/5.
//  Copyright © 2017年 Snailvr. All rights reserved.
//
// 苹果内购支付

#import "WVRInAppPurchaseManager.h"
//#import "WVRWhaleyHTTPManager.h"
//#import "WVRRequestClient.h"
#import "WVRSQLiteManager.h"
#import "SQMD5Tool.h"
#import "WVRPayHeader.h"

#import "WVRPayCallbackLoadingView.h"
#import "YYModel.h"

#define kIOSPurchaseType @"40582FD9679C057B"

NSString * const IAPStorePurchasedSuccessedNotification = @"IAPStorePurchasedSuccessedNotification";

@interface WVRInAppPurchaseManager () <SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property (nonatomic, strong) WVRInAppPurchaseModel *purchaseModel;
@property (atomic, strong) NSMutableArray<WVRInAppPurchaseModel *> *purchaseModels;

@property (nonatomic, copy) BuyProductCompletionHandler completionHandler;

@property (nonatomic, strong) WVRPayCallbackLoadingView * gCallbackLoadingV;

@end


@implementation WVRInAppPurchaseManager
@synthesize products = _products;

+ (instancetype)sharedInstance {
    static WVRInAppPurchaseManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _purchaseModels = [NSMutableArray array];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        self.gCallbackLoadingV = (WVRPayCallbackLoadingView *)VIEW_WITH_NIB(NSStringFromClass([WVRPayCallbackLoadingView class]));
        self.gCallbackLoadingV.frame = [UIScreen mainScreen].bounds;
    }
    return self;
}

#pragma mark - helpless func for a singleton object

- (void)dealloc {
    
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

#pragma mark - External func

// MARK: - step 1
- (void)buyWithPurchaseModel:(WVRInAppPurchaseModel *)model
           completionHandler:(BuyProductCompletionHandler)completionHandler {
    
    self.purchaseModel = model;
    
    [self.purchaseModels addObject:model];
    self.completionHandler = completionHandler;
    
    [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self.gCallbackLoadingV];
    [self createOrderForInAppPurchase];
}

#pragma mark - pravite func

// MARK: - step 3
- (void)requestForProductsForModel:(WVRInAppPurchaseModel *)model {
    
    NSSet *productIdentifiers = [NSSet setWithObject:model.iosProductCode];
    
    if ([SKPaymentQueue canMakePayments] == NO) {
        SQToastInKeyWindow(@"user don't allow payment");
        return;
    }
    
    if (self.products) {
        
        SKProduct *product = [self validProductExist:model.iosProductCode];
        if (nil != product) {
            
            NSLog(@"Buying %@...", product.productIdentifier);
            
            SKPayment *payment = [SKPayment paymentWithProduct:product];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
            
            [self.gCallbackLoadingV updateStatusMsg:kInAppPurchaseing];
            
        } else {
            SQToastInKeyWindow(@"productIdentifier does not exist.");
        }
    } else {
        // 先去请求商品列表，再购买
        
        SKProductsRequest *productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
        
        productRequest.orderNo = model.orderNo;
        productRequest.productId = model.iosProductCode;
        productRequest.delegate = self;
        
        [productRequest start];
    }
}

- (void)restoreCompletedTransactions {
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

// MARK: - step 2
- (void)createOrderForInAppPurchase {
    
//    [self.gCallbackLoadingV updateStatusMsg:kWaiting];
//    
//    WVRInAppPurchaseModel *model = self.purchaseModel;
//    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:8];
//    
//    dict[@"uid"] = [WVRUserModel sharedInstance].accountId;
//    dict[@"goodsNo"] = model.goodsNo;
//    dict[@"goodsType"] = model.goodsType;
//    dict[@"price"] = [NSString stringWithFormat:@"%ld", model.price];
//    dict[@"payMethod"] = @"appStore";
//    dict[@"thirdPayType"] = @"ios_pay";
//    dict[@"phoneNum"] = [WVRUserModel sharedInstance].mobileNumber;
//    
//    // uid+goodsNo+goodsType+price+payMethod+thirdPayType+phoneNum+key
//    NSString *key = [WVRUserModel CMCPURCHASE_sign_secret];
//    NSString *str = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", dict[@"uid"], dict[@"goodsNo"], dict[@"goodsType"], dict[@"price"], dict[@"payMethod"], dict[@"thirdPayType"], dict[@"phoneNum"]];
//    NSString *sign = [SQMD5Tool encryptByMD5:str md5Suffix:key];
//    
//    dict[@"sign"] = sign;
//    
//    kWeakSelf(self);
//    NSString *url = [[WVRUserModel kNewVRBaseURL] stringByAppendingString:@"newVR-report-service/order/createNormalOrder"];
//    [WVRRequestClient POSTService:url withParams:dict completionBlock:^(id responseObj, NSError *error) {
//        
//        NSDictionary *resDic = responseObj;
//        int code = [resDic[@"code"] intValue];
//        
//        if (code == 200) {
//            
//            NSDictionary *data = resDic[@"data"];
//            model.orderNo = data[@"orderNo"];
//            model.iosProductCode = data[@"iosProductCode"];
//            
//            [weakself requestForProductsForModel:model];
//            
//        } else  {
//            
//            [self.gCallbackLoadingV removeFromSuperview];
//            SQToastInKeyWindow(kCreateFail);
//            
//            if (weakself.completionHandler) {
//                NSError *err = [NSError errorWithDomain:kCreateFail code:code userInfo:nil];
//                weakself.completionHandler(err);
//                weakself.completionHandler = nil;
//            }
//        }
//    }];
}

- (void)requestForAppInPurchaseResultWithOrderNo:(NSString *)orderNo iosTradeNo:(NSString *)iosTradeNo phoneNo:(NSString *)phoneNo block:(void (^)(BOOL success, NSError *error))block {
    
//    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];
//    dict[@"orderNo"] = orderNo;
//    dict[@"iosTradeNo"] = iosTradeNo;
//    dict[@"phoneNum"] = phoneNo;
//    
//    NSString *key = [WVRUserModel CMCPURCHASE_sign_secret];
//    NSString *str = [NSString stringWithFormat:@"%@%@%@", dict[@"orderNo"], dict[@"iosTradeNo"], dict[@"phoneNum"]];
//    NSString *sign = [SQMD5Tool encryptByMD5:str md5Suffix:key];
//    
//    dict[@"sign"] = sign;
//    
//    NSString *url = [[WVRUserModel kNewVRBaseURL] stringByAppendingString:@"newVR-report-service/order/iosPayFinishBack"];
//    [WVRRequestClient POSTFormData:url withParams:dict completionBlock:^(id responseObj, NSError *error) {
//        
//        NSDictionary *resDic = responseObj;
//        int code = [resDic[@"code"] intValue];
//        NSString *msg = [NSString stringWithFormat:@"%@", resDic[@"msg"]];
//        
//        if (code == 200) {
//            block(YES, nil);
//        } else {
//            NSError *err = error ?: [NSError errorWithDomain:msg code:code userInfo:resDic];
//            DDLogError(@"requestForAppInPurchaseResultWithOrderNo_error: %@", err);
//            block(NO, err);
//        }
//    }];
}

- (SKProduct *)validProductExist:(NSString *)productIdentifier {
    SKProduct *product = nil;
    
    for (SKProduct *tempProduct in self.products) {
        if ([tempProduct.productIdentifier isEqualToString:productIdentifier]) {
            product = tempProduct;
        }
    }
    return product;
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    
    [self validateReceiptForTransaction:transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    
    [self validateReceiptForTransaction:transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    if (transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    if (self.completionHandler) {
        
        self.completionHandler(transaction.error);
        self.completionHandler = nil;
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    SQToastInKeyWindow(kFailCallback);
    [self.gCallbackLoadingV removeFromSuperview];
}

- (void)validateReceiptForTransaction:(SKPaymentTransaction *)transaction {
    
    if (nil == _purchaseModel.orderNo) { return; }
    
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    // 先将本地获取到的结果写入数据库，服务端返回成功后再删除
    _purchaseModel.receipt = encodeStr;
    [[WVRSQLiteManager sharedManager] insertIAPOrder:[_purchaseModel yy_modelToJSONObject]];
    
    kWeakSelf(self);
    [self requestForAppInPurchaseResultWithOrderNo:_purchaseModel.orderNo iosTradeNo:encodeStr phoneNo:[WVRUserModel sharedInstance].mobileNumber block:^(BOOL success, NSError *error) {
        
        if (NO == success) {
            NSLog(@"验证失败");
            
            if (weakself.completionHandler) {
                weakself.completionHandler(error);
                weakself.completionHandler = nil;
            }
            [weakself handlePurchaseFailedResult:error];
        } else {
            NSLog(@"验证成功");
            
            if (weakself.completionHandler) {
                weakself.completionHandler(nil);
                weakself.completionHandler = nil;
            }
            [weakself handlePurchaseSuccessResult];
        }
        
        [self.gCallbackLoadingV removeFromSuperview];
    }];
}

- (void)handlePurchaseSuccessResult {
    
    [[WVRSQLiteManager sharedManager] removeIAPOrder:self.purchaseModel.orderNo];
    [self.purchaseModels removeObject:self.purchaseModel];
    self.purchaseModel = nil;
}

- (void)handlePurchaseFailedResult:(NSError *)error {
    
    NSDictionary *dict = error.userInfo;
    
    if (nil == dict) {
        
        SQToastInKeyWindow(kNetError);
    } else {
        int code = [dict[@"code"] intValue];
        int subCode = [dict[@"subCode"] intValue];
        
        switch (code) {
            case 400: {
                if (subCode != 23) {
                    
                    [[WVRSQLiteManager sharedManager] removeIAPOrder:self.purchaseModel.orderNo];
                    break;
                }
                // 走到401的逻辑
            }
            case 401:
                // alert for remind user
                
                break;
            
            case 500:
                // try again later
                
                break;
            
            default:
                break;
        }
    }
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(nonnull SKProductsResponse *)response {
    
    NSLog(@"Invalid product id: %@" , response.invalidProductIdentifiers);
    
    NSArray<SKProduct *> *skProducts = response.products;
    _products = skProducts;
    
    NSLog(@"付费产品数量: %d个", (int)[skProducts count]);
    
    SKProduct *product = nil;
    for (SKProduct *pro in skProducts) {
        
        if ([pro.productIdentifier isEqualToString:request.productId]) {
            product = pro;
            break;
        }
    }
    
    if (nil != product) {
        NSLog(@"发送购买请求");
        
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        
        [self.gCallbackLoadingV updateStatusMsg:kInAppPurchaseing];
        
    } else {
        if (self.completionHandler) {
            NSError *err = [NSError errorWithDomain:@"商品编号不匹配" code:400 userInfo:nil];
            self.completionHandler(err);
            self.completionHandler = nil;
        }
        
        SQToastInKeyWindow(@"Error: 商品编号不匹配");
        [self.gCallbackLoadingV removeFromSuperview];
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    if (self.completionHandler) {
        self.completionHandler(error);
        self.completionHandler = nil;
    }
    
    SQToastInKeyWindow(@"请求商品列表失败");
    [self.gCallbackLoadingV removeFromSuperview];
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    
    [transactions enumerateObjectsUsingBlock:^(SKPaymentTransaction * _Nonnull transaction,
                                               NSUInteger idx,
                                               BOOL * _Nonnull stop) {
        
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                self.gCallbackLoadingV.alpha = 0;
                break;
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            case SKPaymentTransactionStateDeferred:
                [self failedTransaction:transaction];
                break;
            default:
                break;
        }
    }];
}

#pragma mark - external func

+ (void)requestForPayMethodList:(void (^)(NSArray *list))block {
    
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    dict[@"appSystem"] = @"ios";
//    dict[@"appVerion"] = kAppVersion;
//    
//    [WVRWhaleyHTTPManager GETService:@"newVR-report-service/payMethod/payMethodList" withParams:dict completionBlock:^(id responseObj, NSError *error) {
//        
//        NSDictionary *dic = responseObj;
//        int code = [dic[@"code"] intValue];
//        if (code == 200) {
//            
//            NSDictionary *dict = dic[@"data"];
//            NSMutableArray *typeList = [NSMutableArray arrayWithCapacity:4];
////            if ([dict[@"whaleyCurrency"] boolValue]) {
////                [typeList addObject:@(WVRPayMethodWhaleyCurrency)];
////            }
//            if ([dict[@"alipay"] boolValue]) {
//                [typeList addObject:@(WVRPayMethodAlipay)];
//            }
//            if ([dict[@"weixin"] boolValue]) {
//                [typeList addObject:@(WVRPayMethodWeixin)];
//            }
//            if ([dict[@"appStore"] boolValue]) {
//                [typeList addObject:@(WVRPayMethodAppStore)];
//            }
//            
//            [[NSUserDefaults standardUserDefaults] setObject:typeList forKey:kIOSPurchaseType];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            block(typeList);
//        } else {
//            NSArray *methodList = [[NSUserDefaults standardUserDefaults] objectForKey:kIOSPurchaseType];
//            if (![methodList isKindOfClass:[NSArray class]] || methodList.count == 0) {
//                methodList = nil;
//                [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:kIOSPurchaseType];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//            }
//            if (!methodList) {
//                methodList = @[ @(WVRPayMethodAppStore) ];
//            }
//            block(methodList);
//        }
//    }];
}

// item
//{
//    "uid": "123456",//用户uid
//    "goodsNo": "878f2dd97dbe480aa0fb8ec6f59d9fa0",//商品编码
//    "goodsType": "recorded",//商品类型（live：直播；recorded：录播；content_packge：节目包；coupon：券；）
//    "result": true//是否已支付（true:已支付；false:未支付）
//}
+ (void)requestCheckGoodsPayedList:(NSArray<NSDictionary *> *)goodsInfoList block:(void (^)(NSArray *list, NSError *error))block {
    
//    NSMutableDictionary *param = [NSMutableDictionary dictionary];
//    param[@"uid"] = [WVRUserModel sharedInstance].accountId;
//    
//    NSString *goodsNos = @"";
//    NSString *goodsTypes = @"";
//    
//    for (NSDictionary *dict in goodsInfoList) {
//        NSString *sid = dict[@"sid"];
//        NSString *type = dict[@"type"];
//        
//        goodsNos = [[goodsNos stringByAppendingString:sid] stringByAppendingString:@","];
//        goodsTypes = [[goodsTypes stringByAppendingString:type] stringByAppendingString:@","];;
//    }
//    // 删除最后一个逗号
//    if ([goodsNos hasSuffix:@","]) { goodsNos = [goodsNos substringToIndex:goodsNos.length - 1]; }
//    if ([goodsTypes hasSuffix:@","]) { goodsTypes = [goodsTypes substringToIndex:goodsTypes.length - 1]; }
//    
//    param[@"goodsNos"] = goodsNos;
//    param[@"goodsTypes"] = goodsTypes;
//    
//    NSString *key = [WVRUserModel CMCPURCHASE_sign_secret];
//    NSString *str = [NSString stringWithFormat:@"%@%@%@", param[@"uid"], param[@"goodsNos"], param[@"goodsTypes"]];
//    NSString *sign = [SQMD5Tool encryptByMD5:str md5Suffix:key];
//    
//    param[@"sign"] = sign;
//    
//    NSString *url = [[WVRUserModel kNewVRBaseURL] stringByAppendingString:@"newVR-report-service/order/goodsPayedList"];
//    
//    [WVRRequestClient POSTService:url withParams:param completionBlock:^(id responseObj, NSError *error) {
//        
//        if (error) {
//            
//            block(nil, error);
//            
//        } else {
//            NSDictionary *dict = responseObj;
//            int code = [dict[@"code"] intValue];
//            NSString *msg = [NSString stringWithFormat:@"%@", dict[@"msg"]];
//            
//            if (code == 200) {
//                
//                NSArray *resultList = dict[@"data"];
//                
//                block(resultList, nil);
//                
//            } else {
//                NSError *err = [NSError errorWithDomain:msg code:code userInfo:nil];
//                block(nil, err);
//            }
//        }
//    }];
}

+ (void)reportLostInAppPurchaseOrders {
    
    NSArray<NSDictionary *> *orders = [[WVRSQLiteManager sharedManager] ordersInIAPOrder];
    
    for (NSDictionary *orderDict in orders) {
        
        WVRInAppPurchaseModel *order = [WVRInAppPurchaseModel yy_modelWithDictionary:orderDict];
        
        [[self sharedInstance] requestForAppInPurchaseResultWithOrderNo:order.orderNo iosTradeNo:order.receipt phoneNo:order.phoneNo block:^(BOOL success, NSError *error) {
            
            // 上报成功或服务器返回数据且错误码不是服务端和网络错误
            if (success || (error.userInfo && error.code < 500)) {
                
                [[WVRSQLiteManager sharedManager] removeIAPOrder:order.orderNo];
            }
        }];
    }
}

- (WVRInAppPurchaseModel *)iapOrderResult:(NSDictionary *)result {
    
    WVRInAppPurchaseModel *model = [WVRInAppPurchaseModel yy_modelWithDictionary:result];
    
    return model;
}

@end


@implementation WVRInAppPurchaseModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _uid = [WVRUserModel sharedInstance].accountId;
        _phoneNo = [WVRUserModel sharedInstance].mobileNumber;
    }
    return self;
}

- (void)dealloc {
    
    NSLog(@"WVRInAppPurchaseModel dealloc");
}

@end


static const void *orderNoKey = &orderNoKey;
static const void *productIdKey = &productIdKey;

@implementation SKProductsRequest (Extend)

- (void)setOrderNo:(NSString *)orderNo {
    
    objc_setAssociatedObject(self, orderNoKey, orderNo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)orderNo {
    
    return objc_getAssociatedObject(self, orderNoKey);
}

- (void)setProductId:(NSString *)productId {
    
    objc_setAssociatedObject(self, productIdKey, productId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)productId {
    
    return objc_getAssociatedObject(self, productIdKey);
}

@end

