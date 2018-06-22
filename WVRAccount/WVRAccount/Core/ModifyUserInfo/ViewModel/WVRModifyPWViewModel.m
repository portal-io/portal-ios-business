//
//  WVRModifyPWViewModel.m
//  WhaleyVR
//
//  Created by qbshen on 2017/8/25.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRModifyPWViewModel.h"
#import "WVRModifyPWUseCase.h"
#import "WVRForgotPWUseCase.h"

@interface WVRModifyPWViewModel ()

@property (nonatomic, strong) WVRModifyPWUseCase * gModifyPWUC;
@property (nonatomic, strong) RACSubject * gMCompleteSubject;

@property (nonatomic, strong) WVRForgotPWUseCase * gForgotPWUC;
@property (nonatomic, strong) RACSubject * gFCompleteSubject;

@end

@implementation WVRModifyPWViewModel
@synthesize mCompleteSignal = _mCompleteSignal;
@synthesize fCompleteSignal = _fCompleteSignal;

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self setUpRAC];
    }
    return self;
}

-(WVRModifyPWUseCase *)gModifyPWUC
{
    if (!_gModifyPWUC) {
        _gModifyPWUC = [[WVRModifyPWUseCase alloc] init];
    }
    return _gModifyPWUC;
}

-(WVRForgotPWUseCase *)gForgotPWUC
{
    if (!_gForgotPWUC) {
        _gForgotPWUC = [[WVRForgotPWUseCase alloc] init];
    }
    return _gForgotPWUC;
}

-(void)setUpRAC
{
    RAC(self.gModifyPWUC, oldPW) = RACObserve(self, oldPW);
    RAC(self.gModifyPWUC, inputPW) = RACObserve(self, inputPW);
    @weakify(self);
    [[self.gModifyPWUC buildUseCase] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.gMCompleteSubject sendNext:x];
    }];
    [[self.gModifyPWUC buildErrorCase] subscribeNext:^(id  _Nullable x) {
        
    }];
    
    RAC(self.gForgotPWUC, inputCode) = RACObserve(self, inputCode);
    RAC(self.gForgotPWUC, inputPW) = RACObserve(self, inputPW);
    
    [[self.gForgotPWUC buildUseCase] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.gFCompleteSubject sendNext:x];
    }];
    [[self.gForgotPWUC buildErrorCase] subscribeNext:^(id  _Nullable x) {
        
    }];
}

-(RACSignal *)mCompleteSignal
{
    if (!_mCompleteSignal) {
        @weakify(self);
        _mCompleteSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self);
            self.gMCompleteSubject = subscriber;
            return nil;
        }];
    }
    return _mCompleteSignal;
}

-(RACSignal *)fCompleteSignal
{
    if (!_fCompleteSignal) {
        @weakify(self);
        _fCompleteSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self);
            self.gFCompleteSubject = subscriber;
            return nil;
        }];
    }
    return _fCompleteSignal;
}

-(RACCommand*)modifyPWCmd
{
    return [self.gModifyPWUC getRequestCmd];
}

-(RACCommand*)forgotPWCmd
{
    return [self.gForgotPWUC getRequestCmd];
}

@end
