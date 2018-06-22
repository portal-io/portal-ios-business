//
//  WVRPayModel.h
//  WhaleyVR
//
//  Created by qbshen on 17/4/13.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WVRMyOrderItemModel.h"

#import "WVRContentPackageQueryDto.h"
#import "WVRPayGoodsType.h"
#import <WVRItemModel.h>

typedef NS_ENUM(NSInteger, WVRPayComeFromType) {
    
    WVRPayComeFromTypeProgramRecord,
    WVRPayComeFromTypeProgramLive,
    WVRPayComeFromTypeProgramPackage,
};

typedef NS_ENUM(NSInteger, PayFromType) {
    
    PayFromTypeUnity,
    PayFromTypeApp,
};

@interface WVRPayModel : NSObject

/// 支付来源类型（App，Launcher）
@property (nonatomic, assign) PayFromType fromType;
/// 所选支付平台
@property (nonatomic, assign) WVRPayPlatform payPlatform;
/// 支付节目来源类型
@property (nonatomic, assign) WVRPayComeFromType payComeFromType;

@property (nonatomic, copy  ) NSString * userId;
/// 券code
@property (nonatomic, copy  ) NSString * goodsCode;
/// 券名称 displayName
@property (nonatomic, copy  ) NSString * goodsName;

/// live：直播；recorded：录播；content_packge：节目包；coupon：券   现在产品中能只能购买券
@property (nonatomic, copy, readonly) NSString * goodsType;

/// 观看券 关联节目的code
@property (nonatomic, copy  ) NSString * relatedCode;
/// 观看券 关联节目的类型
@property (nonatomic, copy  ) NSString * relatedType;

/// 直播状态 for BI
@property (nonatomic, assign) WVRLiveStatus liveStatus;

/// 单位为 分
@property (nonatomic, assign) long goodsPrice;
/// 毫秒时间戳
@property (nonatomic, assign) long disableTime;
/// 节目包 or 合集
@property (nonatomic, assign) WVRPackageType packageType;

/// 用户已选择，或者产品指定的默认购买类型 比如 节目包 （只用来传值）
@property (nonatomic, assign) WVRPayGoodsType defaultGoodsType;

/// 可能为nil，需要checkGoodsType之后才能确定该Model的goods类型
@property (nonatomic, strong) WVRContentPackageQueryDto * programPackModel;

/// enum
- (PurchaseProgramType)purchaseType;

/// enum checkGoodsType
- (WVRPayGoodsType)payGoodsType;

// 用户可选
- (BOOL)isProgramAndPackage;

/// live recorded detail Model
+ (instancetype)createWithDetailModel:(WVRItemModel *)detailBaseModel streamType:(WVRStreamType)streamType;
/// live recorded programPackage detail dictionary
+ (instancetype)createWithDict:(NSDictionary *)dict;

@end
