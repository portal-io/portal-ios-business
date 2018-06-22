//
//  WVRLiveViewController.m
//  WhaleyVR
//
//  Created by Snailvr on 16/8/31.
//  Copyright © 2016年 Snailvr. All rights reserved.

// 直播

#import "WVRLiveReViewPresenter.h"
#import "SQRefreshHeader.h"
#import "SQRefreshFooter.h"
#import "WVRSetViewModel.h"
#import "WVRLiveGotoTool.h"
#import "WVRGotoNextTool.h"
#import "WVRLiveReviewCell.h"

#import "WVRLiveReviewViewModel.h"

#define PAGE_COUNT (2)

@interface WVRLiveReViewPresenter ()


@property (nonatomic) WVRSetViewModel * mLiveReModel;
@property (nonatomic) WVRSectionModel * mSModel;

@property (nonatomic, strong) WVRLiveReviewViewModel * gLiveReviewViewModel;

@end


@implementation WVRLiveReViewPresenter

+ (instancetype)createPresenter:(id)createArgs {
    
    WVRLiveReViewPresenter * presenter = [[WVRLiveReViewPresenter alloc] init];
    presenter.createArgs = createArgs;
    presenter.cellNibNames = @[NSStringFromClass([WVRLiveReviewCell class])];
    presenter.mLiveReModel = [WVRSetViewModel new];
    [presenter loadViews];
    [presenter installRAC];
    return presenter;
}

- (void)loadViews {
    
    [self initCollectionView];
}

- (UIView *)getView {
    
    return self.mCollectionV;
}

- (void)reloadData {
    
    if (self.collectionVOriginDic.count == 0) {
        [self requestInfo];
    }
}

-(WVRLiveReviewViewModel *)gLiveReviewViewModel
{
    if (!_gLiveReviewViewModel) {
        _gLiveReviewViewModel = [[WVRLiveReviewViewModel alloc] init];
    }
    return _gLiveReviewViewModel;
}

-(void)installRAC
{
    @weakify(self);
    [[self.gLiveReviewViewModel mCompleteSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self httpSuccessBlock:x];
    }];
    [[self.gLiveReviewViewModel mFailSignal] subscribeNext:^(WVRErrorViewModel*  _Nullable x) {
        @strongify(self);
        [self httpFailBlock:x.errorMsg];
    }];
}

- (void)initCollectionView {
    
    [super initCollectionView];
    kWeakSelf(self);
    SQRefreshHeader * refreshHeader = [SQRefreshHeader headerWithRefreshingBlock:^{
        [weakself requestInfo];
    }];
    refreshHeader.stateLabel.hidden = YES;
    self.mCollectionV.mj_header = refreshHeader;
    SQRefreshFooter * refreshFooter = [SQRefreshFooter footerWithRefreshingBlock:^{
        [weakself removeNetErrorV];
        [weakself footerMoreRequest];
    }];
    self.mCollectionV.mj_footer = refreshFooter;
}

- (void)requestInfo {
    
    [super requestInfo];
    [self removeNetErrorV];
    if (self.mSModel==nil) {
        SQShowProgressIn(self.mCollectionV);
    }
    self.gLiveReviewViewModel.code = [self.createArgs linkCode];
    self.gLiveReviewViewModel.subCode = [self.createArgs subCode];
    [[self.gLiveReviewViewModel getLiveReviewCmd] execute:nil];
//    kWeakSelf(self);
//    [self.mLiveReModel http_recommendElementsByCode:[self.createArgs linkCode] subCode:[self.createArgs subCode] successBlock:^(WVRSectionModel *args) {
////        [weakself httpSuccessBlock:args];
//        [weakself httpSuccessUI:args];
//    } failBlock:^(NSString *errMsg) {
////        [weakself httpFailBlock:errMsg];
//        [weakself httpFailUI:errMsg];
//    }];
}

- (void)httpSuccessBlock:(WVRSectionModel *)sectionModel
{
    kWeakSelf(self);
    if (sectionModel==nil) {
        if (self.mSModel==nil) {
            
            [self showNetErrorV:weakself.mCollectionV reloadBlock:^{
                [weakself requestInfo];
            }];
        }
        SQHideProgressIn(self.mCollectionV);
        return ;
    }
    [self removeNetErrorV];
    self.mSModel = sectionModel;
    self.collectionVOriginDic[@(0)] = [self getSectionInfo];
    [self updateCollectionView];
    SQHideProgressIn(self.mCollectionV);
    [self.mCollectionV.mj_header endRefreshing];
}

- (void)footerMoreRequest {
    
    if (self.mSModel.pageNum == self.mSModel.totalPages-1) {
        [self endRefreshNoMore];
        return;
    }
    if (self.collectionVOriginDic.count==0) {
        SQShowProgressIn(self.mCollectionV);
    }
    [[self.gLiveReviewViewModel getLiveReviewCmd] execute:nil];
//    kWeakSelf(self);
//    [self.mLiveReModel http_morerecommendElementsByCode:[self.createArgs linkCode] subCode:[self.createArgs subCode] successBlock:^(WVRSectionModel *args) {
//        [weakself httpSuccessUI:args];
//    } failBlock:^(NSString *errMsg) {
//        [weakself httpFailUI:errMsg];
//    }];
}

- (void)httpSuccessUI:(WVRSectionModel*)args {
    
    SQHideProgressIn(self.mCollectionV);
    [self endRefresh];
//    self.mSModel.itemModels = args.itemModels;
    self.mSModel = args;
//    self.mSModel.pageNum = args.pageNum;
//    self.mSModel.totalPages = args.totalPages;
    self.collectionVOriginDic[@(0)] = [self getSectionInfo];
    [self updateCollectionView];
}

- (void)httpFailBlock:(NSString*)errMsg {
    
    SQHideProgressIn(self.mCollectionV);
    kWeakSelf(self);
    SQToastInKeyWindow(errMsg);
    [self endRefresh];
    if (self.mSModel.itemModels.count==0) {
        [self showNetErrorV:weakself.mCollectionV reloadBlock:^{
            [weakself requestInfo];
        }];
    }
}


- (void)endRefresh {
    
    [self.mCollectionV.mj_header endRefreshing];
    [self.mCollectionV.mj_footer endRefreshing];
}

- (void)endRefreshNoMore {
    
    [self.mCollectionV.mj_footer endRefreshingWithNoMoreData];
}

- (SQCollectionViewSectionInfo *)getSectionInfo {
    
    SQCollectionViewSectionInfo* sectionInfo = [SQCollectionViewSectionInfo new];
    kWeakSelf(self);
    NSMutableArray * cellInfos = [NSMutableArray array];
    for (WVRSectionModel* model in self.mSModel.itemModels) {
        WVRLiveReviewCellInfo * cellInfo = [WVRLiveReviewCellInfo new];
        cellInfo.cellNibName = NSStringFromClass([WVRLiveReviewCell class]);
        cellInfo.cellSize = CGSizeMake(SCREEN_WIDTH, fitToWidth(214.0f));
        cellInfo.itemModel = model;
        cellInfo.gotoNextBlock = ^(id args){
            [weakself cellInfoNextBlock:model];
        };
        [cellInfos addObject:cellInfo];
    }
    
    sectionInfo.cellDataArray = cellInfos;
    return sectionInfo;
}

- (void)cellInfoNextBlock:(WVRSectionModel *)model {
    
    [WVRGotoNextTool gotoNextVC:model nav:self.controller.navigationController];
}

- (void)gotoMoreVC:(WVRBaseModel*)model {
    
    [WVRGotoNextTool gotoNextVC:model nav:self.controller.navigationController];
}

- (void)showNetErrorV:(UIView *)parentV reloadBlock:(void(^)())reloadBlock {
    
    SQHideProgressIn(parentV);
    [self.mNullView removeFromSuperview];
    if (!self.mErrorView) {
        self.mErrorView = [WVRNetErrorView errorViewForViewReCallBlock:^{
            reloadBlock();
        } withParentFrame:parentV.frame];
    }
    [parentV addSubview:self.mErrorView];
}

- (void)removeNetErrorV {
    
    SQHideProgressIn(self.mCollectionV);
    [self.mErrorView removeFromSuperview];
    [self.mNullView removeFromSuperview];
}


- (void)showNullView:(UIView*)parentV title:(NSString*)title icon:(NSString*)icon {
    
    SQHideProgressIn(parentV);
    [self.mErrorView removeFromSuperview];
    if (!self.mNullView) {
        self.mNullView = [[WVRNullCollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, parentV.width, parentV.height)];
        [self.mNullView resetImageToCenter];
        [self.mNullView setTint:title];
        [self.mNullView setImageIcon:icon];
    }
    [parentV addSubview:self.mNullView];
}

- (void)removeNullView {
    
    SQHideProgressIn(self.mCollectionV);
    [self.mNullView removeFromSuperview];
    [self.mErrorView removeFromSuperview];
}

- (void)updateCollectionView {
    
    [self.collectionDelegate loadData:self.collectionVOriginDic];
    [self.mCollectionV reloadData];
}

@end


@implementation WVRLiveReViewPModel

@end
