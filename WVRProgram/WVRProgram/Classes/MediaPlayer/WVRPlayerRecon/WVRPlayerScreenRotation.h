//
//  WVRPlayerScreenRotation.h
//  WhaleyVR
//
//  Created by Wang Tiger on 17/3/24.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WVRPlayerView.h"

@interface WVRPlayerScreenRotation : NSObject
- (instancetype)initWithPlayerView:(WVRPlayerView *) playerView withVC:(UIViewController *)vc;
- (void)screenRotation:(BOOL)isLandspace;
- (void)screenRotationAndBack:(BOOL)isLandspace;
@end
