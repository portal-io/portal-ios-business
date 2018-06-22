//
//  ViewController.m
//  WVRProgram
//
//  Created by Bruce on 2017/9/2.
//  Copyright © 2017年 snailvr. All rights reserved.
//

#import "ViewController.h"
#import "WVRHomeViewController.h"
#import "WVRLiveController.h"

@interface ViewController ()
- (IBAction)gotoHomeVC:(id)sender;
- (IBAction)gotoLiveVC:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)gotoHomeVC:(id)sender {
    WVRHomeViewController * vc = [[WVRHomeViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)gotoLiveVC:(id)sender {
    WVRLiveController * vc = [[WVRLiveController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
