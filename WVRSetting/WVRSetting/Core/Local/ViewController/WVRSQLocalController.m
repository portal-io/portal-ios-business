//
//  WVRSQLocalCachController.m
//  WhaleyVR
//
//  Created by qbshen on 16/11/5.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRSQLocalController.h"
#import "SQSegmentView.h"
#import "SQPageView.h"
#import "SQTableView.h"

//#import "WVRPlayerVCLocal.h"
#import "WVRNavigationController.h"

//#import "WVRPlayerTool.h"
//#import "WVRVideoEntityLocal.h"
#import "SQCocoaHttpServerTool.h"
#import "WVRSQCachVideoInfo.h"
#import "WVRSQLocalVideoInfo.h"

#import "WVRDeleteFooterView.h"


typedef NS_ENUM(NSInteger, WVRSQLocalSegmentType) {
    WVRSQLocalSegmentTypeCach = 0,
    WVRSQLocalSegmentTypeLocal,
};

#define HEIGHT_PAGEVIEW (self.view.frame.size.height-self.mSegmentV.y-self.mSegmentV.height)
#define FRAME_SUB_PAGEVIEW (CGRectMake(0, 0, SCREEN_WIDTH, HEIGHT_PAGEVIEW))

@interface WVRSQLocalController ()

//<UIScrollViewDelegate>
//@property (nonatomic) SQSegmentView *mSegmentV;

//@property (nonatomic)  SQPageView *pageView;


/**
 cach tableView
 */
@property (nonatomic) WVRSQCachVideoInfo * cachVideoInfo;

/**
 local tableView
 */
//@property (nonatomic) SQTableView * localTableView;
//@property (nonatomic) WVRSQLocalVideoInfo * localVideoInfo;

@property (nonatomic) UIBarButtonItem * editItem;
@property (nonatomic) UIBarButtonItem * leftItem;
@property (nonatomic) WVRDeleteFooterView * mDelFooterV;

@property (nonatomic, assign) BOOL isEditing;

@end


@implementation WVRSQLocalController
@synthesize gTableView = _gTableView;

+ (instancetype)shareInstance {
    
    static WVRSQLocalController * vc = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        vc = [WVRSQLocalController new];
//        [vc initSegmentView];
//        [vc initPageView];
        vc.hidesBottomBarWhenPushed = YES;
        [[vc cachVideoInfo] setDelegateForTableView:vc.gTableView];
        [vc.view addSubview:vc.gTableView];
    });
    return vc;
}

- (UITableView *)gTableView
{
    if (!_gTableView) {
        _gTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_gTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    return _gTableView;
}

- (void)addDownTask:(WVRVideoModel *)videoModel {
    
    [self.cachVideoInfo addDownTask:videoModel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)startDownWhenHaveNet {
    
    [self.cachVideoInfo startDownWhenHaveNet];
}
//
//- (void)setBackCompletionHandler:(void (^)())backCompletionHandler
//{
//    [self.cachVideoInfo setBackCompletionHandler:backCompletionHandler];
//}

- (void)updateCachVideoInfo {
    
    [self.cachVideoInfo loadNetDBVideoInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
//    [self.localVideoInfo loadVideosInfo];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}

-(void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    self.gTableView.frame = self.view.bounds;
    self.gTableView.center = self.view.center;
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"取消"]) {
        self.gTableView.height -= (self.mDelFooterV.height);
    }else{
        
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return  UIStatusBarStyleDefault;
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    [self changeToDefaultStatus];
}

//- (void)resetEditStatus
//{
//    [self removeDeleteFooterView];
//    self.gTableView.allowsMultipleSelectionDuringEditing = NO;
//    [self.gTableView setEditing:NO animated:YES];
//    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"取消"]) {
//        [self.navigationItem.rightBarButtonItem setTitle:@"编辑"];
//    }
//    self.navigationItem.leftBarButtonItem = self.leftItem;
//}

- (void)initTitleBar {
    
    [super initTitleBar];
    self.leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = self.leftItem;
    self.editItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editStatus)];
    self.navigationItem.rightBarButtonItem = self.editItem;
    self.title = @"本地缓存";
}

- (void)back {
    
    if (self.isEditing) {
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editStatus {
    
//    if (self.gTableView.numberOfSections==0) {
//        return;
//    }
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"编辑"]) {
        [self.navigationItem.rightBarButtonItem setTitle:@"取消"];
        [self.gTableView setEditing:NO animated:NO];
        self.gTableView.allowsMultipleSelectionDuringEditing = YES;
        [self.gTableView setEditing:YES animated:YES];
        [self loadDeleteFooterView];
        self.isEditing = YES;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                                 style:UIBarButtonItemStylePlain target:nil action:nil];
    }else{
        [self changeToDefaultStatus];
    }
}

-(void)changeToDefaultStatus {
    
    [self removeDeleteFooterView];
    [self.navigationItem.rightBarButtonItem setTitle:@"编辑"];
    self.gTableView.allowsMultipleSelectionDuringEditing = NO;
    [self.gTableView setEditing:NO animated:YES];
    self.isEditing = NO;
    self.navigationItem.leftBarButtonItem = self.leftItem;
}

-(void)removeDeleteFooterView {
    
    self.gTableView.height = self.view.height;
    [self.mDelFooterV removeFromSuperview];
}

-(void)didSelectAllCell:(BOOL)selected {
    
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

-(void)loadDeleteFooterView {
    
    if (!self.mDelFooterV) {
        WVRDeleteFooterView * delFooterV = (WVRDeleteFooterView*)VIEW_WITH_NIB(NSStringFromClass([WVRDeleteFooterView class]));
        kWeakSelf(self);
        delFooterV.delBlock = ^{
            [weakself alertForMutilDel];
        };
        delFooterV.selectAllBlock = ^(BOOL selected){
            [weakself didSelectAllCell:selected];
        };
        delFooterV.frame = CGRectMake(0, SCREEN_HEIGHT-44.f, self.view.width, 44.f);
        self.mDelFooterV = delFooterV;
    }
    [self.mDelFooterV resetStatus];
    [self updateSelectedCount];
    self.gTableView.height -= (self.mDelFooterV.height);
    [self.view addSubview:self.mDelFooterV];
    
}

- (void)changeToEditStatus {
    
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"编辑"]) {
        [self.navigationItem.rightBarButtonItem setTitle:@"取消"];
        self.gTableView.allowsMultipleSelectionDuringEditing = YES;
        [self.gTableView setEditing:YES animated:YES];
    }
}

- (WVRSQCachVideoInfo *)cachVideoInfo {
    
    kWeakSelf(self);
    if (!_cachVideoInfo) {
        _cachVideoInfo = [[WVRSQCachVideoInfo alloc] init];
        _cachVideoInfo.controller = self;
        _cachVideoInfo.gotoPlayBlock = ^(WVRVideoModel* model){
            [weakself gotoCachVideoPlayer:model];
        };
        _cachVideoInfo.completeBlock = ^{
            [weakself hideProgress];
            [weakself updateSelectedCount];
        };
        _cachVideoInfo.delAllBlock = ^(BOOL delAll){
            [weakself changeToDefaultStatus];
            weakself.navigationItem.rightBarButtonItem = delAll? nil:weakself.editItem;
        };
        _cachVideoInfo.editBlock = ^{
            [weakself changeToEditStatus];
        };
        _cachVideoInfo.selectBlock = ^{
            [weakself updateSelectedCount];
        };
        _cachVideoInfo.deselectBlock = ^{
            [weakself updateSelectedCount];
        };
        
    }
    return _cachVideoInfo;
}

- (void)updateCachTV {
    
    [self.gTableView reloadData];
}

- (void)updateTableView {

    [self updateCachTV];
}

- (void)requestInfo {
    
}

- (void)requestCachInfo {
    
    [self updateCachTV];
}

#pragma mark - action

- (void)gotoCachVideoPlayer:(WVRVideoModel*)videoModel {
    
    if (videoModel.downStatus != WVRVideoDownloadStatusDown) {
        SQToast(@"视频未缓存完成");
        return;
    }
//    WVRVideoEntityLocal *ve = [[WVRVideoEntityLocal alloc] init];
//    ve.videoTitle = videoModel.name;
//    ve.sid = videoModel.itemId;
//    
//    ve.renderType = videoModel.renderType;
//    ve.needParserURL = videoModel.localUrl;
    if (![SQCocoaHttpServerTool shareInstance].isrunning) {
        [[SQCocoaHttpServerTool shareInstance] openHttpServer];
    }
    
//    WVRPlayerVCLocal *pVC = [[WVRPlayerVCLocal alloc] init];
//    
//    pVC.videoEntity = ve;
//    
//    WVRNavigationController *nav = [[WVRNavigationController alloc] initWithRootViewController:pVC];
//    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)showPlayerCtrl:(WVRVideoModel *)videoModel {
    
//    WVRPlayerToolModel * tModel = [[WVRPlayerToolModel alloc] init];
//    tModel.title = videoModel.name;
//    tModel.sid = videoModel.itemId;
//    tModel.type = WVRVideoStreamTypeLocal;
//    tModel.detailType = WVRVideoDetailTypeVR;
//    tModel.playURL = videoModel.localUrl;
//    tModel.oritaion = videoModel.oritation;
    
//    tModel.nav = self.navigationController;
//    [WVRPlayerTool showPlayerControllerWith:tModel];
}

- (void)dealloc {
    
    DebugLog(@"");
}

-(void)alertForMutilDel {
    
    if (self.gTableView.allowsMultipleSelectionDuringEditing) {
        // 获得所有被选中的行
        NSArray *indexPaths = [self.gTableView indexPathsForSelectedRows];
        if (indexPaths.count==0) {
            return;
        }
        kWeakSelf(self);
        [UIAlertController alertTitle:@"确定要删除吗？" mesasge:nil preferredStyle:UIAlertControllerStyleAlert confirmHandler:^(UIAlertAction *action) {
            [weakself.cachVideoInfo doMultiDelete];
        } cancleHandler:^(UIAlertAction *action) {
            
        }  viewController:self];
    }
}

-(void)updateSelectedCount {
    
    NSArray* indexPaths = [self.gTableView indexPathsForSelectedRows];
    NSInteger totalCount = self.cachVideoInfo.cachVideoArray.count;
    NSString * title = [NSString stringWithFormat:@"删除（%ld/%ld）",(long)indexPaths.count,(long)totalCount];
    [self.mDelFooterV updateDelTitle:title];
}
@end
