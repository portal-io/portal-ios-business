//
//  WVRModifyPhoneNViewModel.m
//  WhaleyVR
//
//  Created by qbshen on 2017/8/25.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRModifyPhoneNViewModel.h"
#import "WVRModifyPhoneNUseCase.h"
#import "WVRSendPhoneCodeUseCase.h"
#import "WVRGetPhoneCodeTokenUseCase.h"

@interface WVRModifyPhoneNViewModel ()

@property (nonatomic, strong) WVRModifyPhoneNUseCase * gMPhoneNUC;


@property (nonatomic, strong) WVRSendPhoneCodeUseCase * gSendPCodeUC;

@property (nonatomic, strong) WVRGetPhoneCodeTokenUseCase * gGetCodeTokenUC;


@property (nonatomic, strong) RACSubject * gCompleteSubject;

@end
@implementation WVRModifyPhoneNViewModel
@synthesize completeSignal = _completeSignal;

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self setUpRAC];
    }
    return self;
}

-(WVRModifyPhoneNUseCase *)gMPhoneNUC
{
    if (!_gMPhoneNUC) {
        _gMPhoneNUC = [[WVRModifyPhoneNUseCase alloc] init];
    }
    return _gMPhoneNUC;
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

-(void)setUpRAC
{
    
    RAC(self.gMPhoneNUC, inputCode) = RACObserve(self, inputCode);
    RAC(self.gMPhoneNUC, inputPhoneNum) = RACObserve(self, inputPhoneNum);
    
    @weakify(self);
    [[self.gMPhoneNUC buildUseCase] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.gCompleteSubject sendNext:x];
    }];
    [[self.gMPhoneNUC buildErrorCase] subscribeNext:^(id  _Nullable x) {
        
    }];
    
    RAC(self.gSendPCodeUC, mobile) = RACObserve(self, inputPhoneNum);
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
}


-(RACSignal *)completeSignal
{
    if (!_completeSignal) {
        @weakify(self);
        _completeSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self);
            self.gCompleteSubject = subscriber;
            return nil;
        }];
    }
    return _completeSignal;
}

-(RACCommand*)modifyPhoneCmd
{
    return [self.gMPhoneNUC getRequestCmd];
}

- (RACCommand *)sendCodeCmd
{
    return [self.gGetCodeTokenUC getRequestCmd];
}
@end
