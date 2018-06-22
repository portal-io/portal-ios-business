//
//  WVRMyTicketVC.m
//  WhaleyVR
//
//  Created by Bruce on 2017/6/7.
//  Copyright © 2017年 Snailvr. All rights reserved.

// 我的券/兑换码

#import "WVRMyTicketVC.h"
#import "WVRMyTicketCell.h"
#import "WVRMyRedeemCell.h"

#import "WVRTicketDetailListVC.h"
#import "WVRRedeemExchangeView.h"
#import "WVRExchangeSuccessView.h"

//#import "WVRLiveReserveModel.h"
#import "WVRExchangeTicketModel.h"
#import "WVRRedeemCodeExchangeModel.h"

//#import "WVRVideoDetailVC.h"
//#import "WVRPlayerVCLive.h"
//
//#import "WVRLiveDetailVC.h"
//#import "WVRProgramPackageController.h"

#import "WVRMyTicketViewModel.h"

#import <SQRefreshHeader.h>
#import <SQRefreshFooter.h>
#import <UIViewController+HUD.h>

#import "WVRWidgetToastHeader.h"
#import "WVRNetErrorView.h"

@interface WVRMyTicketVC ()<UITableViewDelegate, UITableViewDataSource, WVRUnExchangeCodeHeaderDelegate, WVRMyRedeemCellDelegate, WVRMyTicketCellDelegate, WVRRedeemExchangeViewDelegate> {
    
    float _section0FooterHeight;
    float _codeRowHeight;
    float _ticketRowHeight;
    BOOL _statusBarHidden;
}

@property (nonatomic, weak) UITableView *mainView;
@property (nonatomic, strong) WVRMyTicketListModel *ticketListModel;
@property (nonatomic, strong) WVRUnExchangeCodeModel *unRedeemListModel;

@property (nonatomic, assign) int curPage;
@property (nonatomic, assign) BOOL isRequesting;

@property (nonatomic, strong) WVRMyTicketHeader *ticketHeader;
@property (nonatomic, strong) WVRUnExchangeCodeHeader *codeHeader;

@property (nonatomic, strong) WVRMyTicketViewModel * gMyTicketViewModel;


@end


@implementation WVRMyTicketVC

static NSString *const _myTicketCellId = @"_myTicketCellId";
static NSString *const _unExchangeCellId = @"_unExchangeCellId";
static NSString *const _placeholderCellId = @"_placeholderCellId";

static NSString *const _myTicketFooterId = @"_myTicketFooterId";

#pragma mark - life cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"我的券/兑换码";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self buildData];
    [self installRAC];
    [self requestDataWithPage:_curPage];
    
    [self invalidNavPanGuesture:self.isFromUnity];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self invalidNavPanGuesture:NO];
}

-(WVRMyTicketViewModel *)gMyTicketViewModel
{
    if (!_gMyTicketViewModel) {
        _gMyTicketViewModel = [[WVRMyTicketViewModel alloc] init];
    }
    return _gMyTicketViewModel;
}

-(void)installRAC
{
    @weakify(self);
    [self.gMyTicketViewModel.gSuccessSignal subscribeNext:^(id  _Nullable x) {
        
        @strongify(self);
        [self updateDataSuccess:x];
    }];
    [self.gMyTicketViewModel.gFailSignal subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self networkFaild];
    }];
}

- (void)updateDataSuccess:(WVRMyTicketListModel *)model
{
    [self setTicketListModel:model];
    
    if (self.mainView) {
        [self.mainView reloadData];
        
        if (_curPage == 0) {
            [self.mainView.mj_header endRefreshing];
        } else {
            if (model.totalPages - 1 <= _curPage) {
                [self.mainView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [self.mainView.mj_footer endRefreshing];
            }
        }
    } else {
        [self drawUI];
    }
}
// 横屏状态下要失效掉右划返回功能
- (void)invalidNavPanGuesture:(BOOL)isInvalid {
    
    if ([self.navigationController respondsToSelector:@selector(setGestureInValid:)]) {
        [self.navigationController performSelector:@selector(setGestureInValid:) withObject:@(isInvalid)];
    }
}

- (void)buildData {
    
    _curPage = 0;
    _codeRowHeight = adaptToWidth(50);
}

- (void)drawUI {
    
    [self hideProgress];
    
    if (self.unRedeemListModel.redeemCodeList.count == 0) {
        _section0FooterHeight = adaptToWidth(31);
    } else {
        _section0FooterHeight = adaptToWidth(39);
    }
    
    [self createMainView];
    [self rightBatButtonItem];
}

- (void)rightBatButtonItem {
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"明细" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClick:)];
    
    self.navigationItem.rightBarButtonItem = item;
}

- (void)createMainView {
    
    if (self.mainView) { return; }
    
    self.view.backgroundColor = Color_RGB(245, 245, 245);
    
    UITableView *mainView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, self.view.width, self.view.height - kNavBarHeight) style:UITableViewStyleGrouped];
    
    mainView.delegate = self;
    mainView.dataSource = self;
    
    mainView.showsHorizontalScrollIndicator = NO;
    mainView.tableFooterView = [[UIView alloc] init];
    mainView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [mainView registerClass:[WVRMyTicketCell class] forCellReuseIdentifier:_myTicketCellId];
    [mainView registerClass:[WVRMyRedeemCell class] forCellReuseIdentifier:_unExchangeCellId];
    [mainView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:_myTicketFooterId];
    
    [mainView registerClass:[UITableViewCell class] forCellReuseIdentifier:_placeholderCellId];
    
    mainView.mj_header = [SQRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(pulldownRefreshData)];
    
    if (self.ticketListModel.content.count >= kHTTPPageSize) {
        mainView.mj_footer = [SQRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(pullupLoadMoreData)];
    }
    
    [self.view addSubview:mainView];
    _mainView = mainView;
}

#pragma mark - setter

/// 列表数据拼接处理
- (void)setTicketListModel:(WVRMyTicketListModel *)ticketListModel {
    
    if (_curPage == 0) {
        _ticketListModel = ticketListModel;
    } else {
        NSMutableArray *list = [_ticketListModel.content mutableCopy];
        
        for (WVRMyTicketListModel *model in ticketListModel.content) {
            
            [list addObject:model];
        }
        _ticketListModel.content = list;
    }
}

#pragma mark - geter

- (WVRUnExchangeCodeHeader *)codeHeader {
    
    if (!_codeHeader) {
        _codeHeader = [[WVRUnExchangeCodeHeader alloc] init];
        _codeHeader.realDelegate = self;
    }
    return _codeHeader;
}

- (WVRMyTicketHeader *)ticketHeader {
    
    if (!_ticketHeader) {
        _ticketHeader = [[WVRMyTicketHeader alloc] init];
    }
    _ticketHeader.hidden = (_ticketListModel.content.count == 0);
    
    return _ticketHeader;
}

#pragma mark - WVRRedeemExchangeViewDelegate

- (void)viewControllerNeedUpdateStatusBar:(BOOL)hidden {
    
    _statusBarHidden = hidden;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)showSuccessResultWithModel:(WVRMyTicketItemModel *)model {
    
//    if ([model.relatedType isEqualToString:PROGRAMTYPE_LIVE] && model.liveStatus == WVRLiveStatusNotStart) {
//        
//        [WVRLiveReserveModel http_liveOrder:YES itemId:model.relatedCode successBlock:^{} failBlock:^(NSString *err) {}];
//    }
    
    [self pulldownRefreshData];
    
    WVRExchangeSuccessView *view = [[WVRExchangeSuccessView alloc] initWithDataModel:model];
    kWeakSelf(self);
    view.lookupDetailBlock = ^{
        [weakself ticketCellLookupClick:model];
    };
    
    [view showWithAnimate];
}

#pragma mark - WVRMyRedeemCellDelegate

- (void)redeemCellExchangeClick:(WVRRedeemCodeListItemModel *)dataModel {
    
    [self requestForRedeemExchangeWithCode:dataModel.redeemCode];
}

#pragma mark - WVRMyTicketCellDelegate
// 查看
- (void)ticketCellLookupClick:(WVRMyTicketItemModel *)dataModel {
    
    if (dataModel.couponStatus == 0) {
        // 节目已失效
        SQToastInKeyWindow(kToastProgramInvalid);
        return;
    }
    
    UIViewController *vc = nil;
    NSString *linkArrangeValue = dataModel.relatedCode;
    
//    switch ([dataModel purchaseType]) {
//        case PurchaseProgramTypeVR: {
//            
//            vc = [[WVRVideoDetailVC alloc] initWithSid:linkArrangeValue];
//        }
//            break;
//        case PurchaseProgramTypeLive: {
//            
//            if (dataModel.liveStatus == WVRLiveStatusNotStart) {
//                
//                vc = [[WVRLiveDetailVC alloc] initWithSid:linkArrangeValue];
//                
//            } else if (dataModel.liveStatus == WVRLiveStatusPlaying) {
//                
//                vc = [[WVRPlayerVCLive alloc] init];
//                
//                WVRVideoEntityLive *ve = [[WVRVideoEntityLive alloc] init];
//                ve.sid = linkArrangeValue;
//                ve.videoTitle = dataModel.displayName;
//                ve.displayMode = dataModel.liveDisplayMode;
//                
//                ((WVRPlayerVCLive *)vc).videoEntity = ve;
//            } else {
//                
//                SQToastInKeyWindow(kToastLiveOver);
//                return;
//            }
//        }
//            break;
//        case PurchaseProgramTypeCollection: {
//            
//            vc = [[WVRProgramPackageController alloc] init];
//            ((WVRProgramPackageController *)vc).createArgs = [WVRSectionModel new];
//            [((WVRProgramPackageController *)vc).createArgs setLinkArrangeType:LINKARRANGETYPE_CONTENT_PACKAGE];
//            [((WVRProgramPackageController *)vc).createArgs setLinkArrangeValue:linkArrangeValue];
//        }
//            break;
//            
//        default:
//            break;
//    }
    
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - WVRUnExchangeCodeHeaderDelegate

- (void)headerExchangeButtonClick {
    
    CGPoint point = [self.codeHeader convertPoint:self.codeHeader.remindLabel.frame.origin toView:self.view];
    WVRRedeemExchangeView *view = [[WVRRedeemExchangeView alloc] initWithTextFieldOrigin:point size:self.codeHeader.remindLabel.bounds.size];
    view.realDelegate = self;
    
    [view showWithAnimate];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1 && indexPath.row > 0) {
        
        WVRMyTicketItemModel *model = [self.ticketListModel.content objectAtIndex:indexPath.row - 1];
        [self ticketCellLookupClick:model];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) { return 0.000001f; }
    
    if (indexPath.section == 0) {
        return _codeRowHeight;
    } else if (indexPath.section == 1) {
        
        WVRMyTicketItemModel *model = self.ticketListModel.content[indexPath.row - 1];
        return model.cellHeight;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return self.codeHeader.height;
    } else if (section == 1) {
        return self.ticketHeader.height;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == 0) {
        return _section0FooterHeight;
    }
    return 15;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return _unRedeemListModel.redeemCodeList.count + 1;
    } else if (section == 1) {
        
        return _ticketListModel.content.count + 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {       // 第一行是占位的，防止没有cell，header也显示不出来
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_placeholderCellId];
        
        return cell;
    }
    
    if (indexPath.section == 0) {
        
        WVRMyRedeemCell *cell = [tableView dequeueReusableCellWithIdentifier:_unExchangeCellId];
        cell.realDelegate = self;
        
        if (indexPath.row <= self.unRedeemListModel.redeemCodeList.count) {
            cell.dataModel = self.unRedeemListModel.redeemCodeList[indexPath.row - 1];
        }
        return cell;
        
    } else if (indexPath.section == 1) {
        
        WVRMyTicketCell *cell = [tableView dequeueReusableCellWithIdentifier:_myTicketCellId];
//        cell.realDelegate = self;
        
        if (indexPath.row <= self.ticketListModel.content.count) {
            WVRMyTicketItemModel *model = self.ticketListModel.content[indexPath.row - 1];
            model.cellWidth = tableView.width;
            cell.dataModel = model;
        }
        
        return cell;
    }
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return self.codeHeader;
    } else if (section == 1) {
        return self.ticketHeader;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:_myTicketFooterId];
    
    return view;
}

#pragma mark - request

- (void)requestDataWithPage:(int)page {
    
    if (!_mainView) { [self showProgress]; }
    
    if (page == 0) {
        
        [self requestRedeemCodeData];
    } else {
        
//        [self requestTicketData:page];
        [self myTicketexe];
    }
}

- (void)myTicketexe
{
    self.gMyTicketViewModel.page = [NSString stringWithFormat:@"%d",_curPage];
    self.gMyTicketViewModel.size = @"18";
    [[self.gMyTicketViewModel myTicketCmd] execute:nil];
}

- (void)requestRedeemCodeData {
    
    kWeakSelf(self);
//    int page = _curPage;
    
    [WVRUnExchangeCodeModel requestUnExchangeRedeemCode:^(WVRUnExchangeCodeModel *model, NSError *error) {
        
        if (model) {
            
            [weakself setUnRedeemListModel:model];
            [self myTicketexe];
//            [weakself requestTicketData:page];
            
        } else {
            [weakself networkFaild];
        }
    }];
}

//- (void)requestTicketData:(int)page {
//    
//    kWeakSelf(self);
//    [WVRExchangeTicketModel requestMyTicketsWithPage:page block:^(WVRMyTicketListModel *model, NSError *error) {
//        
//        if (model) {
//
//            [weakself setTicketListModel:model];
//            
//            if (weakself.mainView) {
//                [weakself.mainView reloadData];
//                
//                if (page == 0) {
//                    [weakself.mainView.mj_header endRefreshing];
//                } else {
//                    if (model.totalPages - 1 <= page) {
//                        [weakself.mainView.mj_footer endRefreshingWithNoMoreData];
//                    } else {
//                        [weakself.mainView.mj_footer endRefreshing];
//                    }
//                }
//            } else {
//                [self drawUI];
//            }
//            
//        } else {
//            [weakself networkFaild];
//        }
//    }];
//}

- (void)pulldownRefreshData {
    
    _curPage = 0;
    [self requestDataWithPage:_curPage];
}

- (void)pullupLoadMoreData {
    
    _curPage += 1;
    [self requestDataWithPage:_curPage];
}

- (void)re_requestData {
    
    [self.netErrorView removeFromSuperview];
    [self pulldownRefreshData];
}

- (void)networkFaild {
    
    [self hideProgress];
    
    if (_mainView) {          // 已有界面
        [self.mainView.mj_header endRefreshing];
        [self.mainView.mj_footer endRefreshing];
        [self showMessage:kNetError];
        
    } else {                    // 未有界面
        
        if (!self.netErrorView) {
            
            WVRNetErrorView *view = [[WVRNetErrorView alloc] init];
            [view.button addTarget:self action:@selector(re_requestData) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:view];
            
            self.netErrorView = view;
            
        } else {
            
            [self.view addSubview:self.netErrorView];
        }
    }
}

#pragma mark - 兑换 请求

- (void)requestForRedeemExchangeWithCode:(NSString *)code {
    
    [self showProgress];
    self.isRequesting = YES;
    
    kWeakSelf(self);
    [WVRRedeemCodeExchangeModel exchangeWithRedeemCode:code block:^(WVRMyTicketItemModel *model, NSError *error) {
        
        [weakself hideProgress];
        weakself.isRequesting = NO;
        
        if (model) {
            [weakself showSuccessResultWithModel:model];
        } else {
            SQToastInKeyWindow(error.domain);
        }
    }];
}

#pragma mark - action

- (void)rightBarButtonClick:(UIButton *)sender {
    // 查看明细
    WVRTicketDetailListVC *vc = [[WVRTicketDetailListVC alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)leftBarButtonClick {
    
    [self invalidNavPanGuesture:NO];
    
    [self.view endEditing:!self.isFromUnity];
    [self.navigationController popViewControllerAnimated:!self.isFromUnity];
    
    if (self.isFromUnity) {
        
        if (self.backUnityBlock) {
            self.backUnityBlock();
        }
    }
}

#pragma mark - status bar

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    
    return UIStatusBarAnimationFade;
}

- (BOOL)prefersStatusBarHidden {
    
    return _statusBarHidden;
}

@end
