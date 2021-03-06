//
//  WVRSQBasePageController.m
//  WhaleyVR
//
//  Created by qbshen on 2016/11/20.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRSQBasePageController.h"
#import "WVRSQClassifyCell.h"
#import "SQRefreshHeader.h"
#import "SQRefreshFooter.h"
#import "WVRAutoArrangeView.h"
#import "WVRRecommendPageMIXView.h"

@interface WVRSQBasePageController ()

@end


@implementation WVRSQBasePageController

+ (instancetype)createViewController:(id)createArgs {
    
//    UIStoryboard *board = [UIStoryboard storyboardWithName:@"WVRSQVRFindMoreRecommendController" bundle:nil];
//    WVRSQVRFindMoreRecommendController* vc = [board instantiateViewControllerWithIdentifier:@"WVRSQVRFindMoreRecommendController"];
    
    WVRSQBasePageController * vc = [WVRSQBasePageController new];
    vc.sectionModel = createArgs;
    
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self initData];
    [self requestInfo];
}

- (void)initTitleBar {
    [super initTitleBar];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
}

- (void)back {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initData {
    
    if (!self.sitesDic) {
        self.sitesDic = [NSMutableDictionary dictionary];
    }
    if (!self.subPageViews) {
        self.subPageViews = [NSMutableArray array];
        self.subPageViewDelegates = [NSMutableArray array];
    }
    if (!self.subPageErrorViews) {
        self.subPageErrorViews = [NSMutableArray array];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.mSegmentV setNeedsLayout];//ios 10 viewDidAppear 必调用此方法，scrollwview 的contentSzie才正常
    [self.mPageView setNeedsLayout];
}

- (void)initSegmentV:(NSDictionary *)sectionModelDic {
    
    kWeakSelf(self)
    NSArray * titles = [self segmentVTitles:sectionModelDic];
    if (titles.count == 0) {
        return;
    }
    [self.mSegmentV setItemTitles:titles andScrollView:self.mPageView selectedBlock:^(NSInteger index, NSInteger isRepeat) {
          [weakself pageViewScrollToPageIndex:index];
    }];
//    self.mSegmentV.sectionTitles = titles;
//    self.mSegmentV.selectedSegmentIndex = 0;
//    self.mSegmentV.indexChangeBlock = ^(NSInteger index) {
//        [weakself pageViewScrollToPageIndex:index];
//    };
//    self.mSegmentV.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
}

- (void)initPageView:(NSInteger)pageCount {
    
    for (int i = 0; i < pageCount; i++) {
        WVRSectionModel * sectionModel = self.mModelDic[@(i)];
        if ([sectionModel.linkArrangeType isEqualToString:LINKARRANGETYPE_RECOMMENDPAGE]) {
            [self loadRecommemdPageView:sectionModel];
        }else{
            [self loadNodePageView:sectionModel];
        }
    }
    self.mPageView.delegate = self;
    [self.mPageView addSubPageViews:self.subPageViews y:0];
}

- (void)loadRecommemdPageView:(WVRSectionModel *)sectionModel {
    
    WVRRecommendPageMIXViewInfo * vInfo = [WVRRecommendPageMIXViewInfo new];
    vInfo.viewController = self;
    vInfo.frame = self.view.bounds;
    vInfo.sectionModel = sectionModel;
    vInfo.sectionModel.type = self.sectionModel.type;
    WVRRecommendPageMIXView* subPageV = [WVRRecommendPageMIXView createWithInfo:vInfo];
    subPageV.backgroundColor = UIColorFromRGB(0xebeff2);
    [self.subPageViews addObject:subPageV];
}

- (void)loadNodePageView:(WVRSectionModel *)sectionModel {
    
    WVRAutoArrangeViewInfo * vInfo = [WVRAutoArrangeViewInfo new];
    vInfo.viewController = self;
    vInfo.frame = self.view.bounds;
    vInfo.sectionModel = sectionModel;
    vInfo.sectionModel.type = self.sectionModel.type;
    WVRAutoArrangeView * subPageV = [WVRAutoArrangeView createWithInfo:vInfo];
    subPageV.backgroundColor = UIColorFromRGB(0xebeff2);
    [self.subPageViews addObject:subPageV];
}

- (SQSegmentView *)mSegmentV {
    
    if (!_mSegmentV) {
        _mSegmentV = [[SQSegmentView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, SCREEN_WIDTH, HEIGHT_SEGMENTV)];
        [self.view addSubview:_mSegmentV];
    }
    return _mSegmentV;
}

- (SQPageView *)mPageView {
    
    if (!_mPageView) {
        _mPageView = [[SQPageView alloc] initWithFrame:CGRectMake(0, self.mSegmentV.y+self.mSegmentV.height, SCREEN_WIDTH, HEIGHT_PAGEVIEW)];
        _mPageView.pagingEnabled = YES;
        [self.view addSubview:_mPageView];
    }
    return _mPageView;
}

- (NSArray *)segmentVTitles:(NSDictionary *)sectionModelDic {
    
    NSMutableArray * titles = [NSMutableArray array];
    for (NSInteger i = 0; i < sectionModelDic.count; i ++) {
        WVRSectionModel* sectionModel = sectionModelDic[@(i)];
        [titles addObject:sectionModel.name];
    }
    return titles;
}

- (void)requestInfo {
    [super requestInfo];
    
    if (!self.findMoreModel) {
        self.findMoreModel = [WVRRecommendPageSiteModel new];
    }
    kWeakSelf(self);
    SQShowProgress;
    [self.findMoreModel http_recommendPageWithCode:self.sectionModel.linkArrangeValue successBlock:^(NSDictionary *args, NSString * name) {
        [weakself siteHttpSuccessBlock:args name:name];
    } failBlock:^(NSString *args) {
        [weakself siteHttpFailBlock:args];
    }];
}

- (void)siteHttpSuccessBlock:(NSDictionary *)args name:(NSString *)name {
    
    SQHideProgress;
    self.title = name;
    [self.mErrorView removeFromSuperview];
    if (args.count==0) {
        return ;
    }
    self.mModelDic = args;
    [self initSegmentV:args];
    [self initPageView:args.count];
    [self updatePageView:0];
}

- (void)siteHttpFailBlock:(NSString *)args {
    
    SQHideProgress;
    kWeakSelf(self);
    if (!self.mErrorView) {
        self.mErrorView = [WVRNetErrorView errorViewForViewReCallBlock:^{
            weakself.isTest = YES;
            [weakself requestInfo];
        } withParentFrame:self.mPageView.frame];
    }
    [self.view addSubview:self.mErrorView];
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
//    float xx = scrollView.contentOffset.x ;
//    NSInteger index = xx/self.mPageView.frame.size.width;
//    self.mSegmentV.selectedSegmentIndex = index;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    float xx = scrollView.contentOffset.x ;
    NSInteger index = xx/self.mPageView.frame.size.width;
//    self.mSegmentV.selectedSegmentIndex = index;
    NSLog(@"index: %d", (int)index);
    [self updatePageView:index];
}

- (void)pageViewScrollToPageIndex:(NSInteger)index {
    
    NSLog(@"index: %d", (int)index);
    [self updatePageView:index];
    float xx = self.mPageView.frame.size.width * index;
    [self.mPageView scrollRectToVisible:CGRectMake(xx, 0, self.mPageView.frame.size.width, self.mPageView.frame.size.height) animated:YES];
}

- (void)updatePageView:(NSInteger)index {
    
    WVRAutoArrangeView* subPageView = self.subPageViews[index];
    [subPageView requestInfo];
}

- (void)dealloc {
    
    DebugLog(@"");
}

@end
