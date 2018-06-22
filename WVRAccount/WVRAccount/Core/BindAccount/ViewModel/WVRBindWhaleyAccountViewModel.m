//
//  WVRBindWhaleyAccountViewModel.m
//  WhaleyVR
//
//  Created by qbshen on 2017/8/25.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRBindWhaleyAccountViewModel.h"
#import "WVRThirtyPBindUseCase.h"
#import "WVRThirtyPUNBindUseCase.h"
#import "WVRSendPhoneCodeUseCase.h"
#import "WVRGetPhoneCodeTokenUseCase.h"
#import "WVRRegisterUseCase.h"

@interface WVRBindWhaleyAccountViewModel ()

@property (nonatomic, strong) WVRSendPhoneCodeUseCase * gSendPCodeUC;

@property (nonatomic, strong) WVRGetPhoneCodeTokenUseCase * gGetCodeTokenUC;

@property (nonatomic, strong) WVRThirtyPBindUseCase * gThirtyPBindUC;

@property (nonatomic, strong) WVRRegisterUseCase * gRegisterUC;


@end

@implementation WVRBindWhaleyAccountViewModel

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

-(WVRThirtyPBindUseCase *)gThirtyPBindUC
{
    if (!_gThirtyPBindUC) {
        _gThirtyPBindUC = [[WVRThirtyPBindUseCase alloc] init];
    }
    return _gThirtyPBindUC;
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
    [[self.gThirtyPBindUC buildUseCase] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
//        self.bind = YES;
        self.reg_type = [x reg_type];
    }];
    
    [[self.gThirtyPBindUC buildErrorCase] subscribeNext:^(WVRErrorViewModel *  _Nullable x) {
        @strongify(self);
        self.errorModel = x;
    }];
    
    RAC(self.gThirtyPBindUC, origin) = RACObserve(self, origin);
    
    RAC(self.gRegisterUC, mobile) = RACObserve(self, mobile);
    RAC(self.gRegisterUC, code) = RACObserve(self, code);
    RAC(self.gRegisterUC, thirdOpenId) = RACObserve(self, thirdOpenId);
    [[self.gRegisterUC buildUseCase] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [[self thirtyPartyBindCmd] execute:nil];
//        self.reg_type = [x reg_type];
    }];
    
    [[self.gRegisterUC buildErrorCase] subscribeNext:^(WVRErrorViewModel *  _Nullable x) {
        @strongify(self);
        self.errorModel = x;
    }];
}

-(RACCommand*)sendCodeCmd
{
    return [self.gGetCodeTokenUC getRequestCmd];
}

- (RACCommand *)thirtyPartyBindCmd {
    return [self.gThirtyPBindUC getRequestCmd];
}

-(RACCommand*)bindCmd
{
    return [self.gRegisterUC getRequestCmd];
}


@end
