//
//  WVRPlayerScreenRotation.m
//  WhaleyVR
//
//  Created by Wang Tiger on 17/3/24.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRPlayerScreenRotation.h"
#import "WVRNavigationController.h"

@interface WVRPlayerScreenRotation ()

@property (nonatomic, weak) WVRPlayerView *playerView;
@property (nonatomic, weak) UIViewController *vc;
@property (nonatomic) UIDeviceOrientation mCurDO;

@end


@implementation WVRPlayerScreenRotation

- (instancetype)initWithPlayerView:(WVRPlayerView *) playerView withVC:(UIViewController *)vc
{
    self = [super init];
    if (self) {
        _playerView = playerView;
        _vc = vc;
    }
    return self;
}

#pragma mark - orientation Notification
- (void)addOrientationObserver {
    // Do any additional setup after loading the view from its nib.
    //----- SETUP DEVICE ORIENTATION CHANGE NOTIFICATION -----
    UIDevice *device = [UIDevice currentDevice]; //Get the device object
    [device beginGeneratingDeviceOrientationNotifications]; //Tell it to start monitoring the accelerometer for orientation
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; //Get the notification centre for the app
    [nc addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification  object:device];
}

- (void)removeOrientationObserver{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    UIDevice *device = [UIDevice currentDevice]; //Get the device object
    [nc removeObserver:self name:UIDeviceOrientationDidChangeNotification object:device];
}

- (void)orientationChanged:(NSNotification *)note {
    [self removeOrientationObserver];
    UIDeviceOrientation o = [[UIDevice currentDevice] orientation];
    switch (o) {
        case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
            NSLog(@"bottom");
            if (self.mCurDO== UIDeviceOrientationPortrait) {
                
            }else{
                [self screenRotation:NO];
            }
            break;
        case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
            NSLog(@"top");
            //            [self  rotation_icon:180.0];
            break;
        case UIDeviceOrientationLandscapeLeft :      // Device oriented horizontally, home button on the right
//            [WVRAppModel changeStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
            NSLog(@"right");
            if (self.mCurDO== UIDeviceOrientationLandscapeLeft) {
                
            }else{
                //                [self screenRotation:YES];
            }
            
            //            [self  rotation_icon:90.0*3];
            break;
        case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
            //            [WVRAppModel changeStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
            
            NSLog(@"left");
            //            [self  rotation_icon:90.0];
            break;
        default:
            break;
    }
    [self addOrientationObserver];
}

- (void)screenRotation:(BOOL)isLandspace {
    
    if (_playerView.isWaitingForPlay && isLandspace) {
        SQToastInKeyWindow(@"视频播放时才能切换至眼镜模式");
        return;
    }
    
    [_vc.view endEditing:YES];
    
    [_playerView screenWillRotationWithStatus:isLandspace];
    
    self.mCurDO = isLandspace ? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationPortrait;
    [WVRAppModel forceToOrientation:(isLandspace ? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationPortrait)];
    
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    
    [UIView animateWithDuration:duration animations:^{
        
        [self rotaionAnimations:isLandspace];
    } completion:^(BOOL finished) {
        
        [self rotaionAnimatCompletion:isLandspace];
        [_playerView screenRotationCompleteWithStatus:isLandspace];
    }];
}

- (void)rotaionAnimations:(BOOL)isLandspace
{
    [WVRAppModel changeStatusBarOrientation:isLandspace ? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationPortrait];
    
    _vc.navigationController.view.transform = CGAffineTransformIdentity;
    if (isLandspace) {
        _vc.navigationController.view.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    _vc.navigationController.view.bounds = CGRectMake(_vc.navigationController.view.bounds.origin.x, _vc.navigationController.view.bounds.origin.y, _vc.view.frame.size.height, _vc.view.frame.size.width);
    
    _playerView.frame = _vc.view.frame;
}

- (void)rotaionAnimatCompletion:(BOOL)isLandspace
{
    //    [self actionSwitchVR:!isLandspace];
    [_playerView screenRotationCompleteWithStatus:isLandspace];
    
    [self invalidNavPanGuesture:isLandspace];
    
}

- (void)screenRotationAndBack:(BOOL)isLandspace {
    
    [_playerView screenWillRotationWithStatus:isLandspace];
    
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    
    [UIView animateWithDuration:duration animations:^{
        [self rotaionAnimations:isLandspace];
    } completion:^(BOOL finished) {
        [self rotaionAndBackCompletion:isLandspace];
    }];
}

- (void)rotaionAndBackCompletion:(BOOL)isLandspace {
    //    [self actionSwitchVR:!isLandspace];
    
    [self invalidNavPanGuesture:NO];
    
    [_vc.navigationController popViewControllerAnimated:YES];
    SQToastInKeyWindow(@"直播结束");
}

// 横屏状态下要失效掉右划返回功能
- (void)invalidNavPanGuesture:(BOOL)isInvalid {
    
    WVRNavigationController *nav = (WVRNavigationController *)_vc.navigationController;
    nav.gestureInValid = isInvalid;
}

@end
