//
//  WVRSQLocalCachController.h
//  WhaleyVR
//
//  Created by qbshen on 16/11/5.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRTableViewController.h"
@class WVRVideoModel;

@interface WVRSQLocalController : WVRTableViewController

+ (instancetype)shareInstance;

//updateCachVideoInfo 和 addDownTask不能同时调用
- (void)updateCachVideoInfo;

- (void)addDownTask:(WVRVideoModel *)videoModel;
- (void)startDownWhenHaveNet;

@end
