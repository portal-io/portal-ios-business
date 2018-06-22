//
//  WVRPageRecommendPresenterImpl.m
//  WhaleyVR
//
//  Created by qbshen on 2017/3/23.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRPageRecommendPresenter.h"


#import "WVRManualArrangeViewModel.h"
#import "WVRBaseViewSection.h"
#import "WVRBaseCollectionView.h"
#import "WVRViewModelDispatcher.h"
#import "WVRPageRecommendViewModel.h"

@interface WVRPageRecommendPresenter()

@property (nonatomic, strong) WVRManualArrangeViewModel * gViewModel;

@property (nonatomic, strong) NSMutableDictionary * originDic;

@property (nonatomic, strong) WVRPageRecommendViewModel * gPageRecommendViewModel;
@end

@implementation WVRPageRecommendPresenter

@page(([NSString stringWithFormat:@"%d%@",(int)WVRLinkTypeMix,RECOMMENDPAGETYPE_PAGE]), NSStringFromClass([WVRPageRecommendPresenter class]))

- (instancetype)initWithParams:(id)params attchView:(id<WVRCollectionViewProtocol>)view {
    
    self = [super init];
    if (self) {
        self.args = params;
        self.collectionViewDelegte = [SQCollectionViewDelegate new];
        self.gView = view;
        [self installRAC];
    }
    return self;
}


-(WVRManualArrangeViewModel *)gViewModel
{
    if (!_gViewModel) {
        _gViewModel = [[WVRManualArrangeViewModel alloc] init];
    }
    return _gViewModel;
}


-(WVRPageRecommendViewModel *)gPageRecommendViewModel
{
    if (!_gPageRecommendViewModel) {
        _gPageRecommendViewModel = [[WVRPageRecommendViewModel alloc] init];
    }
    return _gPageRecommendViewModel;
}

-(void)installRAC
{
    @weakify(self);
    [[self.gPageRecommendViewModel mCompleteSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self httpSuccessBlock:x];
    }];
    [[self.gPageRecommendViewModel mFailSignal] subscribeNext:^(WVRErrorViewModel*  _Nullable x) {
        @strongify(self);
        [self httpFailBlock:x.errorMsg];
    }];
}


-(void)fetchData
{
    [self requestData];
}

- (void)requestData {
//    kWeakSelf(self);
    [self.gView clear];
    if (self.originDic.count==0) {
        [self.gView showLoadingWithText:nil];
    }
    self.gPageRecommendViewModel.code = [self.args linkArrangeValue];
    [[self.gPageRecommendViewModel getPageRecommendCmd] execute:nil];
//    [self.gViewModel requestData:[self.args linkArrangeValue] successBlock:^(id<WVRModelProtocol>args) {
//        [weakself httpSuccessBlock:args];
//    } failBlock:^(id<WVRErrorProtocol> error) {
//        [weakself httpFailBlock:@""];
//    }];
    //    [WVRManualArrangeViewModel http_recommendPageWithCode:[self.args linkArrangeValue] successBlock:^(WVRSectionModel *args) {
    //        [weakself httpSuccessBlock:args];
    //    } failBlock:^(NSString *args) {
    //        [weakself httpFailBlock:args];
    //    }];
}

- (void)requestInfo:(id)requestParams {
    self.args = requestParams;
    [self requestData];
}

- (void) headerRefreshRequestInfo:(id)requestParams {
    self.args = requestParams;
    [self headerRefreshRequest:YES requestParams:requestParams? requestParams:self.args];
}

- (void)headerRefreshRequest:(BOOL)firstRequest requestParams:(id)requestParams {
    self.args = requestParams;
    kWeakSelf(self);
    [self.gViewModel requestData:[self.args linkArrangeValue] successBlock:^(id<WVRModelProtocol>args) {
        [weakself httpSuccessBlock:args];
    } failBlock:^(id<WVRErrorProtocol> error) {
        [weakself httpFailBlock:@""];
    }];
}

- (void)httpSuccessBlock:(WVRSectionModel *)args {
    
    [self.gView hidenLoading];
    [self parseInfoToOriginDic:args];
}

- (void)httpFailBlock:(NSString *)args {
    [self.gView hidenLoading];
    if (self.originDic.count == 0) {
        kWeakSelf(self);
        [self.gView showNetErrorVWithreloadBlock:^{
            [weakself requestData];
        }];
    }
}

- (void)parseInfoToOriginDic:(WVRSectionModel *)args {
    
    if (!self.originDic) {
        self.originDic = [NSMutableDictionary dictionary];
    }
    [self.originDic removeAllObjects];
    
    WVRBaseViewSection * sectionInfo = [self sectionInfo:args];
    kWeakSelf(self);
    kWeakSelf(sectionInfo);
    sectionInfo.refreshBlock = ^{
        [(WVRBaseCollectionView *)weakself.collectionView updateWithSectionIndex:weaksectionInfo.sectionIndex];
    };
    self.originDic[@(0)] = sectionInfo;
    [self.gView setDelegate:self.collectionViewDelegte andDataSource:self.collectionViewDelegte];
    [self.collectionViewDelegte loadData:self.originDic];
    [self.gView reloadData];
}

@end
