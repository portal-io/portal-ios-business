//
//  WVRCreateOrderUseCase.h
//  WhaleyVR
//
//  Created by qbshen on 2017/8/31.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRUseCase.h"
#import "WVRPayGoodsType.h"

@interface WVRCreateOrderUseCase : WVRUseCase<WVRUseCaseProtocol>

@property(nonatomic, strong) NSString *goodCode;
@property(nonatomic, strong) NSString *goodType;
@property(nonatomic, assign) long goodPrice;
@property(nonatomic, assign) WVRPayPlatform payPlatform;

-(RACCommand*)createOrderCmd;

@end
