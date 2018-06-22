//
//  WVRSectionModel.m
//  WhaleyVR
//
//  Created by qbshen on 16/11/15.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRSectionModel.h"

@implementation WVRSectionModel

- (BOOL)programPackageHaveCharged {
    
    return [_discountPrice isEqualToString:@"0"];
}

@end
