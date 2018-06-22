//
//  WVRReserveController.m
//  WhaleyVR
//
//  Created by qbshen on 2016/12/7.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRLiveReservePresenter.h"
#import "WVRLiveReserveCell.h"
#import "WVRLiveReserveModel.h"
//#import "WVRLoginViewController.h"
#import "WVRNavigationController.h"
#import "WVRLiveGotoTool.h"
//#import "WVRLoginTool.h"
#import "WVRGotoNextTool.h"

#import "SQCollectionView.h"
#import "WVRNullCollectionViewCell.h"
#import "SQRefreshHeader.h"

#define HEIGHT_COLLECTION ((70.0f))

@interface WVRLiveReservePresenter ()

@property (nonatomic) WVRLiveReserveModel * mLiveReserveModel;
@property (nonatomic) NSInteger mCurSectionIndex;
@property (nonatomic) BOOL isClickColletV;
@property (nonatomic) WVRLiveReserveCellInfo * mCurReservecellInfo;
@property (nonatomic) UIButton * mCurReserveBtn;
@property (nonatomic) BOOL isReserving;

@property (nonatomic, copy) void(^successBlock)();
@property (nonatomic, copy) void(^failBlock)(NSString * errStr);

@end


@implementation WVRLiveReservePresenter

+ (instancetype)createPresenter:(id)createArgs {
    
    WVRLiveReservePresenter * presenter = [[WVRLiveReservePresenter alloc] init];
    presenter.cellNibNames = @[NSStringFromClass([WVRLiveReserveCell class])];
    presenter.mLiveReserveModel = [WVRLiveReserveModel new];
    [presenter initCollectionView];
    [presenter addRefreshObserver];
    return presenter;
}

- (void)reloadData {
    
    if (self.collectionVOriginDic.count == 0) {
        [self requestInfo];
    }
}

- (UIView *)getView {
    
    return self.mCollectionV;
}

- (void)initCollectionView {
    
    [super initCollectionView];
    kWeakSelf(self);
    SQRefreshHeader * refreshHeader = [SQRefreshHeader headerWithRefreshingBlock:^{
        [weakself headerRefreshRequest];
    }];
    refreshHeader.stateLabel.hidden = YES;
    self.mCollectionV.mj_header = refreshHeader;
}


- (void)requestInfo {
    
    [super requestInfo];
    [self requestReserveHttp];
}

- (void)requestReserveHttp {
    
    SQShowProgressIn(self.mCollectionV);
    [self headerRefreshRequest];
}

- (void)addRefreshObserver {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerRefreshRequest) name:NAME_NOTF_RESERVE_PRESENTER_REFRESH object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerRefreshRequest) name:NAME_NOTF_MANUAL_ARRANGE_PROGRAMPACKAGE object:nil];
}

- (void)onDestroy {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)headerRefreshRequest {
    
    kWeakSelf(self);
    [self removeNetErrorV];
    [self.mLiveReserveModel http_liveOrder_listSuccessBlock:^(NSArray *array) {
        [weakself httpSuccessBlock:array];
    } failBlock:^(NSString *errStr) {
        [weakself httpFialBlock:errStr];
    }];
}

- (void)httpSuccessBlock:(NSArray *)array {
    
    if (array.count == 0) {
        self.mCollectionV.backgroundColor = [UIColor whiteColor];
        [self showNullView:self.mCollectionV title:@"当前暂无直播预告，横划去看精彩回顾吧" icon:@"icon_live_reserve_empty"];
    } else {
        self.mCollectionV.backgroundColor = UIColorFromRGB(0xeeeeee);
        [self removeNullView];
    }
    self.collectionVOriginDic[@(0)] = [self getSectionInfo:array];
    [self updateCollectionView];
    [self.mCollectionV.mj_header endRefreshing];
}

- (void)httpFialBlock:(NSString*)errMsg {
    
    [self.mCollectionV.mj_header endRefreshing];
    if (self.collectionVOriginDic.count != 0) {
        return;
    }
    kWeakSelf(self);
    [self showNetErrorV:self.mCollectionV reloadBlock:^{
        [weakself requestReserveHttp];
    }];
    
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

- (WVRLiveReserveCellInfo*)getReserveCellInfo:(WVRSQLiveItemModel* )item {
    
    kWeakSelf(self);
    WVRLiveReserveCellInfo * cellInfo = [WVRLiveReserveCellInfo new];
    cellInfo.cellNibName = NSStringFromClass([WVRLiveReserveCell class]);
    cellInfo.cellSize = CGSizeMake(SCREEN_WIDTH, fitToWidth(266.f));
    cellInfo.itemModel = item;
    __weak WVRLiveReserveCellInfo * weakCellInfo = cellInfo;
    cellInfo.reserveBlock = ^(UIButton* button){
        [weakself reserveBlock:button reserveCellInfo:weakCellInfo];
    };
    cellInfo.gotoNextBlock = ^(id args){
        [weakself reserveCellInfoNextBlock:weakCellInfo];
    };
    return cellInfo;
}

- (void)reserveBlock:(UIButton*)button reserveCellInfo:(WVRLiveReserveCellInfo *)cellInfo {
    
    if (self.isReserving) {
        SQToastInKeyWindow(@"直播预约中...");
        return ;
    }
    self.mCurReservecellInfo = cellInfo;
    self.mCurReserveBtn = button;
    [self checkReserveStatus];
}

- (void)reserveCellInfoNextBlock:(WVRLiveReserveCellInfo *)cellInfo {
    
    kWeakSelf(self);
    if (self.isReserving) {
        SQToastInKeyWindow(@"直播预约中...");
        return ;
    }
    __weak WVRLiveReserveCellInfo * weakCellInfo = cellInfo;
    cellInfo.itemModel.reserveBlock = ^(void(^successBlock)(),void(^failBlock)(), UIButton* btn){
        weakself.successBlock = successBlock;
        weakself.failBlock = failBlock;
        weakCellInfo.reserveBlock(btn);
    };
    [WVRGotoNextTool gotoNextVC:cellInfo.itemModel nav:self.controller.navigationController];
}

- (void)goReserveLive {
    
    kWeakSelf(self);
    self.mCurReserveBtn.userInteractionEnabled = NO;
    self.isReserving = YES;
    [WVRLiveReserveModel http_liveOrder:![self.mCurReservecellInfo.itemModel.hasOrder boolValue] itemId:self.mCurReservecellInfo.itemModel.code successBlock:^{
        weakself.mCurReservecellInfo.itemModel.hasOrder = [NSString stringWithFormat:@"%d", ![weakself.mCurReservecellInfo.itemModel.hasOrder boolValue]];
        NSString * curOrderC = weakself.mCurReservecellInfo.itemModel.liveOrderCount;
        if ([weakself.mCurReservecellInfo.itemModel.hasOrder boolValue]) {
            
            weakself.mCurReservecellInfo.itemModel.liveOrderCount = [NSString stringWithFormat:@"%ld", [curOrderC integerValue] + 1];
            
        } else {
        
            weakself.mCurReservecellInfo.itemModel.liveOrderCount = [NSString stringWithFormat:@"%ld", [curOrderC integerValue] - 1];
        }
        [weakself.mCollectionV reloadData];
        weakself.mCurReserveBtn.userInteractionEnabled = YES;
        weakself.isReserving = NO;
        if (weakself.successBlock) {
            weakself.successBlock();
        }
    } failBlock:^(NSString *errStr) {
        SQToastInKeyWindow(errStr);
        [weakself.mCollectionV reloadData];
        weakself.mCurReserveBtn.userInteractionEnabled = YES;
        weakself.isReserving = NO;
        if (weakself.failBlock) {
            weakself.failBlock(errStr);
        }
    }];
}

- (void)checkReserveStatus {
    
    if ([self.mCurReservecellInfo.itemModel.hasOrder boolValue] ) {
        [self shouldCanelReserveLive];
    } else {
        [self shouldReserveLive];
    }
}

- (void)shouldCanelReserveLive {
    
    [self goReserveLive];
}

- (void)shouldReserveLive {
    
//    kWeakSelf(self);
//    BOOL checkResult = [WVRLoginTool checkLoginAndIsCharge:self.mCurReservecellInfo.itemModel changeCompleteBlock:^{
////        [self goReserveLive];
//        if (weakself.mCurReservecellInfo.itemModel.isChargeable) {
////            SQToastInKeyWindow(@"跳到详情");
//            [WVRGotoNextTool gotoNextVC:weakself.mCurReservecellInfo.itemModel nav:[UIViewController getCurrentVC].navigationController];
//        }
//    } loginCanceledBlock:^{
//        [weakself requestReserveHttp];
//    }];
//    if (checkResult) {
//        [self goReserveLive];
//    } else {
//        self.mCurReserveBtn.userInteractionEnabled = YES;
//    }
}

- (SQCollectionViewSectionInfo*)getSectionInfo:(NSArray*)itemModels {
    
    SQCollectionViewSectionInfo * sectionInfo = [SQCollectionViewSectionInfo new];
    NSMutableArray * cellInfos = [NSMutableArray array];
    
    for (WVRSQLiveItemModel * cur in itemModels) {
        [cellInfos addObject:[self getReserveCellInfo:cur]];
    }
    sectionInfo.cellDataArray = cellInfos;
    return sectionInfo;
}

- (void)backForResult:(id)info resultCode:(NSInteger)resultCode {
    
    
}

@end
