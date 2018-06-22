//
//  WVRMyOrderItemModel.m
//  WhaleyVR
//
//  Created by Bruce on 2017/4/13.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRMyOrderItemModel.h"
//#import "WVRRequestClient.h"
#import "SQMD5Tool.h"
#import "YYModel.h"
#import <WVRAppContextHeader.h>

NSString * const GOODS_TYPE_LIVE = @"live";
NSString * const GOODS_TYPE_RECORD = @"recorded";
NSString * const GOODS_TYPE_CONTENT_PACKGE = @"content_packge";
NSString * const GOODS_TYPE_COUPON = @"coupon";

@implementation WVRMyOrderItemModel

#pragma mark - getter

- (PurchaseProgramType)purchaseType {
    
    return [WVRMyOrderItemModel purchaseTypeForGoodType:_merchandiseType];
}

+ (PurchaseProgramType)purchaseTypeForGoodType:(NSString *)goodsType {
    
    if ([goodsType isEqualToString:GOODS_TYPE_RECORD]) {
        return PurchaseProgramTypeVR;
    } else if ([goodsType isEqualToString:GOODS_TYPE_LIVE]) {
        return PurchaseProgramTypeLive;
    } else if ([goodsType isEqualToString:GOODS_TYPE_CONTENT_PACKGE]) {
        return PurchaseProgramTypeCollection;
    } else if ([goodsType isEqualToString:GOODS_TYPE_COUPON]) {
        return PurchaseProgramTypeTicket;
    }
    
    DDLogError(@"merchandiseType：%@ 未约定", goodsType);
    
    return PurchaseProgramTypeVR;
}

+ (NSString *)goodsTypeForPurchaseType:(PurchaseProgramType)purchaseType {
    
    switch (purchaseType) {
        case PurchaseProgramTypeVR:
            return GOODS_TYPE_RECORD;
            
        case PurchaseProgramTypeLive:
            return GOODS_TYPE_LIVE;
            
        case PurchaseProgramTypeCollection:
            return GOODS_TYPE_CONTENT_PACKGE;
            
        case PurchaseProgramTypeTicket:
            return GOODS_TYPE_COUPON;
    }
    
    DDLogError(@"purchaseType：%ld 未约定", purchaseType);
    
    return GOODS_TYPE_COUPON;
}

@end


@implementation WVRMyOrderListModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{ @"content" : [WVRMyOrderItemModel class], };
}

@end

