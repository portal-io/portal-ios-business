//
//  WVRFootballPresenter.m
//  WhaleyVR
//
//  Created by qbshen on 2017/5/8.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRFootballPresenter.h"
#import "WVRFootballViewModel.h"
#import "WVRNullCollectionViewCell.h"
#import "WVRLiveCell.h"
#import "WVRLiveEndCell.h"
#import "WVRSQFindSplitCell.h"
#import "WVRSQFindSplitFooter.h"
#import "SQRefreshHeader.h"
#import "WVRFootballViewModel.h"
#import "WVRSectionModel.h"
#import "WVRViewModelDispatcher.h"
#import "WVRBaseViewSection.h"

@interface WVRFootballPresenter ()

@property (nonatomic) WVRFootballViewModel * mFootballVModel;
@property (nonatomic) NSDictionary * mModelDic;

@property (nonatomic) void(^successBlock)();
@property (nonatomic) void(^failBlock)(NSString * errStr);

@end

@implementation WVRFootballPresenter

+ (instancetype)createPresenter:(id)createArgs {
    
    WVRFootballPresenter * presenter = [[WVRFootballPresenter alloc] init];
    presenter.createArgs = createArgs;
    [presenter registerNot];
    [presenter loadSubViews];
    return presenter;
}

- (void)loadSubViews {
    
    self.cellNibNames = @[NSStringFromClass([WVRLiveCell class]),NSStringFromClass([WVRLiveEndCell class]),NSStringFromClass([WVRSQFindSplitCell class])];
    self.headerNibNames = @[];
    self.footerNibNames = @[NSStringFromClass([WVRSQFindSplitFooter class])];
    [self initCollectionView];
}

- (void)registerNot {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSubViews) name:NAME_NOTF_LAYOUTSUBVIEWS_LIVE_RECOMMEND object:nil];
}

- (void)reloadSubViews {
    
    [self installModelDic];
}

- (UIView *)getView {
    
    return self.mCollectionV;
}

- (void)reloadData {
    
    if (self.collectionVOriginDic.count == 0) {
        [self requestInfo];
    }
}

- (void)initCollectionView {
    
    [super initCollectionView];
    kWeakSelf(self);
    SQRefreshHeader * refreshHeader = [SQRefreshHeader headerWithRefreshingBlock:^{
        [weakself requestInfo];
    }];
    refreshHeader.stateLabel.hidden = YES;
    self.mCollectionV.mj_header = refreshHeader;
}

- (void)requestInfo {
    [super requestInfo];
    kWeakSelf(self);
    if (!self.mFootballVModel) {
        self.mFootballVModel = [[WVRFootballViewModel alloc] initWithSuccessBlock:^(NSDictionary<NSNumber *,NSArray *> * _Nullable resultDic) {
            [weakself httpSuccessBlock:resultDic];
        } failBlock:^(NSString * _Nullable errMsg) {
            [weakself httpFailBlock:errMsg];
        }];
    }
    [self.mFootballVModel http_footballListWithCode:self.createArgs];
    if (self.mModelDic.count==0) {
        SQShowProgressIn(self.mCollectionV);
    }
}

- (void)httpSuccessBlock:(NSDictionary *)modelDic {
    
    kWeakSelf(self);
    if (modelDic.count==0) {
        if (self.mModelDic.count==0) {
            
            [self showNetErrorV:weakself.mCollectionV reloadBlock:^{
                [weakself requestInfo];
            }];
        }
        SQHideProgressIn(self.mCollectionV);
        return ;
    }
    [self removeNetErrorV];
    self.mModelDic = modelDic;
    [self installModelDic];
    SQHideProgressIn(self.mCollectionV);
    [self.mCollectionV.mj_header endRefreshing];
}

- (void)installModelDic {
    
    for (NSNumber* cur in self.mModelDic.allKeys) {
        WVRSectionModel* curSectionModel = self.mModelDic[cur];
        
        self.collectionVOriginDic[cur] = [self sectionInfo:curSectionModel];
    }
    [self updateCollectionView];

}

- (WVRBaseViewSection *)sectionInfo:(WVRSectionModel *)sectionModel {
    
//    NSLog(@"recommendAreaType:%ld", (long)sectionModel.sectionType);
    WVRBaseViewSection * sectionInfo = nil;
    NSInteger type = sectionModel.sectionType;
    sectionInfo = [WVRViewModelDispatcher dispatchSection:[NSString stringWithFormat:@"%d", (int)type] args:sectionModel];//[self getADSectionInfo:sectionModel type:type];
    [sectionInfo registerNibForCollectionView:self.mCollectionV];
//    sectionInfo.viewController = self.controller;
    return sectionInfo;
}

- (void)httpFailBlock:(NSString *)errMsg {
    
    SQToastIn(errMsg, self.mCollectionV);
    if (self.mModelDic.count==0) {
        kWeakSelf(self);
        [self showNetErrorV:weakself.mCollectionV reloadBlock:^{
            [weakself removeNetErrorV];
            [weakself requestInfo];
        }];
    }
    SQHideProgressIn(self.mCollectionV);
    [self.mCollectionV.mj_header endRefreshing];
}

- (void)showNetErrorV:(UIView*)parentV reloadBlock:(void(^)())reloadBlock {
    
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

- (void)dealloc {
    
    DebugLog(@"dealloc");
}

@end
