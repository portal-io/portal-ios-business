//
//  WVRLiveController.m
//  WhaleyVR
//
//  Created by qbshen on 2016/12/6.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRLiveController.h"


#import "WVRSQFindUIStyleHeader.h"

#import "WVRLiveGotoTool.h"

#import "SQRefreshHeader.h"
#import "WVRGotoNextTool.h"

#import "SQPageView.h"
#import "SQCollectionView.h"

#import "WVRLiveReservePresenter.h"
#import "WVRLiveReViewPresenter.h"
#import "WVRLiveTopTabViewPresenter.h"
#import "WVRLiveRecommendPresenter.h"

#import "WVRLiveRecommendPresenter.h"
#import "WVRLiveShowPresenter.h"
#import "WVRSmallPlayerPresenter.h"
#import "WVRLiveTabTipView.h"
#import "WVRFootballPresenter.h"
#import "WVRBaseSubPagePresenter.h"

#define HEIGHT_TTVIEW (50 + kStatuBarHeight)

@interface WVRLiveController ()<UIScrollViewDelegate, WVRLiveTopTabProtocol>

@property (nonatomic) WVRLiveTopTabViewPresenter* mTopTabP;

@property (nonatomic)  SQPageView *mPageView;

@property (nonatomic) NSArray * mSubPresenters;

@property (nonatomic) NSArray * mSubViews;

@property (nonatomic) BOOL preIsPlaying;

@property (nonatomic) NSInteger mCurPageIndex;

@property (nonatomic) NSInteger mRecommendIndex;

@property (nonatomic) WVRLiveTabTipView * mTipV;

@property (nonatomic) BOOL mTTLoadSuccess;

@end


@implementation WVRLiveController
//
//+ (instancetype)createViewController:(id)createArgs {
//    
//    WVRLiveController * vc = [[WVRLiveController alloc] init];
//    vc.view.backgroundColor = k_Color11;
//    vc.createArgs = createArgs;
//    vc.automaticallyAdjustsScrollViewInsets = NO;
//    [vc requestInfo];
//    
//    return vc;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gToOrientAble = NO;
    self.gShouldAutorotate = NO;
    self.gSupportedInterfaceO = UIInterfaceOrientationMaskPortrait;
    self.view.backgroundColor = k_Color11;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self requestInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [WVRSmallPlayerPresenter shareInstance].controller = self;
    if (self.mTTLoadSuccess) {
        self.mTTLoadSuccess = NO;
        [self addTipView];
    }
    if ([[WVRSmallPlayerPresenter shareInstance] isLaunch]) {
        [[WVRSmallPlayerPresenter shareInstance] restartForLaunch];
    } else {
        self.gShouldAutorotate = YES;
        UIInterfaceOrientation ori = UIInterfaceOrientationPortrait;
        self.gSupportedInterfaceO = UIInterfaceOrientationMaskPortrait;
        [WVRAppModel forceToOrientation:ori];
    }
    //    if (!self.curPlayerP) {
    //        self.curPlayerP = [WVRSmallPlayerPresenter createPresenter:nil];
    //        self.curPlayerP.controller = self;
    //        UIView * v = [self.curPlayerP getView];
    //        v.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH*9/16);
    //        v.backgroundColor = [UIColor redColor];
    //        [self.view addSubview:v];
    //    }
    //    [self.curPlayerP reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([[WVRSmallPlayerPresenter shareInstance] isLaunch]) {
        [[WVRSmallPlayerPresenter shareInstance] setIsLaunch:NO];
        //        [[WVRSmallPlayerPresenter shareInstance] restartForLaunch];
    } else {
        if (self.mCurPageIndex == self.mRecommendIndex) {
            [[WVRSmallPlayerPresenter shareInstance] updateCanPlay:YES];
            //        if (self.preIsPlaying) {
            //            [[WVRSmallPlayerPresenter shareInstance] reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:NAME_NOTF_LIVE_TAB_RELOAD_PLAYER object:nil];
            //        }
        }
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //    CGRect subViewFrame = CGRectMake(0, 0, self.mPageView.width, self.mPageView.height);
    //    for (UIView * view in self.mSubViews) {
    //        view.bounds = subViewFrame;
    //    }
    //    [[NSNotificationCenter defaultCenter] postNotificationName:NAME_NOTF_LAYOUTSUBVIEWS_LIVE_RECOMMEND object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([[WVRSmallPlayerPresenter shareInstance] isLaunch]) {
        
    }
    else {
        if (self.mCurPageIndex == self.mRecommendIndex) {
            self.preIsPlaying = [[WVRSmallPlayerPresenter shareInstance] isPlaying];
            [[WVRSmallPlayerPresenter shareInstance] destroy];
            [[WVRSmallPlayerPresenter shareInstance] updateCanPlay:NO];
        }
    }
}
- (void)requestInfo {
    [super requestInfo];
    
    @synchronized (self) {
        self.preIsPlaying = NO;
        [[WVRSmallPlayerPresenter shareInstance] updateCanPlay:YES];
        [[WVRSmallPlayerPresenter shareInstance] destroy];
        [self loadTopTabPresenter];
    }
}

- (void)loadTopTabPresenter {
    
    if (!self.mTopTabP) {
        [self initTTP];
    }
    SQShowProgress;
    [self.mTopTabP reloadData];
}

- (void)initTTP {
    
    kWeakSelf(self);
    self.mTopTabP = [WVRLiveTopTabViewPresenter createPresenter:nil];
    self.mTopTabP.controller = self;
    self.mTopTabP.scrollView = self.mPageView;
    self.mTopTabP.refreshSuccessBlock = ^(NSArray<WVRItemModel*> *itemModels) {
        
        [weakself ttPRefreshSuccessBlock:itemModels];
    };
    self.mTopTabP.refreshFaileBlock = ^(NSString *errMsg) {
        [weakself ttPRefreshFailBlock:errMsg];
    };
}

- (void)ttPRefreshSuccessBlock:(NSArray<WVRItemModel *> *)itemModels {
    
    [self destroy];
    [self  hidenLoading];
    if (itemModels.count == 0) {
        if (self.mSubViews.count == 0) {
            kWeakSelf(self);
            [self showNetErrorVWithreloadBlock:^{
                [weakself.mTopTabP reloadData];
            }];
            return;
        }
    }
    UIView * ttView = [self.mTopTabP getView];
    ttView.frame = CGRectMake(0, 0, SCREEN_WIDTH, HEIGHT_TTVIEW);
    [self.view addSubview:ttView];
    [self.view addSubview:self.mPageView];
    [self addSubPageViewToPageV:itemModels];
    self.mTTLoadSuccess = YES;
}

- (void)destroy {
    
    self.mSubViews = nil;
    self.mSubPresenters = nil;
}

- (void)addTipView {
    
    if (![WVRUserModel sharedInstance].liveTipIsShow) {
        WVRLiveTabTipView * tipV = (WVRLiveTabTipView*)VIEW_WITH_NIB(NSStringFromClass([WVRLiveTabTipView class]));
        tipV.frame = self.view.bounds;
        [tipV.tipBtn addTarget:self action:@selector(dismissTipV) forControlEvents:UIControlEventTouchUpInside];
        self.mTipV = tipV;
        [[UIApplication sharedApplication].keyWindow addSubview:tipV];
        [WVRUserModel sharedInstance].liveTipIsShow = YES;
    }
}

- (void)dismissTipV {
    
    [self.mTipV removeFromSuperview];
    self.mTipV = nil;
}

- (void)ttPRefreshFailBlock:(NSString *)errMsg {
    
    [self  hidenLoading];
    if (self.mSubPresenters.count>0) {
        return;
    }
    kWeakSelf(self);
    [self  showNetErrorVWithreloadBlock:^{
        [weakself requestInfo];
    }];

}



- (SQPageView *)mPageView {
    
    if (!_mPageView) {
        _mPageView = [[SQPageView alloc] initWithFrame:CGRectMake(0, HEIGHT_TTVIEW, SCREEN_WIDTH, self.view.height-HEIGHT_TTVIEW-kTabBarHeight)];
        _mPageView.pagingEnabled = YES;
        _mPageView.delegate = self;
        _mPageView.alwaysBounceHorizontal = NO;
        _mPageView.alwaysBounceVertical = NO;
        _mPageView.showsHorizontalScrollIndicator = NO;
        [self.view addSubview:_mPageView];
    }
    return _mPageView;
}

- (void)addSubPageViewToPageV:(NSArray<WVRItemModel*> *)itemModels {
    
    CGRect subViewFrame = CGRectMake(0, 0, self.mPageView.width, self.mPageView.height);
    NSMutableArray * subPresenters = [NSMutableArray new];
    NSMutableArray * subViews = [NSMutableArray new];
    for (WVRItemModel * cur in itemModels) {
        if ([cur.linkArrangeType isEqualToString:LINKARRANGETYPE_LIVEORDERLIST]) {
            WVRLiveReservePresenter* liveReserveP =[WVRLiveReservePresenter createPresenter:self];
            liveReserveP.controller = self;
            UIView* reserveV = [liveReserveP getView];
            reserveV.frame = subViewFrame;
            [subPresenters addObject:liveReserveP];
            [subViews addObject:reserveV];
        }else if ([cur.linkArrangeType isEqualToString:LINKARRANGETYPE_RECOMMENDPAGE]) {
            if ([cur.recommendPageType isEqualToString:RECOMMENDPAGETYPE_MIX]) {
                WVRLiveRecommendPresenter* liveRecommendP = [WVRLiveRecommendPresenter createPresenter:cur.linkArrangeValue];
                liveRecommendP.controller = self;
                UIView* recommendV = [liveRecommendP getView];
                recommendV.frame = subViewFrame;
                [subPresenters addObject:liveRecommendP];
                [subViews addObject:recommendV];
                self.mRecommendIndex = [itemModels indexOfObject:cur];
            }else if ([cur.recommendPageType isEqualToString:RECOMMENDPAGETYPE_PAGE]) {
                WVRLiveReViewPModel * pModel = [WVRLiveReViewPModel new];
                pModel.linkCode = cur.linkArrangeValue;
                pModel.subCode = [cur.recommendAreaCodes firstObject];
                WVRLiveReViewPresenter* liveReviewP = [WVRLiveReViewPresenter createPresenter:pModel];
                
                liveReviewP.controller = self;
                UIView * reviewCollectionV = [liveReviewP getView];
                reviewCollectionV.frame = subViewFrame;
                [subPresenters addObject:liveReviewP];
                [subViews addObject:reviewCollectionV];
            }
        }else if ([cur.linkArrangeType isEqualToString:LINKARRANGETYPE_SHOWLIST]) {
            WVRLiveShowPresenter * showP = [WVRLiveShowPresenter createPresenter:cur.code];
            UIView * showV = [showP getView];
            showV.frame = subViewFrame;
            [subPresenters addObject:showP];
            [subViews addObject:showV];
        }else if ([cur.linkArrangeType isEqualToString:LINKARRANGETYPE_FOOTBALLLIST]) {
            WVRFootballPresenter * footballP = [WVRFootballPresenter createPresenter:cur.linkArrangeValue];
            footballP.controller = self;
            UIView * footballV = [footballP getView];
            footballV.frame = subViewFrame;
            [subPresenters addObject:footballP];
            [subViews addObject:footballV];
        }
    }
    self.mSubPresenters = subPresenters;
    self.mSubViews = subViews;
    [self.mPageView addSubPageViews:self.mSubViews y:0];
    [self pageViewScrollToZero];
    if (self.mCurPageIndex==self.mRecommendIndex) {
      [[WVRSmallPlayerPresenter shareInstance] updateCanPlay:YES];
    }else{
      [[WVRSmallPlayerPresenter shareInstance] updateCanPlay:NO];
    }
}

- (void)itemPageView:(WVRItemModel *)itemModel {
    
//    switch (itemModel.linkType_) {
//        case <#constant#>:
//            <#statements#>
//            break;
//            
//        default:
//            break;
//    }
}


#pragma mark - WVRLiveTopTabProtocol

- (void)didSelectItem:(NSInteger)index {
    
    [self pageViewScrollToPageIndex:index];
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    float xx = scrollView.contentOffset.x ;
    NSInteger index = xx/self.mPageView.frame.size.width;
    [self.mTopTabP updateSegmentSelectIndex:index];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    float xx = scrollView.contentOffset.x ;
    NSInteger index = xx/self.mPageView.frame.size.width;
    [self.mTopTabP updateSegmentSelectIndex:index];
    NSLog(@"index: %d",(int)index);
    [self updateCurIndex:index];
}

- (void)updateCurIndex:(NSInteger)index {
    
    if (self.mCurPageIndex != index) {
        [self updatePageView:index];
        self.mCurPageIndex = index;
    }
}

- (void)pageViewScrollToPageIndex:(NSInteger)index {
    
    NSLog(@"index: %d", (int)index);
    float xx = self.mPageView.frame.size.width * index;
    [self.mPageView scrollRectToVisible:CGRectMake(xx, 0, self.mPageView.frame.size.width, self.mPageView.frame.size.height) animated:YES];
    [self updateCurIndex:index];
}

- (void)pageViewScrollToZero {
    
    self.mCurPageIndex = 0;
    [self.mPageView scrollRectToVisible:CGRectMake(0, 0, self.mPageView.frame.size.width, self.mPageView.frame.size.height) animated:YES];
    [self updatePageView:0];
}

- (void)updatePageView:(NSInteger)index {
    
    [self updatePlayerStatus:index];
    if (index<self.mSubPresenters.count) {
        SQBasePresenter * presenter = self.mSubPresenters[index];
        [presenter reloadData];
    }
}

- (void)updatePlayerStatus:(NSInteger)index {
    
    if (index == self.mRecommendIndex) {
        [[WVRSmallPlayerPresenter shareInstance] updateCanPlay:YES];
//        if (self.preIsPlaying) {
//            [[WVRSmallPlayerPresenter shareInstance] reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:NAME_NOTF_LIVE_TAB_RELOAD_PLAYER object:nil];
//        }
    } else if (self.mCurPageIndex == self.mRecommendIndex) {
        self.preIsPlaying = [[WVRSmallPlayerPresenter shareInstance] isPlaying];
        [[WVRSmallPlayerPresenter shareInstance] destroy];
        [[WVRSmallPlayerPresenter shareInstance] updateCanPlay:NO];
    } else {
          [[WVRSmallPlayerPresenter shareInstance] updateCanPlay:NO];
    }
}

- (void)showShowList {
    
    for (WVRBaseSubPagePresenter* sub in self.mSubPresenters) {
        if ([sub isKindOfClass:[WVRLiveShowPresenter class]]) {
            [self didSelectItem:[self.mSubPresenters indexOfObject:sub]];
            break;
        }
    }
}

//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

- (BOOL)prefersStatusBarHidden {
    
    BOOL isRight = [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait;
    
    return !isRight||self.hidenStatusBar;     // _isLandspace
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    
    return UIStatusBarAnimationFade;
}

- (void)dealloc {
    
    DebugLog(@"");
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
