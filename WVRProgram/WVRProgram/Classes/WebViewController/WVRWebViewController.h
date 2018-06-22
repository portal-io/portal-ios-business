//
//  WVRWebViewController.h
//  VRManager
//
//  Created by Snailvr on 16/7/14.
//  Copyright © 2016年 Snailvr. All rights reserved.

// WVRHybrid 耦合了登录、抽奖（可以通过路由的方式解耦）、Image、Share 等模块

#import <UIKit/UIKit.h>
#import "WVRBaseViewController.h"

@interface WVRWebViewController : WVRBaseViewController

@property (copy, nonatomic) NSString *URLStr;
@property (nonatomic, assign) BOOL isNews;

//MARK: 上报查看次数
@property (nonatomic, copy) NSString *code;

@end

