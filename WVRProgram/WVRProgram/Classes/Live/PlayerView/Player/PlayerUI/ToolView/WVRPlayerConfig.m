//
//  WVRPlayerStatus.m
//  WhaleyVR
//
//  Created by qbshen on 2017/2/27.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRPlayerConfig.h"

@implementation WVRPlayerConfig

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.isDefinitionHD = [WVRUserModel sharedInstance].defaultDefinition;
        self.mCurDeviceOrientation = UIDeviceOrientationPortrait;
    }
    return self;
}
@end
