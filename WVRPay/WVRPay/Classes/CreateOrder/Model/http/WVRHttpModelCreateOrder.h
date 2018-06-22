//
//  WVRHttpModelCreateOrder.h
//  WhaleyVR
//
//  Created by Wang Tiger on 17/4/7.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WVRHttpModelCreateOrder : NSObject
@property(nonatomic, strong) NSString *uid;
@property(nonatomic, strong) NSString *goodsNo;
@property(nonatomic, strong) NSString *goodsName;
@property(nonatomic, strong) NSString *goodsType;
@property(nonatomic, strong) NSString *price;
@property(nonatomic, strong) NSString *orderNo;
@property(nonatomic, strong) NSString *orderDetail;
@property(nonatomic, strong) NSString *mhtReserved;
@property(nonatomic, strong) NSString *notifyUrl;
@property(nonatomic, strong) NSString *orderStartTime;
@property(nonatomic, strong) NSString *orderTimeOut;
@property(nonatomic, strong) NSString *charset;

@property (nonatomic, strong) NSString * statusCode;
@property (nonatomic, strong) NSString * subStatusCode;

@property (nonatomic, strong) NSString * orderToPayStr;
@end
