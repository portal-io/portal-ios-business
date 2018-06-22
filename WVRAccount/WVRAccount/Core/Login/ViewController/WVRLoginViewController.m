//
//  WVRLoginViewController.m
//  WhaleyVR
//
//  Created by zhangliangliang on 8/24/16.
//  Copyright © 2016 Snailvr. All rights reserved.
//

#import "WVRLoginViewController.h"
#import "WVRLoginView.h"
#import "WVRRegisterViewController.h"
#import "WVRUserInfoViewController.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaHandler.h"
#import "WVRModifyPasswordViewController.h"
#import "WVRUserModel.h"
#import <UMSocialCore/UMSocialCore.h>


#import "WVRForgotPWVC.h"
#import "WVRBindWhaleyAccountVC.h"
#import "WVRBindWhaleyAccountVC.h"

#import "WVRLoginViewModel.h"

#import <ReactiveObjC/ReactiveObjC.h>

@interface WVRLoginViewController ()<WVRLoginViewDelegate>

@property (nonatomic, strong) WVRLoginView *contentView;

@property (nonatomic, strong) WVRLoginViewModel *loginViewModel;

@end


@implementation WVRLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [WVRAppModel changeStatusBarOrientation:UIInterfaceOrientationPortrait];
    
    if ([self isMemberOfClass:[WVRLoginViewController class]]) {
        
        [self configSelf];
        [self configSubviews];
        [self initLoginRAC];
    }
}

#pragma mark - configration

- (void)configSelf {
    self.title = @"登录";
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 60, 44);
    [rightButton setTitle:@"注册" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:13.5];
    [rightButton addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
}

- (void)configSubviews {
    _contentView = [[WVRLoginView alloc] init];
    _contentView.delegate = self;
    [self.view addSubview:_contentView];
    
    _contentView.frame = self.view.bounds;
    [_contentView updateWithViewStyle:_viewStyle];
}

- (void)initLoginRAC {
    @weakify(self);
    RAC(self.loginViewModel, username) = self.contentView.inputPhoneNumView.textField.rac_textSignal;

    RAC(self.loginViewModel, password) = self.contentView.inputPassWDView.textField.rac_textSignal;
    
    self.contentView.loginBtn.rac_command = [self.loginViewModel loginCmd];
    
    [[[RACObserve(self.loginViewModel, userInfo) skip:1] deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self httpLoginSuccess];
    }];
    [[[RACObserve(self.loginViewModel, tpLoginModel) skip:1] deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self httpOtherLoginSuccessBlock];
    }];

    [[RACObserve(self.loginViewModel, errorModel) skip:1] subscribeNext:^(WVRErrorViewModel*  _Nullable x) {
        NSLog(@"%@", x);
        @strongify(self);
        [self requestFaild:x.errorMsg];
    }];
}

- (void)httpOtherLoginSuccessBlock
{
    SQHideProgress;
    [self showMessageToWindow:self.loginViewModel.tpLoginModel.msg];
    WVRBindWhaleyAccountVC *vc = [[WVRBindWhaleyAccountVC alloc] init];
    vc.viewStyle = WVRRegisterViewStyleInputPhoneNumAndPDForThirdPartyBind;
    vc.avatar = self.loginViewModel.tpLoginModel.avatar;
    vc.thirdOrigin = self.loginViewModel.tpLoginModel.origin;
    vc.nickName = self.loginViewModel.tpLoginModel.nickName;
    vc.loginSuccessBlock = self.loginSuccessBlock;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)buttonClicked:(UIButton *)button {
    [self.loginViewModel.loginCmd execute:nil];
}

- (WVRLoginViewModel *) loginViewModel {
    if (_loginViewModel == nil) {
        _loginViewModel = [[WVRLoginViewModel alloc] init];
    }
    return _loginViewModel;
}

- (void)rightButtonClick {
    WVRRegisterViewController *registerVC = [[WVRRegisterViewController alloc] init];
    registerVC.viewStyle = WVRRegisterViewStyleInputPhoneNum;
    registerVC.loginSuccessBlock = self.loginSuccessBlock;
    [self.navigationController pushViewController:registerVC animated:YES];
}

//#pragma mark - thirdparty login
//
//- (void)thirdpartyLoginClick:(int)tag {
//    
//    [self thirdpartyLoginWithPlatformType:[self mappingPlatformType:tag] successBlock:^(WVRLoginVCThirdpartyModel* model) {
//        [self httpOtherLoginSuccessBlock:model avatar:model.avatar];
//    }];
//}

- (UMSocialPlatformType)mappingPlatformType:(int)tag {
    
    NSDictionary* dic = @{
                          @(QQ_btn_tag): @(UMSocialPlatformType_QQ),
                          @(WX_btn_tag): @(UMSocialPlatformType_WechatSession),
                          @(WB_btn_tag): @(UMSocialPlatformType_Sina) };
    UMSocialPlatformType type = [dic[@(tag)] intValue];
    return type;
}

#pragma mark - WVRLoginViewDelegate

- (void)bindView:(WVRLoginView *)view buttonClickedAtIndex:(NSInteger)index {
    
    switch (index) {
        case ACCOUNT_PWLOGIN_tag:
        {
//            [self accountAndPWLogin];
        }
            break;
        case FORGOTPW_tag:
        {
            [self forgotPW];
        }
            break;
        case SMS_SHORT_LOGIN_tag:
        {
            [self smsShortLogin:view.getPhoneNum];
        }
            break;
        default:
            [self thirtyPClick:index];
            break;
    }
}

-(void)thirtyPClick:(NSInteger)type
{
    switch (type) {
        case QQ_btn_tag:
            [WVRTrackEventMapping curEvent:kEvent_login flag:kEvent_login_burialPoint_qq];
            self.loginViewModel.origin = QQ_btn_tag;
            //            [self thirdpartyLoginClick:QQ_btn_tag];
            break;
        case WX_btn_tag:
            [WVRTrackEventMapping curEvent:kEvent_login flag:kEvent_login_burialPoint_wechat];
            self.loginViewModel.origin = WX_btn_tag;
            //            [self thirdpartyLoginClick:WX_btn_tag];
            break;
        case WB_btn_tag:
            [WVRTrackEventMapping curEvent:kEvent_login flag:kEvent_login_burialPoint_weibo];
            self.loginViewModel.origin = WB_btn_tag;
            //            [self thirdpartyLoginClick:WB_btn_tag];
            break;
        default:
            break;
    }
}
- (void)accountAndPWLogin {
    
    NSString *phoneNum = [_contentView getPhoneNum];
    NSString *pw = [_contentView getPassword];
    
    if (![WVRGlobalUtil validateMobileNumber:phoneNum]) {
        
        SQToast(@"请输入正确手机号");
        
    } else if (pw.length == 0) {
        
        SQToast(@"请输入密码");
        
    } else if (![WVRGlobalUtil validatePassword:pw]) {
        
        SQToast(@"密码格式不对");
    } else {
        
//        [self httpLogin];
    }
}

- (void)forgotPW {
    
    [WVRTrackEventMapping curEvent:kEvent_login flag:kEvent_login_burialPoint_forget];
    
    WVRForgotPWVC *securityLoginVC = [[WVRForgotPWVC alloc] init];
    securityLoginVC.viewStyle = WVRRegisterViewStyleFindOldPassword;
    [self.navigationController pushViewController:securityLoginVC animated:YES];
}

- (void)smsShortLogin:(NSString *)phoneNum {
    
    [WVRTrackEventMapping curEvent:kEvent_login flag:kEvent_login_burialPoint_smsLogin];
    
    WVRRegisterViewController *securityLoginVC = [[WVRRegisterViewController alloc] init];
    securityLoginVC.viewStyle = WVRRegisterViewStyleInputPhoneNumForSecurityLogin;
    securityLoginVC.loginSuccessBlock = self.loginSuccessBlock;
    
    securityLoginVC.phoneNum = phoneNum;
    
    [self.navigationController pushViewController:securityLoginVC animated:YES];
}

- (void)requestFaild:(NSString *)errorStr {
    
    [self hideProgress];
    SQToast(errorStr);
}


//#pragma http login
//- (void)httpLogin {
//    
//    kWeakSelf(self);
//    NSString *phoneNum = [_contentView getPhoneNum];
//    NSString *passWord = [_contentView getPassword];
//    
//    WVRHttpLogin *cmd = [[WVRHttpLogin alloc] init];
//    NSMutableDictionary *httpDic = [[NSMutableDictionary alloc] init];
//    httpDic[kHttpParams_login_direct_device_id] = [WVRUserModel sharedInstance].deviceId;
//    httpDic[kHttpParams_login_direct_username] = phoneNum;
//    httpDic[kHttpParams_login_direct_password] = passWord;
//    httpDic[kHttpParams_login_direct_from] = HTTP_FROM_WHALEYVR;
//    
//    cmd.bodyParams = httpDic;
//    cmd.successedBlock = ^(WVRHttpUserModel * data) {
//        [weakself httpLoginSuccess];
//    };
//    cmd.failedBlock = ^(NSString* errMsg) {
//        NSLog(@"fail msg: %@", errMsg);
//        [weakself requestFaild:errMsg];
//    };
//    [cmd execute];
//}

@end
