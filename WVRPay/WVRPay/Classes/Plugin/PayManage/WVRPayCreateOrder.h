//
//  WVRPayCreateOrder.h
//  WhaleyVR
//
//  Created by qbshen on 2017/5/2.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WVRPayStatusProtocol.h"

@class WVRPayModel, WVROrderModel;

//@protocol WVRPayCreateOrderDelegate <NSObject>
//
//-(void)createrOrderSuccess:(WVROrderModel*)orderModel;
//
//-(void)createOrderFail:(NSString*)errMsg;
//
//-(void)isHaveOrder;
//
//@end


@interface WVRPayCreateOrder : NSObject

//@property (nonatomic, weak) id<WVRPayCreateOrderDelegate, WVRPayStatusProtocol> delegate;

@property (nonatomic, strong, readonly) RACSignal * successSignal;

@property (nonatomic, strong, readonly) RACSignal * failSignal;

@property (nonatomic, strong, readonly) RACSignal * isHaveOrderSignal;

@property (nonatomic, strong, readonly) RACSignal * payStatusSignal;

//- (void)http_createOrder:(WVRPayModel*)payModel;
-(void)createOrder:(WVRPayModel*)payModel;

@end
