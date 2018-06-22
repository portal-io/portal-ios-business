//
//  Target_program.h
//  WhaleyVR
//
//  Created by qbshen on 2017/8/15.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Target_pay : NSObject

- (UIViewController *)Action_nativeFetchMyTicketViewController:(NSDictionary *)params;

/**
 pay for video

 @param params @{ @"itemModel":WVRItemModel, @"streamType":WVRStreamType , @"cmd":RACCommand }
 */
- (void)Action_nativePayForVideo:(NSDictionary *)params;

/**
 付费视频播放过程中检测设备

 @param params @{ @"cmd":RACCommand }
 */
- (void)Action_nativeCheckDevice:(NSDictionary *)params;

/**
 用户播放付费视频时上报设备

 @param params @{ @"cmd":RACCommand }
 */
- (void)Action_nativePayReportDevice:(NSDictionary *)params;

/**
 检测付费视频（列表）是否已支付

 @param params @{ @"cmd":RACCommand, @"item":WVRItemModel, @"items":NSArray<WVRItemModel *> }
 */
- (void)Action_nativeCheckIsPaied:(NSDictionary *)params;

/**
 内购丢单上报

 @param params nil
 */
- (void)Action_nativeReportLostInAppPurchaseOrders:(NSDictionary *)params;

@end
