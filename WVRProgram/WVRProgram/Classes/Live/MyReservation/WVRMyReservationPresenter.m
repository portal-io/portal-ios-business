//
//  WVRMyReservationPresenter.m
//  WhaleyVR
//
//  Created by qbshen on 2017/2/10.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRMyReservationPresenter.h"
#import "SQTableView.h"
#import "SQRefreshHeader.h"
#import "SQTableViewDelegate.h"

#import "WVRNullCollectionViewCell.h"
#import "WVRMyReserveCell.h"
#import "WVRGotoNextTool.h"
#import "WVRHttpMyReserve.h"
#import "WVRSQLiveItemModel.h"

//#import "WVRInAppPurchaseManager.h"
#import "WVRSectionModel.h"
#import "WVRMediator+PayActions.h"

@interface WVRMyReservationPresenter ()

@property (nonatomic) UIViewController * controller;
@property (nonatomic) SQTableView* tableView;
@property (nonatomic) SQTableViewDelegate * tableVDelegate;
@property (nonatomic) NSMutableDictionary * originDic;

@property (nonatomic) WVRNullCollectionViewCell * mNullView;
@property (nonatomic) WVRNetErrorView* mErrorView;


@end
@implementation WVRMyReservationPresenter
+ (instancetype)createPresenter:(id)createArgs {
    
    WVRMyReservationPresenter * presenter = [[WVRMyReservationPresenter alloc] init];
    presenter.controller = createArgs;
    
    [presenter loadSubViews];
    return presenter;
}

- (void)loadSubViews {
    kWeakSelf(self);
    SQRefreshHeader * refreshHeader = [SQRefreshHeader headerWithRefreshingBlock:^{
        [weakself requestInfo];
    }];
    refreshHeader.stateLabel.hidden = YES;
    self.tableView.mj_header = refreshHeader;
}

- (void)reloadData {
    
    [self.controller showProgress];
    [self requestInfo];
}

- (SQTableView *)tableView {
    
    if (!_tableView) {
        _tableView = [[SQTableView alloc] initWithFrame:CGRectZero];
        _tableView.delegate = self.tableVDelegate;
        _tableView.dataSource = self.tableVDelegate;
    }
    return _tableView;
}

- (SQTableViewDelegate *)tableVDelegate {
    
    if (!_tableVDelegate) {
        _tableVDelegate = [SQTableViewDelegate new];
    }
    return _tableVDelegate;
}

- (void)requestInfo {
    
    if (!self.originDic) {
        self.originDic = [NSMutableDictionary new];
    }
    [self requestReserveHttp];
}

- (void)requestReserveHttp {
    
    [self headerRefreshRequest];
}

- (void)headerRefreshRequest {
    
    kWeakSelf(self);
    [self removeNetErrorV];
    WVRHttpMyReserve * cmd = [[WVRHttpMyReserve alloc] init];
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[kHttpParams_myReserveList_uid] = [WVRUserModel sharedInstance].accountId;
    params[kHttpParams_myReserveList_token] = [WVRUserModel sharedInstance].sessionId;
    params[kHttpParams_myReserveList_device_id] = [WVRUserModel sharedInstance].deviceId;
    cmd.bodyParams = params;
    cmd.successedBlock = ^(id  data){
        [weakself httpSuccessBlock:data];
    };
    cmd.failedBlock = ^(NSString* errMsg){
        NSLog(@"fail msg: %@",errMsg);
        [weakself httpFialBlock:errMsg];
    };
    [cmd execute];
}

- (void)httpSuccessBlock:(WVRHttpMyReserveModel *)responseModel {
    
    NSMutableArray * array = [NSMutableArray new];
    for (WVRHttpMyReserveItemModel * cur in [responseModel data]) {
        WVRSQLiveItemModel * liveItemModel = [WVRSQLiveItemModel new];
        liveItemModel.name = cur.displayName;
        liveItemModel.thubImageUrl = cur.poster;
        liveItemModel.startDateFormat = cur.beginTime;
        liveItemModel.linkArrangeType = LINKARRANGETYPE_LIVE;
        liveItemModel.liveStatus = cur.liveStatus;
        liveItemModel.code = cur.code;
        liveItemModel.linkArrangeValue = liveItemModel.code;
        liveItemModel.playUrl = [[cur.liveMediaDtos firstObject] playUrl];
        liveItemModel.srcDisplayName = cur.stat.srcDisplayName;
        liveItemModel.displayMode = [cur.displayMode integerValue];
        liveItemModel.programType = cur.programType;
        [array addObject:liveItemModel];
    }
    [self requestForListItemCharged:array];
    
}

- (void)updateUI:(NSArray*)array{
    [self.controller hideProgress];
    SQTableViewSectionInfo * sectionInfo = [self getSectionInfo:array];
    self.originDic[@(0)] = sectionInfo;
    if (sectionInfo.cellDataArray.count==0) {
        [self showNullView:self.tableView title:@"暂无预约节目" icon:@"icon_cach_video_empty"];
    }else{
        [self removeNullView];
    }
    [self updateTableView];
    [self.tableView.mj_header endRefreshing];
}

- (void)requestForListItemCharged:(NSArray *)items {
    
    NSMutableArray *arr = [NSMutableArray array];
    for (WVRItemModel *item in items) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
        dict[@"sid"] = item.code;
        dict[@"type"] = item.programType ? item.programType : @"live";
        
        [arr addObject:dict];
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    @weakify(self);
    RACCommand *cmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSArray *  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            
            @strongify(self);
            [self dealWithCheckGoodPayList:input items:items];
            
            return nil;
        }];
    }];
    
    param[@"cmd"] = cmd;
    param[@"items"] = arr;
    
//    @{ @"cmd":RACCommand, @"item":WVRItemModel, @"items":NSArray<WVRItemModel *> }
    [[WVRMediator sharedInstance] WVRMediator_CheckVideoIsPaied:param];
}

- (void)dealWithCheckGoodPayList:(NSArray *)list items:(NSArray *)items {
    
    int count = 0;
    for (NSDictionary *resDic in list) {

        if (items.count > count) {
            int isCharged = [resDic[@"result"] intValue];
            NSString *goodsNo = resDic[@"goodsNo"];
            WVRItemModel *itemModel = [items objectAtIndex:count];

            if ([goodsNo isEqualToString:itemModel.code]) {

                itemModel.packageItemCharged = @(isCharged);
            }
        }

        count += 1;
    }
    [self updateUI:items];
}


- (void)httpFialBlock:(NSString *)errMsg {
    
    [self.controller hideProgress];
    if (self.originDic.count != 0) {
        return;
    }
    kWeakSelf(self);
    [self showNetErrorV:self.tableView reloadBlock:^{
        [weakself requestReserveHttp];
    }];
    [self.tableView.mj_header endRefreshing];
}

- (void)showNetErrorV:(UIView*)parentV reloadBlock:(void(^)())reloadBlock {
    
    [self.mNullView removeFromSuperview];
    if (!self.mErrorView) {
        self.mErrorView = [WVRNetErrorView errorViewForViewReCallBlock:^{
            reloadBlock();
        } withParentFrame:parentV.frame];
    }
    [parentV addSubview:self.mErrorView];
}

- (void)removeNetErrorV {
    
    [self.mErrorView removeFromSuperview];
    [self.mNullView removeFromSuperview];
}


- (void)showNullView:(UIView*)parentV title:(NSString*)title icon:(NSString*)icon {
    
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
    
    [self.mNullView removeFromSuperview];
    [self.mErrorView removeFromSuperview];
}

- (SQTableViewSectionInfo*)getSectionInfo:(NSArray*)itemModels {
    
    kWeakSelf(self);
    SQTableViewSectionInfo * sectionInfo = [SQTableViewSectionInfo new];
    NSMutableArray * cellInfos = [NSMutableArray array];
    
    for (WVRSQLiveItemModel * cur in itemModels) {
        WVRMyReserveCellInfo * cellInfo = [WVRMyReserveCellInfo new];
        cellInfo.cellNibName = NSStringFromClass([WVRMyReserveCell class]);
        cellInfo.cellHeight = fitToWidth(126.f);
        cellInfo.itemModel = cur;
        cellInfo.gotoNextBlock = ^(WVRMyReserveCellInfo* args){
            [weakself cellInfoNextBlock:args.itemModel];
        };
        [cellInfos addObject:cellInfo];
    }
    sectionInfo.cellDataArray = cellInfos;
    return sectionInfo;
}

- (void)cellInfoNextBlock:(WVRItemModel*)itemModel {
    
    if (itemModel.liveStatus == WVRLiveStatusEnd) {
        SQToastInKeyWindow(@"该直播已结束，去看看精彩回顾吧～");
    } else {
        [WVRGotoNextTool gotoNextVC:itemModel nav:self.controller.navigationController];
    }
}

- (void)updateTableView {
    
    kWeakSelf(self);
    [self.tableVDelegate loadData:^NSDictionary *{
        return weakself.originDic;
    }];
    [self.tableView reloadData];
}


- (UIView *)getView {
    
    return self.tableView;
}
@end
