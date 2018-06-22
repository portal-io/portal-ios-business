//
//  WVRLivePlayerTopToolView.h
//  WhaleyVR
//
//  Created by qbshen on 2017/2/20.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRPlayerTopToolView.h"
#import "WVRDanmuListView.h"
#import "WVRLotteryBoxView.h"
#import "WVRLiveTitleView.h"

@interface WVRLivePlayerTopToolView : WVRPlayerTopToolView

@property (nonatomic) WVRLotteryBoxView *box;

@property (nonatomic) WVRLiveTitleView * liveTitleView;

- (void)resetWithTitle:(NSString*)title curWatcherCount:(NSString*)watchCount;

@end
