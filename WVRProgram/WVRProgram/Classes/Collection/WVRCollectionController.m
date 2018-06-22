//
//  WVRCollectionController.m
//  WhaleyVR
//
//  Created by qbshen on 2017/1/6.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRCollectionController.h"
#import "WVRCollectionVCModel.h"
#import "WVRCollectionCell.h"
#import "WVRGotoNextTool.h"
#import "SQRefreshHeader.h"
#import "SQRefreshFooter.h"
#import "WVRNullCollectionViewCell.h"
#import "WVRDeleteFooterView.h"

#import "WVRCollectionPresenter.h"
#import "WVRTableView.h"

@interface WVRCollectionController ()

@property (nonatomic, strong) SQTableViewDelegate * gDelegate;

@property (nonatomic, strong) NSMutableDictionary * originDic;
//@property (nonatomic, strong) WVRCollectionPresenter * gPresenter;

@property (nonatomic) WVRCollectionVCModel * vcModel;
@property (nonatomic) UIBarButtonItem * editItem;
@property (nonatomic) UIBarButtonItem * leftItem;
@property (nonatomic) WVRNullCollectionViewCell * mNullViewCellCach;

@property (nonatomic, strong) WVRDeleteFooterView * mDelFooterV;
@property (nonatomic, assign) BOOL isEditing;

@property (nonatomic, strong) SQRefreshHeader * mJ_header;

@end


@implementation WVRCollectionController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.originDic = [NSMutableDictionary new];
    self.view.backgroundColor = [UIColor whiteColor];
    self.gTableView.delegate = self.gDelegate;
    self.gTableView.dataSource = self.gDelegate;
    [self.gTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.gTableView];
    self.title = @"我的播单";
    kWeakSelf(self);
    self.mJ_header = [SQRefreshHeader headerWithRefreshingBlock:^{
        [weakself requestInfo];
    }];
    self.gTableView.mj_header = self.mJ_header;
    [self requestInfo];
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"取消"]) {
        self.gTableView.height -= (self.mDelFooterV.height);
    }else{
        
    }
}

-(SQTableViewDelegate *)gDelegate
{
    if (!_gDelegate) {
        _gDelegate = [[SQTableViewDelegate alloc] init];
    }
    return _gDelegate;
}

- (void)initTitleBar {
    
    [super initTitleBar];
    self.leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = self.leftItem;
    self.editItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editStatus)];
    self.navigationItem.rightBarButtonItem = self.editItem;
    self.title = @"我的播单";
}

- (void)back {
    
    if (self.isEditing) {
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editStatus {
    
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

- (void)changeToDefaultStatus {
    
    [self removeDeleteFooterView];
    [self.navigationItem.rightBarButtonItem setTitle:@"编辑"];
    self.gTableView.allowsMultipleSelectionDuringEditing = NO;
    [self.gTableView setEditing:NO animated:YES];
    self.isEditing = NO;
    self.navigationItem.leftBarButtonItem = self.leftItem;
    self.gTableView.mj_header = self.mJ_header;
}

- (void)doMultiDelete {
    
    if (self.gTableView.allowsMultipleSelectionDuringEditing) {
        // 获得所有被选中的行
        NSArray *indexPaths = [self.gTableView indexPathsForSelectedRows];
        if (indexPaths.count==0) {
            return;
        }
        SQTableViewSectionInfo * sectionInfo = self.originDic[@(SQTableViewSectionStyleFir)];
        // 便利所有的行号
        NSMutableArray *deletedDeals = [NSMutableArray array];
        NSMutableArray * vcModels = [NSMutableArray array];
        NSMutableArray * codes = [NSMutableArray array];
        for (NSIndexPath *path in indexPaths) {
            WVRCollectionModel * model = self.vcModel.collections[path.row];
            [codes addObject:model.programCode];
            [vcModels addObject:model];
            [deletedDeals addObject:sectionInfo.cellDataArray[path.row]];
        }
        // 删除模型数据
        [self.vcModel.collections removeObjectsInArray:vcModels];
        [sectionInfo.cellDataArray removeObjectsInArray:deletedDeals];
        // 刷新表格  一定要刷新数据
        [self.gTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
        [self refreshUI];
        [self multiDelete:codes];
    }
    
}

- (void)requestInfo {
    
    [super requestInfo];
    if (self.originDic.count==0) {
        SQShowProgress;
    }
    [self headerRequestInfo];
}

- (void)headerRequestInfo {
    
    kWeakSelf(self);
    [WVRCollectionVCModel http_CollectionGetWithSuccessBlock:^(WVRCollectionVCModel *vcModel) {
        [weakself httpCollectionGetSuccessBlock:vcModel];
    } failBlock:^(NSString *errMsg) {
        [weakself httpFailBlock:errMsg];
    }];
    
}

- (void)httpCollectionGetSuccessBlock:(WVRCollectionVCModel*)vcModel {
    
    SQHideProgress;
    [self.gTableView.mj_header endRefreshing];
    self.vcModel = vcModel;
    [self refreshUI];
}


- (void)httpFailBlock:(NSString*)errMsg {
    
    SQHideProgress;
    kWeakSelf(self);
    [self.gTableView.mj_header endRefreshing];
    [self showNetErrorVWithreloadBlock:^{
        [weakself requestInfo];
    }];
    
}

- (void)refreshUI {
    
    if (self.vcModel.collections.count==0) {
        [self showArrNullView:@"暂无收藏视频" icon:@"local_video_empty"];
        [self.originDic removeAllObjects];
        [self changeToDefaultStatus];
        self.navigationItem.rightBarButtonItem = nil;
        self.gTableView.allowsMultipleSelectionDuringEditing = NO;
        [self.gTableView setEditing:NO animated:YES];
        [self removeDeleteFooterView];
    }else{
        [self clearNullView];
        self.navigationItem.rightBarButtonItem = self.editItem;
        self.originDic[@(0)] = [self getSectionInfo];
    }
    [self.mDelFooterV resetStatus];
    [self updateSelectedCount];
    @weakify(self);
    [self.gDelegate loadData:^NSDictionary *{
        @strongify(self);
        return self.originDic;
    }];
    [self.gTableView reloadData];
}



- (SQTableViewSectionInfo*)getSectionInfo {
    
    kWeakSelf(self);
    SQTableViewSectionInfo * sectionInfo = [SQTableViewSectionInfo new];
    NSMutableArray * cellInfos = [NSMutableArray array];
    for (WVRCollectionModel* model in self.vcModel.collections) {
        WVRCollectionCellInfo * cellInfo = [WVRCollectionCellInfo new];
        cellInfo.cellNibName = NSStringFromClass([WVRCollectionCell class]);
        cellInfo.cellHeight = fitToWidth(95.0f);
        cellInfo.collectionModel = model;
        cellInfo.gotoNextBlock = ^(id args){
            if (weakself.gTableView.allowsMultipleSelectionDuringEditing) {
                [weakself updateSelectedCount];
                return ;
            }
            [weakself gotoParameDetailVC:model];
        };
        cellInfo.willDeleteBlock = ^(WVRCollectionCellInfo* args){
            return [weakself deleteItemBlock:cellInfos index:args.indexPath.row];
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

- (void)updateSelectedCount {
    
    NSArray* indexPaths = [self.gTableView indexPathsForSelectedRows];
    NSInteger totalCount = self.vcModel.collections.count;
    NSString * title = [NSString stringWithFormat:@"删除（%ld/%ld）", (unsigned long)indexPaths.count, totalCount];
    [self.mDelFooterV updateDelTitle:title];
}

- (void)gotoParameDetailVC:(WVRCollectionModel*)model {
    
    [WVRTrackEventMapping trackEvent:@"collection" flag:@"topic"];
    
    model.linkArrangeValue = model.programCode;
    [WVRGotoNextTool gotoNextVC:model nav:self.navigationController];
}

- (BOOL)deleteItemBlock:(NSMutableArray*)cellInfos index:(NSInteger)index {
    
//    kWeakSelf(self);
    WVRCollectionModel * model = self.vcModel.collections[index];
    WVRTVItemModel * itemModel = [WVRTVItemModel new];
    itemModel.code = model.programCode;
    [WVRCollectionVCModel http_CollectionDelWithModel:itemModel successBlock:^{
//        [weakself.vcModel.collections removeObjectAtIndex:index];
//        [cellInfos removeObjectAtIndex:index];
//        [weakself.tableView reloadData];
    } failBlock:^(NSString *errMsg) {
//        SQToastInKeyWindow(@"");
    }];
    [self.vcModel.collections removeObjectAtIndex:index];
    [cellInfos removeObjectAtIndex:index];
    [self refreshUI];
    return NO;
}

- (void)multiDelete:(NSArray*)codes {
    
    WVRTVItemModel * itemModel = [WVRTVItemModel new];
    NSString * curCode = @"";
    for (NSString * code in codes) {
        curCode = [curCode stringByAppendingString:code];
        curCode = [curCode stringByAppendingString:@","];
    }
    itemModel.code = curCode;
    [WVRCollectionVCModel http_CollectionDelWithModel:itemModel successBlock:^{
        //        [weakself.vcModel.collections removeObjectAtIndex:index];
        //        [cellInfos removeObjectAtIndex:index];
        //        [weakself.tableView reloadData];
    } failBlock:^(NSString *errMsg) {
        //        SQToastInKeyWindow(@"");
    }];
}


- (void)showArrNullView:(NSString*)title icon:(NSString*)icon {
    
    if (!self.mNullViewCellCach) {
        self.mNullViewCellCach = [[WVRNullCollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-104)];
        [self.mNullViewCellCach resetImageToCenter];
        [self.mNullViewCellCach setTint:title];
        [self.mNullViewCellCach setImageIcon:icon];
    }
    [self.view addSubview:self.mNullViewCellCach];
}

- (void)clearNullView {
    
    [self.mNullViewCellCach removeFromSuperview];
}

- (void)removeDeleteFooterView {
    
    self.gTableView.height = self.view.height;
    [self.mDelFooterV removeFromSuperview];
}

- (void)didSelectAllCell:(BOOL)selected {
    
    if ([self.gTableView numberOfSections]>0&&[self.gTableView numberOfRowsInSection:0]) {
        if (selected) {
            for (int i = 0; i < [self.gTableView numberOfRowsInSection:0]; i ++) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                
                [self.gTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
        }else{
            for (int i = 0; i < [self.gTableView numberOfRowsInSection:0]; i ++) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                
                [self.gTableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }
        
    }
    [self updateSelectedCount];
}

- (void)loadDeleteFooterView {
    
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

- (void)alertForMutilDel {
    
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
