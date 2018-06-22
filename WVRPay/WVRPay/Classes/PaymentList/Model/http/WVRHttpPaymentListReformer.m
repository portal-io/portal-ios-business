//
//  WVRHttpPaymentListReformer.m
//  WhaleyVR
//
//  Created by Wang Tiger on 2017/9/7.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRHttpPaymentListReformer.h"
#import "WVRModelPayment.h"

@implementation WVRHttpPaymentListReformer

- (id)reformData:(NSDictionary *)data
{
    return [[WVRModelPayment alloc] init];
}

@end
