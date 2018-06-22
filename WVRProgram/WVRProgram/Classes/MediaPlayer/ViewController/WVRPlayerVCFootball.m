//
//  WVRPlayerVCFootball.m
//  WhaleyVR
//
//  Created by qbshen on 2017/5/10.
//  Copyright © 2017年 Snailvr. All rights reserved.

// 足球全屏播放器页面，由于需求和直播完全一致，暂时没有用到本类

#import "WVRPlayerVCFootball.h"

#import "WVRMediator+UnityActions.h"

@interface WVRPlayerVCFootball ()

@end


@implementation WVRPlayerVCFootball

- (void)viewDidLoad {
    
    self.isFootball = YES;
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [WVRAppModel forceToOrientation:UIDeviceOrientationLandscapeRight];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buildInitData {
    if (![WVRReachabilityModel isNetWorkOK]) {
        return;
    }
    [super buildInitData];
}

#pragma mark - overwrite func

// onGLKDealloc 的时候调用
// MARK: - 跳转到Launcher_足球
- (void)showUnityView {
    
    [[WVRMediator sharedInstance] WVRMediator_showU3DView:NO];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
    dict[@"behaviour"] = self.videoEntity.behavior;
    dict[@"matchId"] = @([[[self.videoEntity.behavior componentsSeparatedByString:@"="] lastObject] intValue]);
    dict[@"defaultSlot"] = self.videoEntity.currentStandType;
    
    WVRUnityActionMessageModel *model = [[WVRUnityActionMessageModel alloc] init];
    model.message = @"StartScene";
    model.arguments = @[ @"startSoccerVR", @"MatchInfo", [[dict toJsonString] stringByReplacingOccurrencesOfString:@"\\" withString:@""], ];
    
    [[WVRMediator sharedInstance] WVRMediator_sendMsgToUnity:model];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

@end
