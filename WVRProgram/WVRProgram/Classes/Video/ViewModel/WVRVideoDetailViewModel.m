//
//  WVRVideoDetailViewModel.m
//  WhaleyVR
//
//  Created by Bruce on 2017/9/4.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRVideoDetailViewModel.h"
#import "WVRVideoDetailUseCase.h"

@interface WVRVideoDetailViewModel()

@property (nonatomic, strong) WVRVideoDetailUseCase * gDetailUC;

@property (nonatomic, strong) RACSubject * gSuccessSubject;
@property (nonatomic, strong) RACSubject * gFailSubject;

@end


@implementation WVRVideoDetailViewModel
@synthesize gSuccessSignal = _gSuccessSignal;
@synthesize gFailSignal = _gFailSignal;

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setUpARC];
    }
    return self;
}

- (WVRVideoDetailUseCase *)gDetailUC {
    
    if (!_gDetailUC) {
        _gDetailUC = [[WVRVideoDetailUseCase alloc] init];
    }
    return _gDetailUC;
}

- (void)setUpARC {
    
    RAC(self.gDetailUC, requestParams) = RACObserve(self, requestParams);
    
    @weakify(self);
    [[self.gDetailUC buildUseCase] subscribeNext:^(WVRVideoDetailVCModel *_Nullable x) {
        @strongify(self);
        self.dataModel = x;
        [self.gSuccessSubject sendNext:x];
    }];
    [[self.gDetailUC buildErrorCase] subscribeNext:^(WVRErrorViewModel *_Nullable x) {
        @strongify(self);
        self.errorModel = x;
        [self.gFailSubject sendNext:x];
    }];
}

- (RACSignal *)gSuccessSignal {
    
    if (!_gSuccessSignal) {
        @weakify(self);
        _gSuccessSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self);
            self.gSuccessSubject = subscriber;
            return nil;
        }];
    }
    return _gSuccessSignal;
}

- (RACSignal *)gFailSignal {
    
    if (!_gFailSignal) {
        @weakify(self);
        _gFailSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self);
            self.gFailSubject = subscriber;
            return nil;
        }];
    }
    return _gFailSignal;
}

- (RACCommand *)gDetailCmd {
    
    return [self.gDetailUC getRequestCmd];
}


@end
