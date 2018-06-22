//
//  WVRHomeViewController.m
//  WhaleyVR
//
//  Created by qbshen on 16/11/10.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRHomeViewController.h"
#import "WVRRecommendPageMIXView.h"
#import "WVRSearchViewController.h"
#import "WVRCheckVersionTool.h"

#import "WVRTopBarPresenter.h"
#import "WVRFindNavBarView.h"
#import "WVRFindSearchBar.h"

#import "WVRTopTabView.h"
#import "WVRTopBarPresenter.h"
#import "WVRPageView.h"
#import "WVRHomePagePresenter.h"

#import "WVRSmallPlayerPresenter.h"

#import "WVRHistoryController.h"
#import "WVRAllChannelController.h"

#import "WVRHomePresenter.h"

#import "WVRHomeViewControllerProtocol.h"

#import "WVRMediator+SettingActions.h"

#define COUNT_PAGES (2)

#define STR_RECOMMEND_TYPE (@"recommend_newhome")

@interface WVRHomeViewController ()<WVRTopTabViewDelegate, WVRHomeViewControllerProtocol>

@property (nonatomic, strong) WVRHomePresenter * gHomePresenter;
//@property (nonatomic, strong) WVRTopBarPresenter* mTopBarPresenter;
@property (nonatomic, strong) WVRTopTabView*  mTopTabBarV;
//@property (nonatomic, strong) WVRHomePagePresenter* mPagePresenter;
@property (nonatomic, strong) WVRPageView * mPageView;

@property (nonatomic, strong) WVRFindNavBarView * mNavBarV;

@property (nonatomic, strong) WVRTopTabView * mTopTabBar;


@end


@implementation WVRHomeViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self.gHomePresenter fetchData];
    self.gToOrientAble = NO;
    self.gShouldAutorotate = NO;
    self.gSupportedInterfaceO = UIInterfaceOrientationMaskPortrait;
    self.view.backgroundColor = [UIColor whiteColor];
    [WVRCheckVersionTool checkHaveNewVersion];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if ([[WVRSmallPlayerPresenter shareInstance] isLaunch]) {
        
    }else{
        self.gShouldAutorotate = YES;
        UIInterfaceOrientation ori = UIInterfaceOrientationPortrait;
        self.gSupportedInterfaceO = UIInterfaceOrientationMaskPortrait;
        [WVRAppModel forceToOrientation:ori];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [WVRSmallPlayerPresenter shareInstance].controller = self;
    if ([[WVRSmallPlayerPresenter shareInstance] isLaunch]) {
        [[WVRSmallPlayerPresenter shareInstance] restartForLaunch];
        [[WVRSmallPlayerPresenter shareInstance] setIsLaunch:NO];
    }else{
        [self.gHomePresenter.gPagePresenter updatePlayerStatusForCurIndex];
    }
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([[WVRSmallPlayerPresenter shareInstance] isLaunch]) {
        [[WVRSmallPlayerPresenter shareInstance] destroyForLauncher];
    }
    else{
        [[WVRSmallPlayerPresenter shareInstance] destroy];
        [[WVRSmallPlayerPresenter shareInstance] updateCanPlay:NO];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (void)dealloc
{
    DebugLog(@"");
}


-(WVRHomePresenter *)gHomePresenter
{
    if (!_gHomePresenter) {
        _gHomePresenter = [[WVRHomePresenter alloc] initWithParams:nil attchView:self];
    }
    return _gHomePresenter;
}



-(void)loadSubViews
{
    WVRFindNavBarView *navBarV = [[WVRFindNavBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kNavBarHeight)];//(WVRFindNavBarView *)VIEW_WITH_NIB(NSStringFromClass([WVRFindNavBarView class]));
    kWeakSelf(self);
    navBarV.startSearchClickBlock = ^{
        [weakself searchButtonClicked];
    };
    navBarV.cacheClickBlock = ^{
        [weakself cacheButtonClicked];
    };
    navBarV.historyClickBlock = ^{
        [weakself historyButtonClicked];
    };
    self.mNavBarV = navBarV;
    [self.view addSubview:navBarV];
    
    WVRTopTabView * topTabBar = [[WVRTopTabView alloc] initWithFrame:CGRectMake(0, navBarV.bottomY, SCREEN_WIDTH, fitToWidth(45.f))];
    topTabBar.delegate = self;
    
    self.mTopTabBar = topTabBar;
    [self.view addSubview:topTabBar];
    
    WVRPageView * pageV = [[WVRPageView alloc] initWithFrame:CGRectMake(0, topTabBar.bottomY, SCREEN_WIDTH, self.view.height-topTabBar.bottomY-kTabBarHeight)];
    self.mPageView = pageV;
    self.mPageView.delegate = self.gHomePresenter.gPagePresenter;
    self.mPageView.dataSource = self.gHomePresenter.gPagePresenter;
    [self.view addSubview:pageV];
}

#pragma WVRPageViewProtocol
-(void)scrolling:(CGFloat)scale flag:(BOOL)bigFlag
{
    NSLog(@"scale:%f",scale);
    [self.mTopTabBar scrolling:scale flag:bigFlag];
}

-(void)scrollingToPageNamber:(NSInteger)index
{
    NSLog(@"index: %d",(int)index);
    //    [self.mTopTabBar scrolling];
}

-(void)scrollToPageNamber:(NSInteger)index
{
    float xx = self.mPageView.frame.size.width * index;
    [self.mPageView scrollRectToVisible:CGRectMake(xx, 0, self.mPageView.frame.size.width, self.mPageView.frame.size.height) animated:YES];
    [self.gHomePresenter.gPagePresenter updatePageView:index];
    
}

-(void)scrollViewDidEndDecelerating:(NSUInteger)index
{
    [self.mTopTabBar updateSegmentSelectIndex:index];
}

#pragma WVRFindNavBarView block

- (void)searchButtonClicked
{
    [WVRTrackEventMapping curEvent:@"home" flag:@"research"];
    
    WVRSearchViewController *searchVC = [[WVRSearchViewController alloc] init];
    searchVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchVC animated:YES];
}

- (void)cacheButtonClicked {
    
    UIViewController *localVC = [[WVRMediator sharedInstance] WVRMediator_LocalViewController:YES];
    
    [self.navigationController pushViewController:localVC animated:YES];
}

- (void)historyButtonClicked
{
    WVRHistoryController *historyVC = [[WVRHistoryController alloc] init];
    historyVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:historyVC animated:YES];
}

-(void)reloadData
{
    [self.mPageView reloadData];
}

#pragma WVRTopTabViewProtocol


-(void)updateWithTitles:(NSArray *)titles andItemModels:(NSArray *)itemModels
{
    [self.mTopTabBar updateWithTitles:titles scrollView:self.mPageView];
    
    [self.gHomePresenter.gPagePresenter setArgs:itemModels];
    [self.gHomePresenter.gPagePresenter fetchData];
}

#pragma WVRTopTabViewDelegate

-(void)didSelectSegmentItem:(NSInteger)index;
{
    float xx = self.mPageView.frame.size.width * index;
    [self.mPageView scrollRectToVisible:CGRectMake(xx, 0, self.mPageView.frame.size.width, self.mPageView.frame.size.height) animated:YES];
    [self.gHomePresenter.gPagePresenter updatePageView:index];
}

-(void)didSelectRightItem;
{
    NSLog(@"select rightItem");
    WVRAllChannelController * vc = [WVRAllChannelController new];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)prefersStatusBarHidden {
    
    BOOL isRight = [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait;
    
    return !isRight||self.hidenStatusBar;     // _isLandspace
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    
    return UIStatusBarAnimationFade;
}
#pragma mark - orientation

- (BOOL)shouldAutorotate {
    
    return self.gShouldAutorotate;//self.hidenStatusBar;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return self.gSupportedInterfaceO;//UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
