//
//  WVRTopBarViewModel.m
//  WVRProgram
//
//  Created by qbshen on 2017/9/15.
//  Copyright © 2017年 snailvr. All rights reserved.
//

#import "WVRLiveReviewViewModel.h"
#import "WVRLiveReviewUseCase.h"
#import "WVRRecommendPageReformer.h"
#import "WVRSectionModel.h"

@interface WVRLiveReviewViewModel ()

@property (nonatomic, strong) WVRLiveReviewUseCase * gLiveReviewUC;

@property (nonatomic, strong) RACSubject * gCompleteSubject;
@property (nonatomic, strong) RACSubject * gFailSubject;

@end
@implementation WVRLiveReviewViewModel
@synthesize mCompleteSignal = _mCompleteSignal;
@synthesize mFailSignal = _mFailSignal;

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self setUpRAC];
    }
    return self;
}

-(WVRLiveReviewUseCase *)gLiveReviewUC
{
    if (!_gLiveReviewUC) {
        _gLiveReviewUC = [[WVRLiveReviewUseCase alloc] init];
    }
    return _gLiveReviewUC;
}


-(void)setUpRAC
{
    RAC(self.gLiveReviewUC, code) = RACObserve(self, code);
    RAC(self.gLiveReviewUC, subCode) = RACObserve(self, subCode);
    @weakify(self);
    [[self.gLiveReviewUC buildUseCase] subscribeNext:^(WVRSectionModel*  _Nullable x) {
        @strongify(self);
        [self.gCompleteSubject sendNext:x];
    }];
    [[self.gLiveReviewUC buildErrorCase] subscribeNext:^(WVRErrorViewModel*  _Nullable x) {
        @strongify(self);
        [self.gFailSubject sendNext:x];
        
    }];
    
}

-(RACSignal *)mCompleteSignal
{
    if (!_mCompleteSignal) {
        @weakify(self);
        _mCompleteSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self);
            self.gCompleteSubject = subscriber;
            return nil;
        }];
    }
    return _mCompleteSignal;
}

-(RACSignal *)mFailSignal
{
    if (!_mFailSignal) {
        @weakify(self);
        _mFailSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self);
            self.gFailSubject = subscriber;
            return nil;
        }];
    }
    return _mFailSignal;
}

-(RACCommand*)getLiveReviewCmd
{
    return [self.gLiveReviewUC getRequestCmd];
}

@end
