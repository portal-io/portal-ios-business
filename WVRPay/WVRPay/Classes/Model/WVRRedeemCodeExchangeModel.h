//
//  WVRRedeemCodeExchangeModel.h
//  WhaleyVR
//
//  Created by Bruce on 2017/6/15.
//  Copyright © 2017年 Snailvr. All rights reserved.

// 兑换码兑换接口

#import <Foundation/Foundation.h>
#import "WVRMyTicketListModel.h"

@interface WVRRedeemCodeExchangeModel : NSObject

/// 兑换码兑换接口
+ (void)exchangeWithRedeemCode:(NSString *)redeemCode block:(void (^)(WVRMyTicketItemModel *model, NSError *error))block;

@end
