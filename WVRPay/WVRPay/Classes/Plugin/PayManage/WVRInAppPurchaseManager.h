//
//  WVRInAppPurchaseManager.h
//  WhaleyVR
//
//  Created by Bruce on 2017/5/5.
//  Copyright © 2017年 Snailvr. All rights reserved.
//
// 苹果内购支付

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "WVRPayGoodsType.h"

@class WVRInAppPurchaseModel;

extern NSString * const IAPStorePurchasedSuccessedNotification;

typedef void (^BuyProductCompletionHandler) (NSError *error);


@interface WVRInAppPurchaseManager : NSObject

@property (nonatomic, strong, readonly) NSArray<SKProduct *> *products;

+ (instancetype)sharedInstance;

- (void)buyWithPurchaseModel:(WVRInAppPurchaseModel *)model
           completionHandler:(BuyProductCompletionHandler)completionHandler;

#pragma mark - exteral func

+ (void)requestForPayMethodList:(void (^)(NSArray *list))block;

+ (void)requestCheckGoodsPayedList:(NSArray<NSDictionary *> *)goodsInfoList block:(void (^)(NSArray *list, NSError *error))block;

/// 内购丢单重新上报
+ (void)reportLostInAppPurchaseOrders;

@end


@interface WVRInAppPurchaseModel : NSObject

@property (nonatomic, copy) NSString *goodsNo;
@property (nonatomic, copy) NSString *goodsType;        // live：直播；recorded：录播；content_packge：节目包；

@property (nonatomic, copy  ) NSString * relatedCode;   // 关联节目的code
@property (nonatomic, copy  ) NSString * relatedType;   // 关联节目的类型

@property (nonatomic, assign) long price;               // 单位是 分

@property (nonatomic, copy) NSString *orderNo;
@property (nonatomic, copy) NSString *iosProductCode;

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *phoneNo;

#pragma mark - private

@property (nonatomic, copy) NSString *receipt;

@end


@interface SKProductsRequest (Extend)

@property (nonatomic, copy) NSString *orderNo;      // 本次刷新可购买列表时传递的订单号字段
@property (nonatomic, copy) NSString *productId;    // 本次刷新可购买列表时传递的iosProductCode字段

@end
