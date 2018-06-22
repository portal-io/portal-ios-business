//
//  WVRModifyPhoneNumViewController.m
//  WhaleyVR
//
//  Created by zhangliangliang on 9/1/16.
//  Copyright © 2016 Snailvr. All rights reserved.
//

#import "WVRModifyPhoneNumViewController.h"
#import "WVRModifyPhoneNumView.h"
#import "WVRUserModel.h"

#import "WVRModifyPhoneNViewModel.h"

@interface WVRModifyPhoneNumViewController ()

@property (nonatomic, strong) WVRModifyPhoneNumView *contentView;

@property (nonatomic) NSString * mCaptcha;

@property (nonatomic, strong) WVRModifyPhoneNViewModel * gMPhoneNViewModel;

@end

@implementation WVRModifyPhoneNumViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configSelf];
    [self configSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)configSelf
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClick)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:14.0f]} forState:UIControlStateNormal];
    [self.navigationItem setTitle:@"修改手机"];
}

- (void)configSubviews
{
    _contentView = [[WVRModifyPhoneNumView alloc] init];
    [self.view addSubview:_contentView];
    _contentView.frame = self.view.bounds;
    __block WVRModifyPhoneNumViewController* blockSelf = self;
    _contentView.getCodeBlock = ^{
//        [blockSelf httpSMS_token];
        [blockSelf sendSMS];
    };
    _contentView.getCaptchaBlock = ^{
        [blockSelf.contentView setCaptcha:blockSelf.mCaptcha];
    };
    
}

-(WVRModifyPhoneNViewModel *)gMPhoneNViewModel
{
    if (!_gMPhoneNViewModel) {
        _gMPhoneNViewModel = [[WVRModifyPhoneNViewModel alloc] init];
    }
    return _gMPhoneNViewModel;
}

-(void)setUpRAC
{
    @weakify(self);
    [self.gMPhoneNViewModel.completeSignal subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self httpChangePhoneNumSuccessBlock:@"手机号修改成功"];
    }];
    
    [[RACObserve(self.gMPhoneNViewModel, responseCaptcha) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.contentView displayVeryfyCodeInputView];
        [self.contentView setCaptcha:self.gMPhoneNViewModel.responseCaptcha];
    }];
    
    [[RACObserve(self.gMPhoneNViewModel, responseMsg) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        SQToast(x);
    }];
    [[RACObserve(self.gMPhoneNViewModel, responseCode) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.contentView startTimer];
    }];

}


- (void)rightButtonClick
{
    NSString * phoneNum = [_contentView getNewPhoneNum];
    if (![WVRGlobalUtil validateMobileNumber:phoneNum])
    {
        [self showMessageToWindow:@"请输入正确手机号"];
        return;
    }
    
    if ([_contentView getPhoneCode].length == 0)
    {
        [self showMessageToWindow:@"请输入验证码"];
        return;
    }
    
    if (![WVRReachabilityModel isNetWorkOK])
    {
        [self showMessageToWindow:kNetError];
        return;
    }
    self.gMPhoneNViewModel.inputPhoneNum = [self.contentView getNewPhoneNum];
    self.gMPhoneNViewModel.inputCode = [self.contentView getPhoneCode];
    [[self.gMPhoneNViewModel modifyPhoneCmd] execute:nil];
//    [self httpChangePhoneNum];
}

//-(void)httpSMS_token{
//    [self showProgress];
//    WVRHttpSMSToken * cmd = [[WVRHttpSMSToken alloc] init];
//    NSMutableDictionary * httpDic = [[NSMutableDictionary alloc] init];
//    httpDic[kHttpParams_smsToken_device_id] = [WVRUserModel sharedInstance].deviceId;
//    
//    cmd.bodyParams = httpDic;
//    cmd.successedBlock = ^(WVRHttpSMSTokenModel * data) {
//        NSLog(@"sms_token: %@", data.sms_token);
//        [self httpSMS_tokenSuccessBlock:data];
//    };
//    cmd.failedBlock = ^(NSString* errMsg){
//        NSLog(@"fail msg: %@",errMsg);
//        [self hideProgress];
//        [self requestFaild:errMsg];
//    };
//    [cmd execute];
//}
//
//-(void)httpSMS_tokenSuccessBlock:(WVRHttpSMSTokenModel*)data
//{
//    [WVRUserModel sharedInstance].sms_token = data.sms_token;
//    [WVRUserModel sharedInstance].expiration_time = data.expiration_time;
//    [WVRUserModel sharedInstance].now_time = data.now_time;
//    
//    [self sendSMS];
//}

- (void)sendSMS
{
    //    NSString *deviceId= [WVRUserModel sharedInstance].deviceId;
    NSString *phoneNum = [self.contentView getNewPhoneNum];
    
    if (![WVRGlobalUtil validateMobileNumber:phoneNum])
    {
        [self showMessageToWindow:@"请输入正确手机号"];
        return;
    }
    
    if (![WVRReachabilityModel isNetWorkOK])
    {
        [self showMessageToWindow:kNetError];
        return;
    }
    self.gMPhoneNViewModel.inputPhoneNum = [self.contentView getNewPhoneNum];
    self.gMPhoneNViewModel.inputCaptcha = [self.contentView getCaptchaCode];
    [[self.gMPhoneNViewModel sendCodeCmd] execute:nil];
//    [self httpSendSMSCode];
}

//- (void)httpSendSMSCode {
//    WVRHttpSMSForChangePhone * cmd = [[WVRHttpSMSForChangePhone alloc] init];
//    NSMutableDictionary * httpDic = [[NSMutableDictionary alloc] init];
//    httpDic[kHttpParams_sms_changePhoneNum_device_id] = [WVRUserModel sharedInstance].deviceId;//@"b6e7bcd3cd5d4fb2a96d76c670f02a35";//[self deviceId];
//    httpDic[kHttpParams_sms_changePhoneNum_sms_token] = [WVRUserModel sharedInstance].sms_token;
//    httpDic[kHttpParams_sms_changePhoneNum_mobile] = [self.contentView getNewPhoneNum];
//    httpDic[kHttpParams_sms_changePhoneNum_ncode] = @"86";
//    httpDic[kHttpParams_sms_changePhoneNum_captcha] = [self.contentView getCaptchaCode];
//    
//    cmd.bodyParams = httpDic;
//    cmd.successedBlock = ^(WVRWAccountBaseResponse * data) {
//        NSLog(@"success response: %@", [data yy_modelToJSONString]);
//        [self httpSendSMSCodeSuccessBlock:data];
//    };
//    cmd.failedBlock = ^(NSString* errMsg) {
//        NSLog(@"fail msg: %@", errMsg);
//        [self hideProgress];
//        [self requestFaild:errMsg];
//    };
//    [cmd execute];
//    
//}

//-(void)httpSendSMSCodeSuccessBlock:(WVRWAccountBaseResponse * )data
//{
//    [self hideProgress];
//    
//    NSInteger code = [[data code] integerValue];
//    NSString *msg = [data msg];
//    NSDictionary *dataDic = [data data];
//    
//    if (141 == code)
//    {
//        self.mCaptcha = [dataDic objectForKey:@"url"];
//        [self.contentView displayVeryfyCodeInputView];
//        [self.contentView setCaptcha:self.mCaptcha];
//        msg = @"请输入验证码";
//    }else if(000 == code)
//    {
////        self.codeHasbeenGot = YES;
//        [self.contentView startTimer];
//        msg = @"安全码发送成功";
//    }else if(103 == code)
//    {
//        msg = @"安全码错误";
//    }
//    
//    [self showMessageToWindow:msg];
//}

#pragma http changePW

- (void)httpChangePhoneNumSuccessBlock:(NSString *)successStr
{
    [WVRUserModel sharedInstance].isLogined = NO;
    [WVRUserModel sharedInstance].firstLogin = NO;
    
    NSString *message = successStr;
    [self showMessageToWindow:message];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
