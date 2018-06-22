//
//  WVRHttpCheckGoodsPayedListReformer.m
//  WhaleyVR
//
//  Created by Wang Tiger on 2017/9/7.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRHttpCheckGoodsPayedListReformer.h"
#import "WVRModelGoodsPayed.h"

@implementation WVRHttpCheckGoodsPayedListReformer

- (id)reformData:(NSDictionary *)data
{
    return [[WVRModelGoodsPayed alloc] init];
}

@end
