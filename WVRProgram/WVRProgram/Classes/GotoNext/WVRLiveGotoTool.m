//
//  WVRLiveGotoTool.m
//  WhaleyVR
//
//  Created by qbshen on 2016/12/7.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRLiveGotoTool.h"
#import "WVRLivingController.h"
#import "WVRGotoNextTool.h"
#import "WVRManualArrangeController.h"
#import "WVRLiveDetailVC.h"

@implementation WVRLiveGotoTool

+ (void)gotoMoreVC:(WVRSectionModel*)sectionModel nav:(UINavigationController*)nav
{
    NSLog(@"linkArrangeType: %ld",(long)sectionModel.liveStatus);
    UIViewController * subVc = nil;
    if (sectionModel.liveStatus == WVRLiveStatusPlaying) {
        WVRLivingController * vc = [[WVRLivingController alloc] init];
        vc.title = @"正在直播";
        subVc = vc;
    } else if (sectionModel.liveStatus == WVRLiveStatusNotStart){
        
    } else {
       
    }
    subVc.hidesBottomBarWhenPushed = YES;
    [nav pushViewController:subVc animated:YES];
}
@end
