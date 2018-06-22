//
//  WVRUserInfoViewModel.m
//  WhaleyVR
//
//  Created by qbshen on 2017/8/23.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRUserInfoViewModel.h"
#import "WVRThirtyPBindUseCase.h"
#import "WVRThirtyPUNBindUseCase.h"

@interface WVRUserInfoViewModel ()

@property (nonatomic, strong) WVRThirtyPBindUseCase * gThirtyPBindUC;

@property (nonatomic, strong) WVRThirtyPUNBindUseCase * gThirtyPUNBindUC;

@end
@implementation WVRUserInfoViewModel
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupRAC];
    }
    return self;
}

-(WVRThirtyPBindUseCase *)gThirtyPBindUC
{
    if (!_gThirtyPBindUC) {
        _gThirtyPBindUC = [[WVRThirtyPBindUseCase alloc] init];
    }
    return _gThirtyPBindUC;
}

-(WVRThirtyPUNBindUseCase *)gThirtyPUNBindUC
{
    if (!_gThirtyPUNBindUC) {
        _gThirtyPUNBindUC = [[WVRThirtyPUNBindUseCase alloc] init];
    }
    return _gThirtyPUNBindUC;
}

- (void)setupRAC {
    @weakify(self);
    [[self.gThirtyPBindUC buildUseCase] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.bind = YES;
    }];
    
    [[self.gThirtyPBindUC buildErrorCase] subscribeNext:^(WVRErrorViewModel *  _Nullable x) {
        @strongify(self);
        self.errorModel = x;
    }];
    
    RAC(self.gThirtyPBindUC, origin) = RACObserve(self, origin);
    [[RACObserve(self, origin) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.gThirtyPBindUC.origin = self.origin;
        self.gThirtyPUNBindUC.origin = self.origin;
        if (!self.isBind) {
            [[self thirtyPartyUNBindCmd] execute:nil];
        }else{
            [[self thirtyPartyBindCmd] execute:nil];
        }
    }];
    [[self.gThirtyPUNBindUC buildUseCase] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.bind = NO;
    }];
    
    [[self.gThirtyPUNBindUC buildErrorCase] subscribeNext:^(WVRErrorViewModel *  _Nullable x) {
        @strongify(self);
        self.errorModel = x;
    }];
    
}

- (RACCommand *)thirtyPartyBindCmd {
    return [self.gThirtyPBindUC getRequestCmd];
}

- (RACCommand *)thirtyPartyUNBindCmd {
    return [self.gThirtyPUNBindUC getRequestCmd];
}

@end
