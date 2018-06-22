//
//  ViewController.m
//  WVRAccount
//
//  Created by qbshen on 2017/8/2.
//  Copyright © 2017年 qbshen. All rights reserved.
//

#import "ViewController.h"
#import "WVRLoginViewController.h"

@interface ViewController ()
- (IBAction)gotoMineVC:(id)sender;

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


- (IBAction)gotoMineVC:(id)sender {
    WVRLoginViewController * vc = [[WVRLoginViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
