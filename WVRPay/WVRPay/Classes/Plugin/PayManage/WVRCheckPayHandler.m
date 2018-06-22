//
//  WVRCheckPayHandler.m
//  WhaleyVR
//
//  Created by qbshen on 2017/9/1.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRCheckPayHandler.h"
#import "WVRCheckPayUseCase.h"

@interface WVRCheckPayHandler ()

@property (nonatomic, strong) WVRCheckPayUseCase * gCheckPayUC;

@property (nonatomic, strong) RACSubject * gSuccessSubject;
@property (nonatomic, strong) RACSubject * gFailSubject;

@end

@implementation WVRCheckPayHandler
@synthesize successSignal = _successSignal;
@synthesize failSignal = _failSignal;

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self installRAC];
    }
    return self;
}

-(void)installRAC
{
    RAC(self.gCheckPayUC, payModel) = RACObserve(self, gPayModel);
    @weakify(self);
    [[self.gCheckPayUC buildUseCase] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.gSuccessSubject sendNext:x];
    }];
    [[self.gCheckPayUC buildErrorCase] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.gFailSubject sendNext:@"网络异常"];
    }];
}

-(WVRCheckPayUseCase *)gCheckPayUC
{
    if (!_gCheckPayUC) {
        _gCheckPayUC = [[WVRCheckPayUseCase alloc] init];
    }
    return _gCheckPayUC;
}

-(RACSignal *)successSignal
{
//    if (!_successSignal) {
        @weakify(self);
        _successSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self);
            self.gSuccessSubject = subscriber;
            return nil;
        }];
//    }
    return _successSignal;
}

-(RACSignal *)failSignal
{
//    if (!_failSignal) {
        @weakify(self);
        _failSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self);
            self.gFailSubject = subscriber;
            return nil;
        }];
//    }
    return _failSignal;
}

-(RACCommand *)checkPayCmd
{
    return [self.gCheckPayUC checkPayCmd];
}
@end
