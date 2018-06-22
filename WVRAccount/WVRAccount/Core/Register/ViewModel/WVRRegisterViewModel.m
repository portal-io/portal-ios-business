//
//  WVRRegisterViewModel.m
//  WhaleyVR
//
//  Created by qbshen on 2017/8/24.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRRegisterViewModel.h"
#import "WVRUserModel.h"
#import "WVRRegisterUseCase.h"
#import "WVRThirtyPLoginUseCase.h"
#import "WVRThirtyPLoginModel.h"
#import "WVRSendPhoneCodeUseCase.h"
#import "WVRGetPhoneCodeTokenUseCase.h"

@interface WVRRegisterViewModel ()

@property (nonatomic, strong) WVRRegisterUseCase * gRegisterUC;

@property (nonatomic, strong) WVRThirtyPLoginUseCase * gTPLoginUC;

@property (nonatomic, strong) WVRSendPhoneCodeUseCase * gSendPCodeUC;

@property (nonatomic, strong) WVRGetPhoneCodeTokenUseCase * gGetCodeTokenUC;

@end
@implementation WVRRegisterViewModel
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupRAC];
    }
    return self;
}

-(WVRRegisterUseCase *)gRegisterUC
{
    if (!_gRegisterUC) {
        _gRegisterUC = [[WVRRegisterUseCase alloc] init];
    }
    return _gRegisterUC;
}

-(WVRThirtyPLoginUseCase *)gTPLoginUC
{
    if (!_gTPLoginUC) {
        _gTPLoginUC = [[WVRThirtyPLoginUseCase alloc] init];
    }
    return _gTPLoginUC;
}

-(WVRSendPhoneCodeUseCase *)gSendPCodeUC
{
    if (!_gSendPCodeUC) {
        _gSendPCodeUC = [[WVRSendPhoneCodeUseCase alloc] init];
    }
    return _gSendPCodeUC;
}

-(WVRGetPhoneCodeTokenUseCase *)gGetCodeTokenUC
{
    if (!_gGetCodeTokenUC) {
        _gGetCodeTokenUC = [[WVRGetPhoneCodeTokenUseCase alloc] init];
    }
    return _gGetCodeTokenUC;
}

- (void)setupRAC {
    @weakify(self);
    RAC(self.gSendPCodeUC, mobile) = RACObserve(self, mobile);
    RAC(self.gSendPCodeUC, inputCaptcha) = RACObserve(self, inputCaptcha);
    RAC(self.gSendPCodeUC, smsToken) = RACObserve(self.gGetCodeTokenUC, smsToken);
//    RACObserve(self.gSendPCodeUC, <#KEYPATH#>)
    [[self.gSendPCodeUC buildUseCase] subscribeNext:^(WVRNetworkingResponse* value) {
        @strongify(self);
        NSInteger code = [value.content[@"code"] integerValue];
        NSString *msg = value.content[@"msg"];
        NSDictionary *dataDic = value.content[@"data"];
        
        if (141 == code)
        {
            self.responseCaptcha = (NSString *)[dataDic objectForKey:@"url"];
            msg = @"请输入图形验证码";
            
        } else if (000 == code)
        {
            msg = @"安全码发送成功";
            self.responseCode = [NSString stringWithFormat:@"%d",(int)code];
        } else if(103 == code)
        {
            msg = @"图形验证码验证码失败";
        }
        self.responseMsg = msg;
    }];
    [[self.gGetCodeTokenUC buildUseCase] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [[self.gSendPCodeUC getRequestCmd] execute:nil];
    }];
    RAC(self.gRegisterUC, mobile) = RACObserve(self, mobile);
    RAC(self.gRegisterUC, code) = RACObserve(self, code);
    
    [[self.gRegisterUC buildUseCase] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.reg_type = [x reg_type];
    }];
    
    [[self.gRegisterUC buildErrorCase] subscribeNext:^(WVRErrorViewModel *  _Nullable x) {
        @strongify(self);
        self.errorModel = x;
    }];
    

    RAC(self.gTPLoginUC, origin) = RACObserve(self, origin);
    [[RACObserve(self, origin) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.gTPLoginUC.origin = self.origin;
        [[self thirtyPartyLoginCmd] execute:nil];
    }];
    [[self.gTPLoginUC buildUseCase] subscribeNext:^(id _Nullable x) {
        @strongify(self);
        if ([x isKindOfClass:[WVRThirtyPLoginModel class]]) {
            self.tpLoginModel = x;
        }else{
            self.userInfo = x;
        }
    }];
    [[self.gTPLoginUC buildErrorCase] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.errorModel = x;
    }];
}



- (RACCommand *)sendCodeCmd
{
    return [self.gGetCodeTokenUC getRequestCmd];
}


- (RACCommand *)registerCmd
{
    return [self.gRegisterUC getRequestCmd];
}

- (RACCommand *)thirtyPartyLoginCmd {
    return [self.gTPLoginUC getRequestCmd];
}

@end
