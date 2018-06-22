//
//  WVRMineController.m
//  WhaleyVR
//
//  Created by qbshen on 2017/8/7.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRMineController.h"
#import "WVRMineViewModel.h"
#import <ReactiveObjC/ReactiveObjC.h>

#import "WVRMediator+ProgramActions.h"
#import "WVRMediator+PayActions.h"
#import "WVRMediator+AccountActions.h"
#import "WVRMediator+SettingActions.h"

#import "WVRFeedbackVC.h"
#import "WVRSQHelperController.h"
#import "WVRAboutUsVC.h"
#import "WVRMineAvatarCellViewModel.h"

#define VR_ManagerAppID (@"963637613")

@interface WVRMineController ()

@property (nonatomic, strong) WVRMineViewModel * gMineViewModel;

@property (nonatomic, strong) NSDictionary * gGotoSubcribeBlockDic;

@property (nonatomic, strong) NSDictionary * gAvatarClickBlockDic;

@end

@implementation WVRMineController
@synthesize gTableView = _gTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.gTableView];
    [self bindViewModel:nil];
    [self.gMineViewModel fetchData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self getUserInfo];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.gTableView.y = -kStatuBarHeight;
    self.gTableView.height += kStatuBarHeight;
}

- (void)getUserInfo
{
    if ([WVRUserModel sharedInstance].isLogined) {
        [[WVRMediator sharedInstance] WVRMediator_GetUserInfo];
    }
}

- (void)updateRewardDot:(BOOL)show
{
    
}

#pragma bind viewModel
- (void)bindViewModel:(id)viewModel
{
    @weakify(self);
    [[RACObserve([WVRUserModel sharedInstance], isLogined) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if (self.navigationController.viewControllers.count>1) {
            [self.navigationController popToViewController:self animated:YES];
        }
    }];
    [self.gMineViewModel.gotoSignal subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        void (^block)(void) = self.gGotoSubcribeBlockDic[x];
        if (block) {
            block();   
        }
    }];
    [self.gMineViewModel.avatarClickSignal subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        void (^block)(void) = self.gAvatarClickBlockDic[x];
        if (block) {
            block();
        }
    }];
    [self.gMineViewModel.updateModelSingal subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self showUserViewModel];
    }];
}

#pragma gotoNext block dic
- (NSDictionary*)gGotoSubcribeBlockDic
{
    if (!_gGotoSubcribeBlockDic) {
        @weakify(self);
        _gGotoSubcribeBlockDic = @{@(WVRMineCellTypeAvater):^{
            
        },
          @(WVRMineCellTypeLocal):^{
              @strongify(self);
              [self gotoLocal];
          },
          @(WVRMineCellTypeCollection):^{
              @strongify(self);
              [self gotoCollection];
          },
          @(WVRMineCellTypeReward):^{
              @strongify(self);
              [self gotoReward];
          },
          @(WVRMineCellTypeFeedBack):^{
              @strongify(self);
              [self gotoFeedBack];
          },
          @(WVRMineCellTypeHelper):^{
              @strongify(self);
              [self gotoHelper];
          },
          @(WVRMineCellTypeOfficel):^{
              @strongify(self);
              [self gotoOfficel];
          },
          @(WVRMineCellTypeSocre):^{
              @strongify(self);
              [self gotoSocre];
          },
          @(WVRMineCellTypeAbount):^{
              @strongify(self);
              [self gotoAbount];
          }
          };
        
    }
    return _gGotoSubcribeBlockDic;
}

- (void)gotoLocal {
//    [WVRUserModel sharedInstance].isLogined = YES;
//    return;
    UIViewController * vc = [[WVRMediator sharedInstance] WVRMediator_LocalViewController:YES];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoCollection
{
    @weakify(self);
    RACCommand * cmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self);
        UIViewController * vc = [[WVRMediator sharedInstance] WVRMediator_CollectionViewController];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        return nil;
    }];
    NSDictionary * params = @{@"completeCmd":cmd};
    [[WVRMediator sharedInstance] WVRMediator_CheckAndAlertLogin:params];
//    [WVRLoginTool checkAndAlertLogin:@"需要登录才能查看播单" completeBlock:^(BOOL isLogined) {
//    } loginCanceledBlock:nil];
    
}

- (void)gotoReward
{
    @weakify(self);
    RACCommand * cmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self);
        UIViewController * vc = [[WVRMediator sharedInstance] WVRMediator_RewardViewController];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        [self updateRewardDot:NO];
        return nil;
    }];
    NSDictionary * params = @{@"completeCmd":cmd};
    [[WVRMediator sharedInstance] WVRMediator_CheckAndAlertLogin:params];
}

- (void)gotoFeedBack
{
    UIViewController * vc = [[WVRFeedbackVC alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoOfficel
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithUTF8String:@"http://bbs.whaley.cn/forum-60-1.html"]];
}

- (void)gotoHelper
{
    UIViewController * vc = [[WVRSQHelperController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoSocre
{
    NSString *storeURL = [NSString stringWithFormat:@"https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8",VR_ManagerAppID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:storeURL]];
}

- (void)gotoAbount
{
    UIViewController * vc = [[WVRAboutUsVC alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma avatar click block dic
- (NSDictionary*)gAvatarClickBlockDic
{
    if (!_gAvatarClickBlockDic) {
        @weakify(self);
        _gAvatarClickBlockDic = @{@(WVRMAvatarClickTypeLogin):^{
            @strongify(self);
            [self gotoLogin];
        },
                                   @(WVRMAvatarClickTypeRegister):^{
                                       @strongify(self);
                                       [self gotoRegister];
                                   },
                                   @(WVRMAvatarClickTypeEdit):^{
                                       @strongify(self);
                                       [self gotoEdit];
                                   },
                                   @(WVRMAvatarClickTypeSetting):^{
                                       @strongify(self);
                                       [self gotoSetting];
                                   }
                                   };
        
    }
    return _gAvatarClickBlockDic;

}

- (void)gotoLogin
{
    UIViewController * vc = [[WVRMediator sharedInstance] WVRMediator_LoginViewController];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoRegister
{
    UIViewController * vc = [[WVRMediator sharedInstance] WVRMediator_RegisterViewController];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoSetting
{
    UIViewController * vc = [[WVRMediator sharedInstance] WVRMediator_SettingViewController];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoEdit
{
    if ([WVRUserModel sharedInstance].isLogined) {
        UIViewController * vc = [[WVRMediator sharedInstance] WVRMediator_UserInfoViewController];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [self showMessageToWindow:@"请登录"];
    }
}

#pragma init
- (UITableView *)gTableView
{
    if (!_gTableView) {
        _gTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _gTableView.delegate = self.gMineViewModel.gTableViewAdapter;
        _gTableView.dataSource = self.gMineViewModel.gTableViewAdapter;
        _gTableView.sectionFooterHeight = 0;
        _gTableView.sectionHeaderHeight = 0;
        _gTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.01)];
        _gTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.01)];
        [_gTableView setSeparatorColor:[UIColor grayColor]];
        [_gTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _gTableView.backgroundColor = [UIColor colorWithHex:0xebeff2];
    }
    return _gTableView;
}

- (WVRMineViewModel *) gMineViewModel {
    if (_gMineViewModel == nil) {
        _gMineViewModel = [[WVRMineViewModel alloc] init];
    }
    return _gMineViewModel;
}

#pragma reloadData
- (void)showUserViewModel
{
    [self.gTableView reloadData];
}
@end
