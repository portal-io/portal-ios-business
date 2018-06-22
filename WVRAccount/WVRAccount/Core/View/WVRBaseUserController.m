//
//  WVRBaseUserController.m
//  WhaleyVR
//
//  Created by qbshen on 2016/12/10.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRBaseUserController.h"
#import "WVRBindWhaleyAccountVC.h"
#import "WVRInputNameAndPWVC.h"

//#import "UnityAppController+JPush.h"

@interface WVRBaseUserController ()

@end


@implementation WVRBaseUserController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self presentingViewController]) {
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(0, 0, 60, 44);
        [leftButton setTitle:@"取消" forState:UIControlStateNormal];
        [leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        leftButton.titleLabel.font = [UIFont systemFontOfSize:13.5];
        [leftButton addTarget:self action:@selector(cancelLogin) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    }
}

- (void)gotoPerfectInfoVC {
    
    WVRInputNameAndPWVC *registerVC = [[WVRInputNameAndPWVC alloc] init];
    registerVC.viewStyle = WVRRegisterViewStyleInputNameAndPD;
    registerVC.loginSuccessBlock = self.loginSuccessBlock;
    [self.navigationController pushViewController:registerVC animated:YES];
}

- (void)httpLoginSuccess {
    
    [WVRUserModel sharedInstance].isLogined = YES;
    [WVRUserModel sharedInstance].firstLogin = YES;
//    UnityAppController* app = (UnityAppController *)[UIApplication sharedApplication].delegate;
//    [app setTagsAlias];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginStatusNotification object:self userInfo:@{ @"status" : @1 }];
    
    if ([self presentingViewController]) {
        if ([WVRAppModel sharedInstance].preVcisOrientationPortraitl) {
            [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
            [WVRAppModel sharedInstance].preVcisOrientationPortraitl = NO;
        }
//        [WVRAppModel sharedInstance].shouldContinuePlay = YES;
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.loginSuccessBlock) {
                self.loginSuccessBlock();
            }
        }];
    } else {
        
//        for (WVRMineController *controller in [self.navigationController viewControllers]) {
//
//            SQToastInKeyWindow(@"登录成功");
//            [self.navigationController popToViewController:controller animated:YES];
//
//            break;
//        }
        if (self.loginSuccessBlock) {
            self.loginSuccessBlock();
        }
    }
}

//- (void)httpOtherLoginSuccessBlock:(WVRLoginVCThirdpartyModel *)model avatar:(NSString *)avatar
//{
//    SQHideProgress;
//    WVRWAccountBaseResponse * httpData = model.data;
//    NSString *code = [httpData code];
//    NSString *message = [httpData msg];
//
//    if ([code isKindOfClass:[NSString class]] && [code isEqualToString:@"144"]) {
//
//        [self showMessageToWindow:message];
//        WVRBindWhaleyAccountVC *registerVC = [[WVRBindWhaleyAccountVC alloc] init];
//        registerVC.viewStyle = WVRRegisterViewStyleInputPhoneNumAndPDForThirdPartyBind;
//        registerVC.avatar = avatar;
//        registerVC.thirdOrigin = model.thirdOrigin;
//        registerVC.nickName = model.nickName;
//        registerVC.loginSuccessBlock = self.loginSuccessBlock;
//        [self.navigationController pushViewController:registerVC animated:YES];
//
//    } else {
//        [self httpLoginSuccess];
//    }
//}

#pragma mark - 外部方法

- (void)cancelLogin {
    kWeakSelf(self);
    if ([self presentingViewController]) {
        if ([WVRAppModel sharedInstance].preVcisOrientationPortraitl) {
            [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
            [WVRAppModel sharedInstance].preVcisOrientationPortraitl = NO;
        }
        
        [self.view endEditing:YES];
        [self dismissViewControllerAnimated:YES completion:^{
            if (weakself.cancelBlock) {
                weakself.cancelBlock();
            }
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
        if (self.cancelBlock) {
            self.cancelBlock();
        }
    }
}

#pragma mark - dismiss
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector  = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

@end


@implementation WVRLoginVCThirdpartyModel

@end
