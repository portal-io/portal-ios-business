//
//  ViewController.m
//  WVRDanmu
//
//  Created by Bruce on 2017/9/7.
//  Copyright © 2017年 snailvr. All rights reserved.
//

#import "ViewController.h"
#import "WVRWebSocketClient.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    WVRWebSocketClient *client = [[WVRWebSocketClient alloc] init];
    
    [[WVRWebSocketClient shareInstance] sendTextMsg:@"" successBlock:^{
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
