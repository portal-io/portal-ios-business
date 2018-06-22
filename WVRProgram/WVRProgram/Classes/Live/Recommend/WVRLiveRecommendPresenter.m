//
//  WVRLivePresenter.m
//  WhaleyVR
//
//  Created by qbshen on 2017/2/11.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRLiveRecommendPresenter.h"
#import "WVRNullCollectionViewCell.h"
#import "WVRLiveCell.h"
#import "WVRLiveEndCell.h"

#import "WVRSQFindSplitFooter.h"
#import "WVRSQFindUIStyleHeader.h"
#import "SQRefreshHeader.h"
#import "SQCollectionView.h"
#import "WVRGotoNextTool.h"
#import "WVRLiveModel.h"
#import "WVRLiveGotoTool.h"

#import "WVRLiveRecommendBannerCell.h"
#import "WVRLiveRecTitleHeader.h"
#import "WVRLiveRecReviewCell.h"
#import "WVRLiveRecReBannerCell.h"
#import "WVRSQFindSplitCell.h"

#import "WVRSmallPlayerPresenter.h"

#import "WVRLiveRecommendViewModel.h"

#define MIN_SPACE_ITEM (1.0f)

@interface WVRLiveRecommendPresenter ()

@property (nonatomic) NSDictionary * mModelDic;
@property (nonatomic) WVRLiveModel * mLiveModel;

@property (nonatomic, strong) WVRLiveRecommendViewModel * gLiveRecommendViewModel;

@end
@implementation WVRLiveRecommendPresenter
+ (instancetype)createPresenter:(id)createArgs {
    
    WVRLiveRecommendPresenter * presenter = [[WVRLiveRecommendPresenter alloc] init];
    presenter.createArgs = createArgs;
    presenter.mLiveModel = [WVRLiveModel new];
//    [presenter registerNot];
    [presenter loadViews];
    [presenter installRAC];
    return presenter;
}

-(WVRLiveRecommendViewModel *)gLiveRecommendViewModel
{
    if (!_gLiveRecommendViewModel) {
        _gLiveRecommendViewModel = [[WVRLiveRecommendViewModel alloc] init];
    }
    return _gLiveRecommendViewModel;
}

-(void)installRAC
{
    @weakify(self);
    [[self.gLiveRecommendViewModel mCompleteSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self httpSuccessBlock:x];
    }];
    [[self.gLiveRecommendViewModel mFailSignal] subscribeNext:^(WVRErrorViewModel*  _Nullable x) {
        @strongify(self);
        [self httpFailBlock:x.errorMsg];
    }];
}

- (void)loadViews {
    
    self.cellNibNames = @[NSStringFromClass([WVRLiveCell class]),NSStringFromClass([WVRLiveEndCell class]),NSStringFromClass([WVRLiveRecommendBannerCell class]),NSStringFromClass([WVRLiveRecReBannerCell class]),NSStringFromClass([WVRLiveRecReviewCell class]),NSStringFromClass([WVRSQFindSplitCell class])];
    self.headerNibNames = @[NSStringFromClass([WVRLiveRecTitleHeader class])];
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
    
    self.collectionDelegate.scrollDidScrolling = ^(CGFloat y){
//        NSLog(@"y:%f",y);
        [weakself checkBannerVisibleBlock:y];
    };
    SQRefreshHeader * refreshHeader = [SQRefreshHeader headerWithRefreshingBlock:^{
        [weakself requestInfo];
    }];
    refreshHeader.stateLabel.hidden = YES;
    self.mCollectionV.mj_header = refreshHeader;
}

- (void)checkBannerVisibleBlock:(CGFloat) y {
    
    if (y<fitToWidth(190.f)) {
        if ([[WVRSmallPlayerPresenter shareInstance] prepared]) {
            if ([WVRSmallPlayerPresenter shareInstance].isPaused) {
                [[WVRSmallPlayerPresenter shareInstance] start];
            }
        }
        [[WVRSmallPlayerPresenter shareInstance] setShouldPause:NO];
    }else if(y>fitToWidth(190.f)){
        [[WVRSmallPlayerPresenter shareInstance] setShouldPause:YES];
        if (![WVRSmallPlayerPresenter shareInstance].isPaused) {
            [[WVRSmallPlayerPresenter shareInstance] stop];
        }
    }
//    NSArray * visibleCells = [self.mCollectionV visibleCells];
//    BOOL bannerCellIsVisible = NO;
//    for (NSObject * obj in visibleCells) {
//        if ([obj isKindOfClass:[WVRLiveRecommendBannerCell class]]) {
//            bannerCellIsVisible = YES;
//        }
//    }
}

- (void)requestInfo {
    [super requestInfo];
    [[WVRSmallPlayerPresenter shareInstance] destroy];
    if (self.mModelDic.count==0) {
        SQShowProgressIn(self.mCollectionV);
    }
    self.gLiveRecommendViewModel.code = self.createArgs;
    [[self.gLiveRecommendViewModel getLiveRecommendCmd] execute:nil];
//    kWeakSelf(self);
//    [self.mLiveModel http_recommendPageWithCode:self.createArgs successBlock:^(NSDictionary *modelDic,NSString* name, NSString* pageName) {
//        [weakself httpSuccessBlock:modelDic];
//    } failBlock:^(NSString *errStr) {
//        [weakself httpFailBlock:errStr];
//    }];
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
    
    kWeakSelf(self);
    for (int i = 0; i < self.mModelDic.count; i++) {
        WVRSectionModel* sectionModel = self.mModelDic[@(i)];
        NSNumber* key = @(i);
        self.collectionVOriginDic[key] = [SQCollectionViewSectionInfo new];
        if (sectionModel.sectionType == WVRSectionModelTypeBanner) {
            self.collectionVOriginDic[key] = [self getBannerSectionInfo:sectionModel];
        }else if (sectionModel.sectionType== WVRSectionModelTypeHot){
            self.collectionVOriginDic[key] = [self getSectionInfo:sectionModel headerBlock:^(id args) {
                [weakself gotoMoreBlock:i];
            } cellBlock:^(WVRLiveCellInfo* args) {
                [weakself gotoMoreVC:args.itemModel];
            }];
        }
        else if (sectionModel.sectionType == WVRSectionModelTypeDefault){
            self.collectionVOriginDic[key] = [self getReviewLiveSectionInfo:sectionModel];
        }
    }
    [self updateCollectionView];
}

- (void)gotoMoreBlock:(NSInteger)index {
    
    WVRSectionModel* cur = self.mModelDic[@(index)];
    switch (index) {
        case 1:
            cur.liveStatus = WVRLiveStatusPlaying;
            break;
        case 2:
            cur.liveStatus = WVRLiveStatusNotStart;
            break;
        case 3:
            cur.liveStatus = WVRLiveStatusEnd;
            break;
        default:
            break;
    }
    [WVRLiveGotoTool gotoMoreVC:cur nav:self.controller.navigationController];
}

- (void)httpFailBlock:(NSString*)errMsg {
    
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

- (SQCollectionViewSectionInfo*)getBannerSectionInfo:(WVRSectionModel *)sectionModel {
    
    SQCollectionViewSectionInfo * sectionInfo = [SQCollectionViewSectionInfo new];
    WVRLiveRecommendBannerCellInfo * cellInfo = [WVRLiveRecommendBannerCellInfo new];
    
    cellInfo.cellNibName = NSStringFromClass([WVRLiveRecommendBannerCell class]);
    cellInfo.cellSize = CGSizeMake(SCREEN_WIDTH, fitToWidth(250.f));
    cellInfo.itemModels = sectionModel.itemModels; 
    cellInfo.controller = self.controller;
    NSMutableArray * array = [NSMutableArray new];
    
    [array addObject:cellInfo];
    
    sectionInfo.cellDataArray = array;
    
    sectionInfo.footerInfo = [self getSplitFooterInfo];
    return sectionInfo;
}

- (SQCollectionViewSectionInfo*)getSectionInfo:(WVRSectionModel *)sectionModel headerBlock:(void(^)(id))headerBlock cellBlock:(void(^)(id))cellBlock {
    
    if (sectionModel.itemModels.count==0) {
        return [SQCollectionViewSectionInfo new];
    }
    SQCollectionViewSectionInfo * sectionInfo = [SQCollectionViewSectionInfo new];
    WVRLiveRecTitleHeaderInfo * headerInfo = [WVRLiveRecTitleHeaderInfo new];
    headerInfo.cellNibName = NSStringFromClass([WVRLiveRecTitleHeader class]);
    headerInfo.cellSize = CGSizeMake(SCREEN_WIDTH, fitToWidth(60.f));
    headerInfo.title = sectionModel.name;//@"火热直播";
    sectionInfo.headerInfo = headerInfo;
    sectionInfo.minItemSpace = MIN_SPACE_ITEM;
    NSMutableArray * cellInfos = [NSMutableArray array];
    
    for (WVRSQLiveItemModel* itemModel in sectionModel.itemModels) {
        if ([itemModel.type isEqualToString:@"1"]) {
            continue;
        }
        [cellInfos addObject:[self getCellInfo:itemModel sectionModel:sectionModel cellBlock:cellBlock]];
    }
    sectionInfo.cellDataArray = cellInfos;
    return sectionInfo;
}

- (WVRLiveCellInfo*)getCellInfo:(WVRSQLiveItemModel*)itemModel sectionModel:(WVRSectionModel*)sectionModel cellBlock:(void(^)(id))cellBlock {
    
    WVRLiveCellInfo * cellInfo = [WVRLiveCellInfo new];
    cellInfo.cellNibName = NSStringFromClass([WVRLiveCell class]);
//    if (sectionModel.liveStatus == WVRLiveStatusNotStart) {
        cellInfo.cellSize = CGSizeMake(SCREEN_WIDTH, fitToWidth(266.f));
//    }else{
//        cellInfo.cellSize = [self makeCellSize:sectionModel.itemModels.count curIndex:[sectionModel.itemModels indexOfObject:itemModel] cellInfo:cellInfo];
//    }
    cellInfo.itemModel = itemModel;
    cellInfo.gotoNextBlock = cellBlock;
    
    return cellInfo;
}

- (CGSize)makeCellSize:(NSInteger)itemCount curIndex:(NSInteger)curIndex cellInfo:(WVRLiveCellInfo *)cellInfo {
    
    CGSize size ;
    if (itemCount%2 !=0) {
        if (curIndex==0) {
            size = CGSizeMake(SCREEN_WIDTH, fitToWidth(HEIGHT_LIVE_BIG_CELL));
        }else{
            size = CGSizeMake((SCREEN_WIDTH-MIN_SPACE_ITEM)/2.0f, fitToWidth(HEIGHT_DEFAULT_CELL));
            cellInfo.cellNibName = NSStringFromClass([WVRLiveEndCell class]);
        }
    }else{
        size = CGSizeMake((SCREEN_WIDTH-MIN_SPACE_ITEM)/2.0f, fitToWidth(HEIGHT_DEFAULT_CELL));
        cellInfo.cellNibName = NSStringFromClass([WVRLiveEndCell class]);
    }
    return size;
}

- (SQCollectionViewSectionInfo*)getReviewLiveSectionInfo:(WVRSectionModel*)sectionModel {
    
    if (sectionModel.itemModels.count==0) {
        return [SQCollectionViewSectionInfo new];
    }
    SQCollectionViewSectionInfo * sectionInfo = [SQCollectionViewSectionInfo new];
    WVRLiveRecTitleHeaderInfo * headerInfo = [WVRLiveRecTitleHeaderInfo new];
    headerInfo.cellNibName = NSStringFromClass([WVRLiveRecTitleHeader class]);
    headerInfo.cellSize = CGSizeMake(SCREEN_WIDTH, fitToWidth(60.f));
    headerInfo.title = sectionModel.name;//@"直播回顾";
    sectionInfo.headerInfo = headerInfo;
    kWeakSelf(self);
    NSMutableArray * cellInfos = [NSMutableArray array];
    for (WVRItemModel* model in sectionModel.itemModels) {
        if ([model.type isEqualToString:@"1"]) {
            continue;
        }
        WVRLiveReviewCellInfo * cellInfo = [WVRLiveReviewCellInfo new];
        cellInfo.cellNibName = NSStringFromClass([WVRLiveRecReviewCell class]);
        cellInfo.cellSize = CGSizeMake(SCREEN_WIDTH, fitToWidth(214.0f));
        WVRSectionModel * cursecM = [WVRSectionModel new];
        cursecM.name = model.name;
        cursecM.subTitle = model.subTitle;
        cursecM.thubImageUrl = model.thubImageUrl;
        cursecM.linkArrangeType = model.linkArrangeType;
        cursecM.linkArrangeValue = model.linkArrangeValue;
        cursecM.itemCount = model.unitConut;
        cursecM.arrangeShowFlag = model.arrangeShowFlag;
        cursecM.duration = model.duration;
        cursecM.playCount = model.playCount;
        cellInfo.itemModel = cursecM;
        cellInfo.gotoNextBlock = ^(id args){
            [weakself gotoMoreVC:cursecM];
        };
        [cellInfos addObject:cellInfo];
        if ([model.arrangeShowFlag boolValue]) {
            WVRLiveRecReBannerCellInfo * bCellInfo = [WVRLiveRecReBannerCellInfo new];
            
            bCellInfo.cellNibName = NSStringFromClass([WVRLiveRecReBannerCell class]);
            bCellInfo.cellSize = CGSizeMake(SCREEN_WIDTH, fitToWidth(180.f));
            bCellInfo.itemModel = model;
            bCellInfo.controller = self.controller;
            [cellInfos addObject:bCellInfo];
        }
        if (model != sectionModel.itemModels.lastObject) {
            [cellInfos addObject:[self getSplitCellInfo]];
        }
    }
    
    sectionInfo.cellDataArray = cellInfos;
    return sectionInfo;
}

- (void)gotoMoreVC:(WVRBaseModel *)model {
    
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

- (SQCollectionViewFooterInfo *)getSplitFooterInfo {
    
    SQCollectionViewFooterInfo * footerInfo = [[SQCollectionViewFooterInfo alloc] init];
    footerInfo.cellNibName = NSStringFromClass([WVRSQFindSplitFooter class]);
    footerInfo.cellSize = CGSizeMake(SCREEN_WIDTH, fitToWidth(HEIGHT_SPLIT_CELL));
    return footerInfo;
}

- (WVRSQFindSplitCellInfo*)getSplitCellInfo {
    
    WVRSQFindSplitCellInfo * splitCellInfo = [WVRSQFindSplitCellInfo new];
    splitCellInfo.cellNibName = NSStringFromClass([WVRSQFindSplitCell class]);
    splitCellInfo.cellSize = CGSizeMake(SCREEN_WIDTH, fitToWidth(HEIGHT_SPLIT_CELL));
    return splitCellInfo;
}

- (void)dealloc {
    
    DebugLog(@"dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
