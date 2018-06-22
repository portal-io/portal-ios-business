//
//  Target_program.m
//  WhaleyVR
//
//  Created by qbshen on 2017/8/15.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "Target_program.h"

#import "WVRHistoryController.h"

#import "WVRRewardController.h"

#import "WVRCollectionController.h"

#import "WVRGotoNextTool.h"
#import "WVRBaseModel.h"

#import "UIViewController+HUD.h"

@implementation Target_program

- (UIViewController *)Action_nativeFetchHistoryViewController:(NSDictionary *)params
{
    WVRHistoryController * vc = [[WVRHistoryController alloc] init];
    return vc;
}


- (UIViewController *)Action_nativeFetchRewardViewController:(NSDictionary *)params
{
    WVRRewardController * vc = [[WVRRewardController alloc] init];
    return vc;
}

- (UIViewController *)Action_nativeFetchCollectionViewController:(NSDictionary *)params
{
    WVRCollectionController * vc = [[WVRCollectionController alloc] init];
    return vc;
}

- (void)Action_nativeGotoNextVC:(NSDictionary *)params {
    
    NSDictionary *paramDic = params[@"param"];
    WVRBaseModel *model = [WVRBaseModel yy_modelWithDictionary:paramDic];
    UINavigationController *nav = params[@"nav"];
    
    if (!nav) {
        nav = [UIViewController getCurrentVC].navigationController;
    }
    
    if (!nav) {
        DDLogError(@"fatal error: navigationController is nil");
        return;
    }
    
    [WVRGotoNextTool gotoNextVC:model nav:nav];
}

@end
