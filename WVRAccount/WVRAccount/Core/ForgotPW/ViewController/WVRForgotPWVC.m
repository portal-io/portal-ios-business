//
//  WVRForgotPWVC.m
//  WhaleyVR
//
//  Created by qbshen on 16/10/21.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRForgotPWVC.h"

//#import "WVRHttpForgotPWSMSCode.h"
//#import "WVRHttpForgotPWValidateCode.h"
#import "WVRModifyPasswordViewController.h"
//#import "WVRHttpSMSToken.h"
#import "WVRUserModel.h"
//#import "WVRHttpSMSCode.h"
//#import "WVRHttpSMSLogin.h"
#import "WVRForgotPWViewModel.h"

@interface WVRForgotPWVC ()

@property (nonatomic, strong) WVRForgotPWViewModel* gForgotViewModel;

@end
@implementation WVRForgotPWVC

-(void)initRegisterRAC
{
    @weakify(self);
    [self.gForgotViewModel.gSendCodeCompleteSignal subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self httpForgotPWSMSCodeSuccessBlock:x];
    }];
    [self.gForgotViewModel.gValidCodeCompleteSignal subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self httpForgotPWValidateCodeSuccessBlock:x];
    }];
}

-(WVRForgotPWViewModel *)gForgotViewModel
{
    if (!_gForgotViewModel) {
        _gForgotViewModel = [[WVRForgotPWViewModel alloc] init];
    }
    return _gForgotViewModel;
}

- (void)sendSMSForFindOldPW
{
    NSString *phoneNum = [self.contentView getPhoneNum];
    if (![WVRGlobalUtil validateMobileNumber:phoneNum])
    {
        SQToast(@" 请输入正确手机号");
        return;
    }
    [self showProgress];
//    [self httpUser:phoneNum];
    self.gForgotViewModel.inputPhoneNum = phoneNum;
    [[self.gForgotViewModel sendCodeCmd] execute:nil];
}

-(void)loginBtnOnClickFindOldPassword
{
    NSString *phoneNum = [self.contentView getPhoneNum];
    NSString *securityCode = [self.contentView getSecurityCode];
    NSString *captcha = [self.contentView getCaptcha];
    if (![WVRGlobalUtil validateMobileNumber:phoneNum])
    {
        [self showMessageToWindow:@"请输入正确手机号"];
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
        
        self.gForgotViewModel.inputCode = [self.contentView getSecurityCode];
        
        [[self.gForgotViewModel validCmd] execute:nil];
//        [self httpForgotPWValidateCode];
        
    }else{
        
        SQToast(@"请获取安全码");
        return;
    }
    
}

//#pragma http user
//-(void)httpUser:(NSString*)phoneNum{
//    WVRHttpUser * cmd = [[WVRHttpUser alloc] init];
//    NSMutableDictionary * httpDic = [[NSMutableDictionary alloc] init];
//    httpDic[kHttpParams_user_account] = phoneNum;
//    
//    cmd.bodyParams = httpDic;
//    cmd.successedBlock = ^(WVRHttpUserModel * data){
//        [self httpUserSuccessBlock:data];
//    };
//    cmd.failedBlock = ^(NSString* errMsg){
//        NSLog(@"fail msg: %@",errMsg);
//        [self requestFaild:errMsg];
//    };
//    [cmd execute];
//}
//
//-(void)httpUserSuccessBlock:(WVRHttpUserModel*)data
//{
//    NSString *phoneNum = [self.contentView getPhoneNum];
//    [self httpForgotPWSMSCode:phoneNum];
//}
//
//#pragma http forgotPW smsCode
//-(void)httpForgotPWSMSCode:(NSString*)phoneNum{
//    WVRHttpForgotPWSMSCode * cmd = [[WVRHttpForgotPWSMSCode alloc] init];
//    NSMutableDictionary * httpDic = [[NSMutableDictionary alloc] init];
//    httpDic[kHttpParams_forgotPWSMSCode_account] = phoneNum;
//    
//    cmd.bodyParams = httpDic;
//    cmd.successedBlock = ^(NSString * successStr){
//        [self httpForgotPWSMSCodeSuccessBlock:successStr];
//    };
//    cmd.failedBlock = ^(NSString* errMsg){
//        NSLog(@"fail msg: %@",errMsg);
//        [self requestFaild:errMsg];
//    };
//    [cmd loadData];
//}
//
-(void)httpForgotPWSMSCodeSuccessBlock:(NSString*)successStr
{
    [self hideProgress];
    self.codeHasbeenGot = YES;
    [self.contentView startTimer];
    SQToast(@"安全码发送成功");
}
//
//#pragma http forgotPW smsCode
//-(void)httpForgotPWValidateCode{
//    NSString *securityCode = [self.contentView getSecurityCode];
//    WVRHttpForgotPWValidateCode * cmd = [[WVRHttpForgotPWValidateCode alloc] init];
//    NSMutableDictionary * httpDic = [[NSMutableDictionary alloc] init];
//    httpDic[kHttpParams_forgotPW_validate_code] = securityCode;
//    
//    cmd.bodyParams = httpDic;
//    cmd.successedBlock = ^(NSString * successStr){
//        [self httpForgotPWValidateCodeSuccessBlock:successStr];
//    };
//    cmd.failedBlock = ^(NSString* errMsg){
//        NSLog(@"fail msg: %@",errMsg);
//        [self requestFaild:errMsg];
//    };
//    [cmd loadData];
//}

-(void)httpForgotPWValidateCodeSuccessBlock:(NSString*)successStr
{
    NSString *securityCode = [self.contentView getSecurityCode];
    WVRModifyPasswordViewController *modifyPasswordVC = [[WVRModifyPasswordViewController alloc] init];
    modifyPasswordVC.isFindOldPWMode = YES;
    modifyPasswordVC.smsCode = securityCode;
    [self.navigationController pushViewController:modifyPasswordVC animated:YES];
    
}

@end
