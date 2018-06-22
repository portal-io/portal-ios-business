//
//  WVRBindWhaleyAccountVC.m
//  WhaleyVR
//
//  Created by qbshen on 16/10/21.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRBindWhaleyAccountVC.h"

#import "WVRUserModel.h"

#import "WVRInputNameAndPWVC.h"
#import "WVRReachabilityModel.h"
#import "WVRBindWhaleyAccountViewModel.h"


@interface WVRBindWhaleyAccountVC ()

@property (nonatomic, strong) WVRBindWhaleyAccountViewModel * gBindWAViewModel;

@end
@implementation WVRBindWhaleyAccountVC

-(WVRBindWhaleyAccountViewModel *)gBindWAViewModel
{
    if (!_gBindWAViewModel) {
        _gBindWAViewModel = [[WVRBindWhaleyAccountViewModel alloc] init];
    }
    return _gBindWAViewModel;
}

-(void)initRegisterRAC
{
    @weakify(self);
    [[RACObserve(self.gBindWAViewModel, responseCaptcha) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.contentView displayVeryfyCodeInputView];
        [self.contentView setCaptcha:self.gBindWAViewModel.responseCaptcha];
    }];
    
    [[RACObserve(self.gBindWAViewModel, responseMsg) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        SQToast(x);
    }];
    [[RACObserve(self.gBindWAViewModel, responseCode) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.codeHasbeenGot = YES;
        [self.contentView startTimer];
    }];

    [[RACObserve(self.gBindWAViewModel, reg_type) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self bindAccountSuccessBlock:self.gBindWAViewModel.reg_type];
    }];
}

- (void)sendSMSForShortLogin
{
    NSString *phoneNum = [self.contentView getPhoneNum];
    
    if (![WVRGlobalUtil validateMobileNumber:phoneNum])
    {
        SQToast(@"请输入正确手机号");
        return;
    }
    
    if (!self.contentView.verifyCodeViewIsHidden && (![self.contentView getCaptcha] || [[self.contentView getCaptcha] isEqualToString:@""]))
    {
        SQToast(@"请输入图形验证码");
        return;
    }
    
    if (![WVRReachabilityModel isNetWorkOK])
    {
        SQToast(kNetError);
        return;
    }
    self.gBindWAViewModel.mobile = [self.contentView getPhoneNum];
    [[self.gBindWAViewModel sendCodeCmd] execute:nil];
//    [self httpSMS_token];
}

-(void)loginBtnInputPhoneNumAndPDForThirdPartyBind
{
    NSString *phoneNum = [self.contentView getPhoneNum];
    NSString *securityCode = [self.contentView getSecurityCode];
    NSString *captcha = [self.contentView getCaptcha];
    if (![WVRGlobalUtil validateMobileNumber:phoneNum])
    {
        SQToast(@"请输入正确手机号");
        return;
    }
    
    if (!self.contentView.verifyCodeViewIsHidden) {
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
        self.gBindWAViewModel.code = [self.contentView getSecurityCode];
        self.gBindWAViewModel.thirdOpenId = @"";
        [[self.gBindWAViewModel bindCmd] execute:nil];
//        [self httpThirdLoginOrRegisterAndBindWithOpenId:[WVRUserModel sharedInstance].openIdForBinding];
    }else{
        SQToast(@"请获取安全码");
        return;
    }
    
}

-(void)bindAccountSuccessBlock:(NSString*)reg_type
{
    if ([self isNewUserWithRegType:reg_type userName:[WVRUserModel sharedInstance].username]) {
        [self gotoPerfectInfoVC];
    }else{
        [self httpLoginSuccess];
    }
}

- (BOOL)isNewUserWithRegType:(NSString*) regType userName:(NSString*) userName
{
    return [regType isEqualToString:@"new"] || [userName hasPrefix:@"vr_"];
}

@end
