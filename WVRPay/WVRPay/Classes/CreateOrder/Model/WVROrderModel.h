//
//  WVRGoodsModel.h
//  WhaleyVR
//
//  Created by qbshen on 17/4/13.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WVROrderModel : NSObject

@property(nonatomic, strong) NSString *userId;
@property(nonatomic, strong) NSString *goodsName;
@property(nonatomic, strong) NSString *goodsType;
@property(nonatomic, strong) NSString *goodsPrice;
@property(nonatomic, strong) NSString *orderNo;
@property(nonatomic, strong) NSString *orderDetail;
@property(nonatomic, strong) NSString *mhtReserved;
@property(nonatomic, strong) NSString *notifyUrl;
@property(nonatomic, strong) NSString *orderStartTime;
@property(nonatomic, strong) NSString *orderTimeOut;
@property(nonatomic, strong) NSString *charset;

@property (nonatomic, strong) NSString *statusCode;
@property (nonatomic, strong) NSString *subStatusCode;

@property (nonatomic, strong) NSString *signDataStr;

@end
