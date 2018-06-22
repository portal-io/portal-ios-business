//
//  WVRHistoryController.m
//  WhaleyVR
//
//  Created by qbshen on 2017/3/29.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRHistoryController.h"
#import "WVRGotoNextTool.h"
#import "SQRefreshHeader.h"
#import "SQRefreshFooter.h"
#import "WVRNullCollectionViewCell.h"
#import "WVRDeleteFooterView.h"
#import "WVRHistoryViewModel.h"
#import "WVRHistoryCell.h"
#import "WVRHistoryModel.h"
#import "WVRSectionModel.h"
#import "WVRRewardSectionHeader.h"

#import "WVRHistoryHeaderView.h"
#import "UIAlertController+Extend.h"
//#import "WVRTableView.h"

@interface WVRHistoryController ()

@property (nonatomic, strong) NSMutableDictionary * originDic;
@property (nonatomic) UIBarButtonItem * editItem;
@property (nonatomic) UIBarButtonItem * leftItem;
@property (nonatomic) WVRNullCollectionViewCell * mNullViewCellCach;
@property (nonatomic, strong) WVRDeleteFooterView * mDelFooterV;
@property (nonatomic, strong) WVRHistoryViewModel * mViewModel;

@property (nonatomic, strong) NSMutableArray* mOriginArray;
@property (nonatomic, assign) BOOL selectAll;

@property (nonatomic, assign) BOOL isEditing;

@property (nonatomic, strong) SQRefreshHeader * mJ_header;

@property (nonatomic, strong) SQTableViewDelegate * tableDelegate;

@end

@implementation WVRHistoryController

+ (instancetype)createViewController:(id)createArgs {
    WVRHistoryController * vc = [WVRHistoryController new];
    vc.view.backgroundColor = [UIColor whiteColor];
    vc.originDic = [NSMutableDictionary new];
//    vc.gTableView = (UITableView *)[[UITableView alloc] initWithFrame:vc.view.bounds style:UITableViewStylePlain];
    [vc.view addSubview:vc.gTableView];
    [vc initTableView];
    vc.title = @"浏览历史";
    kWeakSelf(vc);
    
    vc.mJ_header = [SQRefreshHeader headerWithRefreshingBlock:^{
        [weakvc.getEmptyView setHidden:YES];
        [weakvc headerRequestInfo];
    }];
    vc.gTableView.mj_header = vc.mJ_header;
    
    [vc requestInfo];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestInfo) name:NAME_NOTF_HISTORY_REFRESH object:nil];
}

-(void)initTableView
{
//    [super initTableView];
    self.gTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableDelegate.editStyle = UITableViewCellEditingStyleDelete;
    [self.tableDelegate setCanEdit:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initTitleBar
{
    [super initTitleBar];
    self.leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = self.leftItem;
    self.editItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editStatus)];
    self.navigationItem.rightBarButtonItem = self.editItem;
    self.title = @"我的收藏";
}

- (void)back
{
    if (self.isEditing) {
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editStatus
{
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"编辑"]) {
        [self.navigationItem.rightBarButtonItem setTitle:@"取消"];
        [self.gTableView setEditing:NO animated:NO];
        self.gTableView.allowsMultipleSelectionDuringEditing = YES;
        [self.gTableView setEditing:YES animated:YES];
        [self loadDeleteFooterView];
        self.isEditing = YES;
        self.gTableView.mj_header = nil;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                                 style:UIBarButtonItemStylePlain target:nil action:nil];
    }else{
        [self removeDeleteFooterView];
        [self.navigationItem.rightBarButtonItem setTitle:@"编辑"];
        self.gTableView.allowsMultipleSelectionDuringEditing = NO;
        [self.gTableView setEditing:NO animated:YES];
        self.isEditing = NO;
        self.navigationItem.leftBarButtonItem = self.leftItem;
        self.gTableView.mj_header = self.mJ_header;
    }
}

-(void)changeToDefaultStatus
{
    [self removeDeleteFooterView];
    [self.navigationItem.rightBarButtonItem setTitle:@"编辑"];
    self.gTableView.allowsMultipleSelectionDuringEditing = NO;
    [self.gTableView setEditing:NO animated:YES];
    self.isEditing = NO;
    self.navigationItem.leftBarButtonItem = self.leftItem;
    self.gTableView.mj_header = self.mJ_header;
}

-(void)doMultiDelete
{
    if (self.gTableView.allowsMultipleSelectionDuringEditing) {
        // 获得所有被选中的行
        NSMutableArray * codes = [NSMutableArray array];
        NSArray *indexPaths = [self.gTableView indexPathsForSelectedRows];
        
        NSMutableDictionary * sectionModelDic = [NSMutableDictionary dictionary];
        NSMutableDictionary * sectionInfoDic = [NSMutableDictionary dictionary];
        
        for (NSIndexPath* indexPath in indexPaths) {
            WVRSectionModel* sectionModel = self.mOriginArray[indexPath.section];
            //组装row
            SQTableViewSectionInfo * sectionInfo = self.originDic[@(indexPath.section)];
            
            NSMutableArray *deloriginItems = sectionModelDic[@(indexPath.section)];
            if (!deloriginItems) {
                deloriginItems = [NSMutableArray new];
                sectionModelDic[@(indexPath.section)] = deloriginItems;
            }
            NSMutableArray *deletedDeals = sectionInfoDic[@(indexPath.section)];
            if (!deletedDeals) {
                deletedDeals = [NSMutableArray new];
                sectionInfoDic[@(indexPath.section)] = deletedDeals;
            }
            
            WVRHistoryModel * model = [sectionInfo.cellDataArray[indexPath.row] args];
            [codes addObject:model.uid];
            
            [deloriginItems addObject:sectionModel.itemModels[indexPath.row]];
            [deletedDeals addObject:sectionInfo.cellDataArray[indexPath.row]];
//            [sectionModel.itemModels removeObjectsInArray:deloriginItems];
//            [sectionInfo.cellDataArray removeObjectsInArray:deletedDeals];
        }
        
        for (NSNumber * num in [sectionModelDic allKeys]) {
            WVRSectionModel* sectionModel = self.mOriginArray[[num integerValue]];
            //组装row
            SQTableViewSectionInfo * sectionInfo = self.originDic[num];
            [sectionModel.itemModels removeObjectsInArray:sectionModelDic[num]];
            [sectionInfo.cellDataArray removeObjectsInArray:sectionInfoDic[num]];
        }
        // 刷新表格  一定要刷新数据
        [self.gTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
        [self refreshUI];
        [self multiDelete:codes];
    }
}

- (void)requestInfo
{
    [super requestInfo];
    SQShowProgress;
    [self headerRequestInfo];
}

- (void)headerRequestInfo
{
    kWeakSelf(self);
    if (!self.mViewModel) {
        self.mViewModel = [WVRHistoryViewModel new];
    }
    [self.mViewModel http_historyList:^(NSArray<WVRHistoryViewModel *> *originArray) {
        [weakself httpHistorySuccessBlock:originArray];
    } andFailBlock:^(NSString *errMsg) {
       [weakself httpFailBlock:errMsg];
    }];
    
}

- (void)httpHistorySuccessBlock:(NSArray<WVRHistoryViewModel *> *)originArray
{
    SQHideProgress;
    self.mOriginArray = [NSMutableArray arrayWithArray:originArray];
    [self.gTableView.mj_header endRefreshing];
    [self refreshUI];
}

- (void)refreshUI
{
    [self parseForDic];
    if (self.mOriginArray.count==0) {
        [self showArrNullView:@"暂无观看历史" icon:@"local_video_empty"];
        [self.originDic removeAllObjects];
        [self changeToDefaultStatus];
        self.navigationItem.rightBarButtonItem = nil;
        
        self.navigationItem.leftBarButtonItem = self.leftItem;
        self.gTableView.allowsMultipleSelectionDuringEditing = NO;
        [self.gTableView setEditing:NO animated:YES];
        [self removeDeleteFooterView];
    }else{
        [self clearNullView];
        self.navigationItem.rightBarButtonItem = self.editItem;
        
    }
    [self.mDelFooterV resetStatus];
    [self updateSelectedCount];
//    [self updateTableView];
}

- (void)httpFailBlock:(NSString*)errMsg
{
    SQHideProgress;
    kWeakSelf(self);
    [self.gTableView.mj_header endRefreshing];
    [self.getEmptyView showNetErrorVWithreloadBlock:^{
        [weakself requestInfo];
    }];
}

- (void)parseForDic
{
    [self.originDic removeAllObjects];
    NSMutableArray * curArray = [NSMutableArray new];
    for (WVRSectionModel* sectionModel in self.mOriginArray) {
        if (sectionModel.itemModels.count==0) {
            [curArray addObject:sectionModel];
        }
    }
    [self.mOriginArray removeObjectsInArray:curArray];
    for (WVRSectionModel* sectionModel in self.mOriginArray) {
        NSInteger index = [self.mOriginArray indexOfObject:sectionModel];
        self.originDic[@(index)] = [self getSectionInfo:sectionModel];
    }
    
}

-(SQTableViewSectionInfo *)getSectionInfo:(WVRSectionModel*)sectionModel
{
    kWeakSelf(self);
    SQTableViewSectionInfo * sectionInfo = [SQTableViewSectionInfo new];
    WVRHistoryHeaderViewInfo * headerInfo = [WVRHistoryHeaderViewInfo new];
    headerInfo.cellNibName = NSStringFromClass([WVRHistoryHeaderView class]);
    headerInfo.args = sectionModel.formatDateKey;
    headerInfo.cellHeight = fitToWidth(80.0/2.0f);
    sectionInfo.headViewInfo = headerInfo;
    NSMutableArray * cellInfos = [NSMutableArray array];
    for (WVRHistoryModel* model in sectionModel.itemModels) {
        WVRHistoryCellInfo * cellInfo = [WVRHistoryCellInfo new];
        cellInfo.cellNibName = NSStringFromClass([WVRHistoryCell class]);
        if (model == [sectionModel.itemModels firstObject]) {
            cellInfo.cellHeight = fitToWidth(85.0f);
        }else{
            cellInfo.cellHeight = fitToWidth(95.0f);
        }
        
        cellInfo.args = model;
        cellInfo.gotoNextBlock = ^(id args){
            weakself.selectAll = NO;
            if (weakself.gTableView.allowsMultipleSelectionDuringEditing) {
                [weakself updateSelectedCount];
                return ;
            }
            [weakself gotoParameDetailVC:model];
        };
        cellInfo.willDeleteBlock = ^(WVRHistoryCellInfo* args){
            return [weakself deleteItemBlock:cellInfos indexPath:args.indexPath];
        };
        cellInfo.deselectBlock = ^(id args){
            if (weakself.gTableView.allowsMultipleSelectionDuringEditing) {
                [weakself updateSelectedCount];
                return ;
            }
        };
        [cellInfos addObject:cellInfo];
    }
    sectionInfo.cellDataArray = cellInfos;
    return sectionInfo;

}

-(void)updateSelectedCount
{
    NSArray* indexPaths = [self.gTableView indexPathsForSelectedRows];
    NSInteger totalCount = 0;
    for (WVRSectionModel* sectionModel in self.mOriginArray) {
        totalCount += sectionModel.itemModels.count;
    }
    NSString * title = [NSString stringWithFormat:@"删除（%d/%d）",(int)indexPaths.count,(int)totalCount];
    [self.mDelFooterV updateDelTitle:title];
}

- (void)gotoParameDetailVC:(WVRHistoryModel*)model
{
    model.linkArrangeValue = model.programCode;
//    model.linkArrangeType = LINKARRANGETYPE_PROGRAM;
//    model.programType = model.programType;
    if ([model.playTime isEqualToString:model.totalPlayTime]) {
        model.playTime = @"0";
    }
    [WVRGotoNextTool gotoNextVC:model nav:self.navigationController];
}

- (BOOL)deleteItemBlock:(NSMutableArray*)cellInfos indexPath:(NSIndexPath*)indexPath
{
    //    kWeakSelf(self);
    WVRHistoryModel * model = [cellInfos[indexPath.row] args];
    [self.mViewModel http_history_dels:model.uid successBlock:^(NSArray<WVRHistoryModel *> *originArray) {
        
    } andFailBlock:^(NSString *errMsg) {
        
    }];
    WVRSectionModel * sectionModel = self.mOriginArray[indexPath.section];
    [sectionModel.itemModels removeObjectAtIndex:indexPath.row];
    [cellInfos removeObjectAtIndex:indexPath.row];
    [self refreshUI];
    return NO;
}

- (void)multiDelete:(NSArray*)codes
{
    if (self.selectAll) {
        [self.mViewModel http_history_delAll:^(NSArray<WVRHistoryModel *> *originArray) {
            
        } andFailBlock:^(NSString *errMsg) {
            
        }];
    }else{
        NSString * curCode = @"";
        for (NSString * code in codes) {
            curCode = [curCode stringByAppendingString:code];
            curCode = [curCode stringByAppendingString:@","];
        }
        curCode = [curCode substringToIndex:curCode.length-1];
        [self.mViewModel http_history_dels:curCode successBlock:^(NSArray<WVRHistoryModel *> *originArray) {
            
        } andFailBlock:^(NSString *errMsg) {
            
        }];
    }
}


- (void)showArrNullView:(NSString*)title icon:(NSString*)icon
{
    if (!self.mNullViewCellCach) {
        self.mNullViewCellCach = [[WVRNullCollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-104)];
        [self.mNullViewCellCach resetImageToCenter];
        [self.mNullViewCellCach setTint:title];
        [self.mNullViewCellCach setImageIcon:icon];
    }
    [self.view addSubview:self.mNullViewCellCach];
}

- (void)clearNullView
{
    [self.mNullViewCellCach removeFromSuperview];
}

-(void)removeDeleteFooterView
{
    self.gTableView.height = self.view.height;
    [self.mDelFooterV removeFromSuperview];
}

-(void)didSelectAllCell:(BOOL)selected
{
//    self.selectAll = selected;
    for (int section=0 ; section < [self.gTableView numberOfSections]; section++) {
//        if ([self.tableView numberOfSections]>0&&[self.tableView numberOfRowsInSection:0]) {
            if (selected) {
                for (int i = 0; i < [self.gTableView numberOfRowsInSection:section]; i ++) {
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:section];
                    
                    [self.gTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                }
            }else{
                for (int i = 0; i < [self.gTableView numberOfRowsInSection:section]; i ++) {
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:section];
                    
                    [self.gTableView deselectRowAtIndexPath:indexPath animated:YES];
                }
            }
            
//        }
    }
    [self updateSelectedCount];
}

-(void)loadDeleteFooterView
{
    if (!self.mDelFooterV) {
        WVRDeleteFooterView * delFooterV = (WVRDeleteFooterView*)VIEW_WITH_NIB(NSStringFromClass([WVRDeleteFooterView class]));
        kWeakSelf(self);
        delFooterV.delBlock = ^{
            [weakself alertForMutilDel];
        };
        delFooterV.selectAllBlock = ^(BOOL selectAll){
            [weakself didSelectAllCell:selectAll];
        };
        delFooterV.frame = CGRectMake(0, SCREEN_HEIGHT-HEIGHT_DELETE_FOOTVIEW, self.view.width, HEIGHT_DELETE_FOOTVIEW);
        self.mDelFooterV = delFooterV;
    }
    [self.mDelFooterV resetStatus];
    [self updateSelectedCount];
    self.gTableView.height -= self.mDelFooterV.height;
    [self.view addSubview:self.mDelFooterV];
}

-(void)alertForMutilDel
{
    if (self.gTableView.allowsMultipleSelectionDuringEditing) {
        // 获得所有被选中的行
        NSArray *indexPaths = [self.gTableView indexPathsForSelectedRows];
        if (indexPaths.count==0) {
            return;
        }
        kWeakSelf(self);
        [UIAlertController alertTitle:@"确定要删除吗？" mesasge:nil preferredStyle:UIAlertControllerStyleAlert confirmHandler:^(UIAlertAction *action) {
            [weakself doMultiDelete];
        } cancleHandler:^(UIAlertAction *action) {
            
        }  viewController:self];
    }
}

@end
