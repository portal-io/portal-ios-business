//
//  WVRRegisterViewController.m
//  WhaleyVR
//
//  Created by zhangliangliang on 8/25/16.
//  Copyright © 2016 Snailvr. All rights reserved.
//

#import "WVRRegisterViewController.h"
#import "WVRRegisterView.h"

#import "WVRLoginViewController.h"
#import "WVRUserModel.h"

#import <UMSocialCore/UMSocialCore.h>
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaHandler.h"

#import "WVRBindWhaleyAccountVC.h"
#import "WVRInputNameAndPWVC.h"

#import "WVRRegisterViewModel.h"


@interface WVRRegisterViewController ()<WVRRegisterViewDelegate>

@property (nonatomic, assign) BOOL tokenExists;

@property (nonatomic, strong) WVRRegisterViewModel * gRegisterViewModel;

@end


@implementation WVRRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configSubviews];
    [self configSelf];
    
    _codeHasbeenGot = NO;
    [self initRegisterRAC];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(WVRRegisterViewModel *)gRegisterViewModel
{
    if (!_gRegisterViewModel) {
        _gRegisterViewModel = [[WVRRegisterViewModel alloc] init];
    }
    return _gRegisterViewModel;
}

- (void)initRegisterRAC {
    @weakify(self);
//    RAC(self.gRegisterViewModel, username) = self.contentView.inputPhoneNumView.textField.rac_textSignal;
//    
//    RAC(self.gRegisterViewModel, password) = self.contentView.inputPassWDView.textField.rac_textSignal;
//    
//    self.contentView.loginBtn.rac_command = [self.gRegisterViewModel loginCmd];
    [[[RACObserve(self.gRegisterViewModel, reg_type) skip:1] deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self httpSMSLoginSuccessBlock];
    }];
    
    [[[RACObserve(self.gRegisterViewModel, userInfo) skip:1] deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self httpLoginSuccess];
    }];
    [[[RACObserve(self.gRegisterViewModel, tpLoginModel) skip:1] deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self httpOtherLoginSuccessBlock];
    }];
    
    [[RACObserve(self.gRegisterViewModel, errorModel) skip:1] subscribeNext:^(WVRErrorViewModel*  _Nullable x) {
        NSLog(@"%@", x);
        @strongify(self);
        [self requestFaild:x.errorMsg];
    }];
    [[RACObserve(self.gRegisterViewModel, responseCaptcha) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.contentView displayVeryfyCodeInputView];
        [self.contentView setCaptcha:self.gRegisterViewModel.responseCaptcha];
    }];
    
    [[RACObserve(self.gRegisterViewModel, responseMsg) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        SQToast(x);
    }];
    [[RACObserve(self.gRegisterViewModel, responseCode) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.codeHasbeenGot = YES;
        [self.contentView startTimer];
    }];

}

- (void)httpOtherLoginSuccessBlock
{
    SQHideProgress;
    [self showMessageToWindow:self.gRegisterViewModel.tpLoginModel.msg];
    WVRBindWhaleyAccountVC *vc = [[WVRBindWhaleyAccountVC alloc] init];
    vc.viewStyle = WVRRegisterViewStyleInputPhoneNumAndPDForThirdPartyBind;
    vc.avatar = self.gRegisterViewModel.tpLoginModel.avatar;
    vc.thirdOrigin = self.gRegisterViewModel.tpLoginModel.origin;
    vc.nickName = self.gRegisterViewModel.tpLoginModel.nickName;
    vc.loginSuccessBlock = self.loginSuccessBlock;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)configSelf {
    if (WVRRegisterViewStyleInputPhoneNum == _viewStyle
       || WVRRegisterViewStyleInputNameAndPD == _viewStyle)
    {
        [self setTitle:@"注册微鲸账户"];
        [self.contentView setEventId:kEvent_register];
        
    } else if (WVRRegisterViewStyleInputPhoneNumForSecurityLogin == _viewStyle)
    {
        [self setTitle:@"短信快捷登录"];
        [self.contentView setEventId:kEvent_smsLogin];
        
    } else if (WVRRegisterViewStyleInputPhoneNumAndPDForThirdPartyBind == _viewStyle)
    {
        [self setTitle:@"绑定微鲸账户"];
        [self.contentView setEventId:kEvent_social];
        
    } else if (WVRRegisterViewStyleFindOldPassword == _viewStyle)
    {
        [self setTitle:@"找回密码"];
    }
}

- (void)configSubviews {
    _contentView = [[WVRRegisterView alloc] init];
    _contentView.delegate = self;
    [self.view addSubview:_contentView];
    
    _contentView.frame = self.view.bounds;
    [_contentView updateWithViewStyle:_viewStyle];
    [_contentView setAvatar:_avatar];
    
    [_contentView setPhoneNum:_phoneNum];
}

- (void)rightButtonClick {
    
    WVRLoginViewController *loginVC = [[WVRLoginViewController alloc] init];
    [self.navigationController pushViewController:loginVC animated:YES];
}

- (void)getNewCaptcha {
    
    [_contentView setCaptcha:_captcha];
}

- (BOOL)judgephoneNumber:(NSString *)phoneNum {     // 手机号
    
    NSString *regex = @"[0-9]{11}";
    NSPredicate *passwordText = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [passwordText evaluateWithObject:phoneNum];
}

#pragma mark - http smsLogin 快捷登录 注册接口也用这个

- (void)httpSMSLoginWithOpenId:(NSString *)openId {
    self.gRegisterViewModel.mobile = [self.contentView getPhoneNum];
    self.gRegisterViewModel.code = [self.contentView getSecurityCode];
    [self.gRegisterViewModel.registerCmd execute:nil];
//    kWeakSelf(self);
//    WVRHttpSMSLogin * cmd = [[WVRHttpSMSLogin alloc] init];
//    NSMutableDictionary * httpDic = [[NSMutableDictionary alloc] init];
//    httpDic[kHttpParams_smslogin_device_id] = [WVRUserModel sharedInstance].deviceId;
//    httpDic[kHttpParams_smslogin_from] = HTTP_FROM_WHALEYVR;
//    httpDic[kHttpParams_smslogin_mobile] = [self.contentView getPhoneNum];
//    httpDic[kHttpParams_smslogin_code] = [self.contentView getSecurityCode];
//    httpDic[kHttpParams_smslogin_ncode] = @"86";
//    httpDic[kHttpParams_smslogin_third_id] = openId;
//    
//    cmd.bodyParams = httpDic;
//    cmd.successedBlock = ^(WVRHttpUserModel * data) {
//        [weakself httpSMSLoginSuccessBlock:data];
//    };
//    cmd.failedBlock = ^(NSString* errMsg) {
//        NSLog(@"fail msg: %@",errMsg);
//        [weakself hideProgress];
//        [weakself requestFaild:errMsg];
//    };
//    [cmd execute];
}

- (void)httpSMSLoginSuccessBlock {
    
    [self hideProgress];
    NSString *regType = self.gRegisterViewModel.reg_type;
        if ([self isNewUserWithRegType:regType userName:[WVRUserModel sharedInstance].username]) {
            [self gotoPerfectInfoVC];
        }else{
            [self httpLoginSuccess];
        }
}


- (BOOL)isNewUserWithRegType:(NSString *)regType userName:(NSString *)userName
{
    return [regType isEqualToString:@"new"] || [userName hasPrefix:@"vr_"];
}


#pragma mark - WVRRegisterViewDelegate
- (void)bindView:(WVRRegisterView *)view buttonClickedAtIndex:(NSInteger)index
{
    switch (index) {
        case login_btn_tag:
        {
            [self loginBtnOnClick];
        }
            break;
        case VerifyCode_btn_tag:
            
            [self getNewCaptcha];
            break;
        case security_btn_tag:
            
            if (WVRRegisterViewStyleFindOldPassword == _viewStyle) {
                [self sendSMSForFindOldPW];
            } else{
                self.gRegisterViewModel.mobile = [self.contentView getPhoneNum];
                [[self.gRegisterViewModel sendCodeCmd] execute:nil];
//                [self sendSMSForShortLogin];
            }
            break;
        case QQ_btn_tag:
        {
            [WVRTrackEventMapping curEvent:kEvent_smsLogin flag:kEvent_smsLogin_burialPoint_qq];
            self.gRegisterViewModel.origin = QQ_btn_tag;
//            [self thirdpartyRegisterClick:QQ_btn_tag];
        }
            break;
        case WX_btn_tag:
        {
            [WVRTrackEventMapping curEvent:kEvent_smsLogin flag:kEvent_smsLogin_burialPoint_wechat];
            self.gRegisterViewModel.origin = WX_btn_tag;
//            [self thirdpartyRegisterClick:WX_btn_tag];
        }
            break;
        case WB_btn_tag:
        {
            [WVRTrackEventMapping curEvent:kEvent_smsLogin flag:kEvent_smsLogin_burialPoint_weibo];
            self.gRegisterViewModel.origin = WB_btn_tag;
//            [self thirdpartyRegisterClick:WB_btn_tag];
        }
            break;
        default:
            break;
    }
}

- (void)loginBtnOnClickInputPhoneNumOrSecurityLogin
{
    NSString *phoneNum = [self.contentView getPhoneNum];
    NSString *securityCode = [self.contentView getSecurityCode];
    NSString *captcha = [self.contentView getCaptcha];
    
    if (![WVRGlobalUtil validateMobileNumber:phoneNum])
    {
        SQToast(@"请输入正确手机号");
        return;
    }
    
    if (!self.contentView.verifyCodeViewIsHidden)
    {
        if ([WVRGlobalUtil isEmpty:captcha]) {
            SQToast(@"请输入验证码");
            return;
        }
    }
    
    if (self.codeHasbeenGot) {
        
        if ([WVRGlobalUtil isEmpty:securityCode])
        {
            SQToast(@"请输入安全码");
            return;
        }
        
        [self httpSMSLoginWithOpenId:@""];
    } else {
        
        SQToast(@"未获取安全码");
        return;
    }
}


#pragma mark - loginBtn onClick

- (void)loginBtnOnClick
{
    if (WVRRegisterViewStyleInputPhoneNum == _viewStyle
        || WVRRegisterViewStyleInputPhoneNumForSecurityLogin == _viewStyle)
    {
        [WVRTrackEventMapping curEvent:kEvent_register flag:kEvent_burialPoint_next];
        [self loginBtnOnClickInputPhoneNumOrSecurityLogin];
        
    } else if (WVRRegisterViewStyleInputNameAndPD == _viewStyle)
    {
        [WVRTrackEventMapping curEvent:kEvent_register flag:kEvent_register_burialPoint_register];
        [self loginBtnOnClickInputNameAndPD];
        
    } else if (WVRRegisterViewStyleInputPhoneNumAndPDForThirdPartyBind == _viewStyle)
    {
        [WVRTrackEventMapping curEvent:kEvent_social flag:kEvent_burialPoint_next];
        [self loginBtnInputPhoneNumAndPDForThirdPartyBind];
        
    } else if (WVRRegisterViewStyleFindOldPassword == _viewStyle)
    {
        [self loginBtnOnClickFindOldPassword];
    }
}


//#pragma mark - thirdpartyRegister
//- (void)thirdpartyRegisterClick:(int)tag
//{
//    
//    [self thirdpartyRegisterWithplatformType:[self mappingPlatformType:tag] successBlock:^(WVRLoginVCThirdpartyModel* model) {
//        [self httpOtherLoginSuccessBlock:model avatar:model.avatar];
//    }];
//}

- (void)trackEventWithType:(int)tag
{
    switch (tag) {
        case QQ_btn_tag:
            [WVRTrackEventMapping curEvent:kEvent_register flag:kEvent_register_burialPoint_qq];
            break;
        case WX_btn_tag:
            [WVRTrackEventMapping curEvent:kEvent_register flag:kEvent_register_burialPoint_wechat];
            break;
        case WB_btn_tag:
            [WVRTrackEventMapping curEvent:kEvent_register flag:kEvent_register_burialPoint_weibo];
            break;
    
        default:
            break;
    }
}

- (UMSocialPlatformType)mappingPlatformType:(int)tag
{
    NSDictionary *dic = @{
                          @(QQ_btn_tag):@(UMSocialPlatformType_QQ),
                          @(WX_btn_tag):@(UMSocialPlatformType_WechatSession),
                          @(WB_btn_tag):@(UMSocialPlatformType_Sina) };
    UMSocialPlatformType type = [dic[@(tag)] intValue];
    return type;
}

- (void)requestFaild:(NSString *) errorStr
{
    [self hideProgress];
    [self showMessageToWindow:errorStr];
}

#pragma mark - abstract input nick name and pw class function
- (void)loginBtnOnClickInputNameAndPD
{
    NSAssert(false, @"loginBtnOnClickInputNameAndPD must implement by subclass");

}

#pragma mark - abstract bindWhaley account class function

- (void)loginBtnInputPhoneNumAndPDForThirdPartyBind
{
    NSAssert(false, @"loginBtnInputPhoneNumAndPDForThirdPartyBind must implement by subclass");
}

#pragma mark - abstract forgotPW class function
- (void)sendSMSForFindOldPW{
    NSAssert(false, @"sendSMSForFindOldPW must implement by subclass");
}

- (void)loginBtnOnClickFindOldPassword
{
    NSAssert(false, @"loginBtnOnClickFindOldPassword must implement by subclass");
}

@end
