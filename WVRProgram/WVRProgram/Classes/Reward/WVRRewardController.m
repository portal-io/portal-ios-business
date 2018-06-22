//
//  WVRRewardController.m
//  WhaleyVR
//
//  Created by qbshen on 2016/12/10.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRRewardController.h"
#import "WVRRewardHeaderV.h"
#import "WVRRewardSectionHeader.h"
#import "WVRRewardCell.h"
#import "WVREditAddressController.h"
#import "WVRRewardVCModel.h"
#import "WVRVirtualRewardCell.h"
#import "WVRVirtualCardRewardCell.h"
#import "WVRNavigationController.h"
#import "WVRTableView.h"

#import "WVRMediator+UnityActions.h"

@interface WVRRewardController ()<BaseBackForResultDelegate>

@property (nonatomic, strong) NSMutableDictionary * originDic;
@property (nonatomic) WVRRewardHeaderV * mHeadV;
@property (nonatomic) WVRRewardHeaderVInfo* mHeadVInfo;
@property (nonatomic) WVRAddressModel* mAddressModel;

@end


@implementation WVRRewardController

+ (instancetype)createViewController:(id)createArgs {
    
    WVRRewardController * vc = [[WVRRewardController alloc] init];
    
    vc.hidesBottomBarWhenPushed = YES;
    
    vc.view.backgroundColor = k_Color11;
    vc.mAddressModel = [WVRAddressModel new];
    [vc requestInfo];

    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [WVRAppModel changeStatusBarOrientation:UIInterfaceOrientationPortrait];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if (_isFormUnity) {
        WVRNavigationController *nav = (WVRNavigationController *)self.navigationController;
        nav.gestureInValid = YES;
    }
}

- (void)initTitleBar {
    [super initTitleBar];
    
    self.title = @"我的奖品";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
}


- (void)back {
    
    [WVRAppModel sharedInstance].shouldContinuePlay = YES;
//    [WVRAppModel forceToOrientation:[self preferredInterfaceOrientationForPresentation]];
    [self.navigationController popViewControllerAnimated:!self.isFormUnity];
    
    if (self.isFormUnity) {
        [WVRAppModel sharedInstance].shouldContinuePlay = NO;
        [[WVRMediator sharedInstance] WVRMediator_showU3DView:NO];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            WVRUnityActionMessageModel *model = [[WVRUnityActionMessageModel alloc] init];
            model.message = @"Manager2UnityResume";
            
            [[WVRMediator sharedInstance] WVRMediator_sendMsgToUnity:model];
        });
    }
}

- (void)requestInfo {
    [super requestInfo];
    
    kWeakSelf(self);
    if (![WVRUserModel sharedInstance].isLogined) {
        [weakself.getEmptyView showNullViewWithTitle:@"你还没抽中任何奖品\n请再接再厉～" icon:@"icon_no_reward"];
        return;
    }
    SQShowProgress;
    [WVRRewardVCModel http_myRewardWithSuccessBlock:^(WVRRewardVCModel *vcModel) {
        [weakself httpMyRewardSuccessBlock:vcModel];
    } failBlock:^(NSString *errStr) {
        [weakself.getEmptyView showNetErrorVWithreloadBlock:^{
            [weakself requestInfo];
        }];
    }];
    [WVRRewardVCModel http_getAddressWithSuccessBlock:^(WVRAddressModel *model) {
        weakself.mAddressModel = model;
        [weakself updateHeadV];
    } failBlock:^(NSString *errStr) {
        SQToastInKeyWindow(errStr);
    }];
}

- (void)httpMyRewardSuccessBlock:(WVRRewardVCModel *)vcModel {
    [self initHeadV];
    [self initSubTabelV];
    if (vcModel.sectionRewards.count == 0) {
        [self.getEmptyView showNullViewWithTitle:@"你还没抽中任何奖品\n请再接再厉～" icon:@"icon_no_reward"];
        self.gTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    } else {
        [self.getEmptyView setHidden:YES];
        self.gTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        NSArray<WVRRewardSectionModel*>* sectionModels = vcModel.sectionRewards;
        for (WVRRewardSectionModel* sectionModel in sectionModels) {
            NSInteger index = [sectionModels indexOfObject:sectionModel];
            self.originDic[@(index)] = [self getDefaultSctionInfo:sectionModel];
        }
//        [self updategTableView];
    }
}


- (void)initSubTabelV {
    
//        self.gTableView = [[WVRTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        self.gTableView.y = self.mHeadV.bottomY;
        self.gTableView.height -= self.mHeadV.bottomY;
        self.gTableView.backgroundColor = [UIColor clearColor];
//        [self initgTableView];
//    }
    [self.view addSubview:self.gTableView];
}

- (void)initHeadV {
    
    kWeakSelf(self);
    if (!self.mHeadV) {
        WVRRewardHeaderV * headV = (WVRRewardHeaderV*)VIEW_WITH_NIB(NSStringFromClass([WVRRewardHeaderV class]));
        WVRRewardHeaderVInfo* vInfo = [WVRRewardHeaderVInfo new];
        if(self.mAddressModel.province.length==0){
            vInfo.address = @"当前没有地址";
            vInfo.operateTitle = @"添加";
        }else{
            vInfo.address = [NSString stringWithFormat:@"当前地址：%@ %@ %@ %@",self.mAddressModel.province,self.mAddressModel.city,self.mAddressModel.county,self.mAddressModel.address];
            vInfo.operateTitle = @"修改";
        }
        vInfo.changeBlock = ^{
            WVREditAddressController * vc = [[WVREditAddressController alloc] init];
            vc.createArgs = [weakself.mAddressModel copyNewModel];
            vc.backDelegate = weakself;
            [weakself.navigationController pushViewController:vc animated:YES];
        };
        [headV fillData:vInfo];
        headV.frame = CGRectMake(0, kNavBarHeight, SCREEN_WIDTH, fitToWidth(41.0f));
        [self.view addSubview:headV];
        self.mHeadV = headV;
        self.mHeadVInfo = vInfo;
    }
}

- (void)updateHeadV {
    
    if(self.mAddressModel.province.length==0){
        self.mHeadVInfo.address = @"当前没有地址";
        self.mHeadVInfo.operateTitle = @"添加";
    }else{
        self.mHeadVInfo.address = [NSString stringWithFormat:@"当前地址：%@ %@ %@ %@",self.mAddressModel.province,self.mAddressModel.city,self.mAddressModel.county,self.mAddressModel.address];
        self.mHeadVInfo.operateTitle = @"修改";
    }
    [self.mHeadV fillData:self.mHeadVInfo];
}

- (SQTableViewSectionInfo *)getDefaultSctionInfo:(WVRRewardSectionModel *)sectionModel {
    
    SQTableViewSectionInfo* sectionInfo = [SQTableViewSectionInfo new];
    WVRRewardSectionHeaderInfo * headerInfo = [WVRRewardSectionHeaderInfo new];
    headerInfo.cellNibName = NSStringFromClass([WVRRewardSectionHeader class]);
    headerInfo.title = sectionModel.formatDateKey;
    headerInfo.cellHeight = fitToWidth(75.0/2.0f);
    sectionInfo.headViewInfo = headerInfo;
    NSMutableArray * cellInfos = [NSMutableArray array];
    for (WVRRewardModel* cur in sectionModel.rewards) {
        [self addCellInfoTo:cellInfos withRewardModel:cur];
    }
    sectionInfo.cellDataArray = cellInfos;
    return sectionInfo;
}

- (void)addCellInfoTo:(NSMutableArray*)cellInfos withRewardModel:(WVRRewardModel*)cur {
    
    if (cur.rewardType == WVRRewardModelTypeDefault) {
        WVRRewardCellInfo * cellInfo = [WVRRewardCellInfo new];
        cellInfo.cellNibName = NSStringFromClass([WVRRewardCell class]);
        cellInfo.cellHeight = fitToWidth(138.0f);
        cellInfo.rewardModel = cur;
        [cellInfos addObject:cellInfo];
    }else if(cur.rewardType == WVRRewardModelTypeCodeEXCode){
        WVRVirtualRewardCellInfo * cellInfo = [WVRVirtualRewardCellInfo new];
        cellInfo.cellNibName = NSStringFromClass([WVRVirtualRewardCell class]);
        cellInfo.cellHeight = fitToWidth(138.0f);
        cellInfo.rewardModel = cur;
        kWeakSelf(cellInfo);
        kWeakSelf(self);
        cellInfo.copyBlock = ^{
            [weakself copyBlock:weakcellInfo];
        };
        [cellInfos addObject:cellInfo];
    }else if (cur.rewardType == WVRRewardModelTypeVirtualCard){
        WVRVirtualCardRewardCellInfo * cellInfo = [WVRVirtualCardRewardCellInfo new];
        cellInfo.cellNibName = NSStringFromClass([WVRVirtualCardRewardCell class]);
        cellInfo.cellHeight = fitToWidth(138.0f);
        cellInfo.rewardModel = cur;
        [cellInfos addObject:cellInfo];
    }
}

- (void)copyBlock:(WVRVirtualRewardCellInfo *)cellInfo {
    
    UIPasteboard *pastboad = [UIPasteboard generalPasteboard];
    
    pastboad.string = cellInfo.rewardModel.rewardInfo.length>0? cellInfo.rewardModel.rewardInfo:@"";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"复制成功"
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)backForResult:(id)info resultCode:(NSInteger)resultCode {
    
    WVRAddressModel* backModel = info;
    self.mAddressModel = backModel;
    
    [self updateHeadV];
}

#pragma mark - orientation

- (BOOL)shouldAutorotate {
    
    return NO;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif 
{
    return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskLandscapeRight;;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    
    return UIInterfaceOrientationPortrait;
}

@end
