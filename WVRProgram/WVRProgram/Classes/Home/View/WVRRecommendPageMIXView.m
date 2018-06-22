//
//  WVRRecommendPageView.m
//  WhaleyVR
//
//  Created by qbshen on 2017/1/3.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRRecommendPageMIXView.h"
#import "WVRSQFindModel.h"
#import "SQCollectionView.h"
#import "SQRefreshHeader.h"
#import "WVRSQBannerReusableHeader.h"
#import "WVRSmallPlayerPresenter.h"
#import "WVRBaseViewSection.h"
#import "WVRViewModelDispatcher.h"
#import "WVRNetErrorView.h"

@interface WVRRecommendPageMIXView ()

//@property (nonatomic) WVRSQFindModel *mRecommendModel;

@property (nonatomic) SQCollectionViewDelegate * mDelegate;
@property (nonatomic) WVRNetErrorView* mErrorView;
@property (nonatomic) WVRRecommendPageMIXViewInfo * mVInfo;
@property (nonatomic) NSMutableDictionary* originDic;
@property (nonatomic) NSDictionary * modelDic;
@property (nonatomic) WVRSQFindModel * findModel;

@property (nonatomic) WVRSQBannerReusableHeaderInfo * mBannerHeaderInfo;

@end


@implementation WVRRecommendPageMIXView

+ (instancetype)createWithInfo:(WVRRecommendPageMIXViewInfo *)vInfo {
    
    WVRRecommendPageMIXView * pageV = [[WVRRecommendPageMIXView alloc] initWithFrame:vInfo.frame collectionViewLayout:[UICollectionViewFlowLayout new] withVInfo:vInfo];
    
    return pageV;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout withVInfo:(WVRRecommendPageMIXViewInfo *)vInfo {
    self =  [super initWithFrame:frame collectionViewLayout:layout];
    
    if (self) {
        kWeakSelf(self);
        self.mVInfo = vInfo;
        self.backgroundColor = k_Color10;
        SQRefreshHeader * refreshHeader = [SQRefreshHeader headerWithRefreshingBlock:^{
            [weakself.mErrorView removeFromSuperview];
            [weakself headerRefreshRequest:NO];
        }];
        self.mj_header = refreshHeader;
        SQCollectionViewDelegate * delegate = [SQCollectionViewDelegate new];
        self.delegate = delegate;
        self.dataSource = delegate;
        self.mDelegate = delegate;
        delegate.scrollDidScrolling = ^(CGFloat y){
            [weakself checkBannerVisibleBlock:y];
        };

//        [self registerNibForView:self];
        WVRNetErrorView *view = [WVRNetErrorView errorViewForViewReCallBlock:^{
            [weakself.mErrorView removeFromSuperview];
            [weakself headerRefreshRequest:YES];
        } withParentFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        view.y -= kNavBarHeight;
        self.mErrorView = view;
    }
    return self;
}

- (void)checkBannerVisibleBlock:(CGFloat)y {
    
    if (y < fitToWidth(290.f)) {
        if ([[WVRSmallPlayerPresenter shareInstance] prepared]) {
            if (![WVRSmallPlayerPresenter shareInstance].isPlaying) {
                if ([WVRReachabilityModel sharedInstance].isWifi) {
                    [[WVRSmallPlayerPresenter shareInstance] start];
                }
            }
        }
        [[WVRSmallPlayerPresenter shareInstance] setShouldPause:NO];
    } else if(y > fitToWidth(290.f)) {
        [[WVRSmallPlayerPresenter shareInstance] setShouldPause:YES];
        if ([WVRSmallPlayerPresenter shareInstance].isPlaying) {
            [[WVRSmallPlayerPresenter shareInstance] stop];
        }
    }
//    NSArray * visibleCells = [self.mCollectionV visibleCells];
//    BOOL bannerCellIsVisible = NO;
//    for (NSObject * obj in visibleCells) {
//        if ([obj isKindOfClass:[WVRLiveRecommendBannerCell class]]) {
//            bannerCellIsVisible = YES;
//        }
//    }
}


- (void)requestInfo {
    
    if (self.originDic.count ==0) {
        [self headerRefreshRequest:YES];
    }
}

- (void)headerRefreshRequest:(BOOL)firstRequest {
    
    kWeakSelf(self);
    if (self.originDic.count==0&&firstRequest) {
        SQShowProgress;
    }
    if (!self.findModel) {
        self.findModel = [WVRSQFindModel new];
    }
    [self.findModel http_recommendPageWithCode:self.mVInfo.sectionModel.linkArrangeValue successBlock:^(NSDictionary *args, NSString* name, NSString* pageName) {
        SQHideProgress;
        weakself.modelDic = args;
        [weakself parseInfoToOriginDic];
        [weakself updateCollectionView];
        weakself.mVInfo.viewController.title = pageName;
    } failBlock:^(NSString *failDes) {
        SQHideProgress;
        [weakself networkFaild];
    }];
}

- (void)networkFaild {
    [self.mj_header endRefreshing];
    if (self.originDic.count > 0) {      // 已有界面
        SQToastInKeyWindow(kNetError);
    } else {                         // 未有界面
        [self addSubview:self.mErrorView];
    }
}

- (void)parseInfoToOriginDic {
    
    if (!self.originDic) {
        self.originDic = [NSMutableDictionary dictionary];
    }
    [self.originDic removeAllObjects];
    for (NSNumber *key in [self.modelDic allKeys]) {
        WVRSectionModel * sectionModel = self.modelDic[key];
        WVRCollectionViewSectionInfo * sectionInfo = [self sectionInfo:sectionModel];
//        sectionInfo.viewController = self.mVInfo.viewController;
//        sectionInfo.collectionView = self;
        self.originDic[key] = sectionInfo;
    }
}

- (WVRBaseViewSection*)sectionInfo:(WVRSectionModel*)sectionModel {
    
//    NSLog(@"recommendAreaType:%ld", (long)sectionModel.sectionType);
    WVRBaseViewSection * sectionInfo = nil;
    NSInteger type = sectionModel.sectionType;
    sectionInfo = [WVRViewModelDispatcher dispatchSection:[NSString stringWithFormat:@"%d",(int)type] args:sectionModel];//[self getADSectionInfo:sectionModel type:type];
    [sectionInfo registerNibForCollectionView:self];
//    sectionInfo.viewController = self.mVInfo.viewController;
    return sectionInfo;
}

- (void)updateCollectionView {
    
    [self.mErrorView removeFromSuperview];
    [self.mDelegate loadData:self.originDic];
    [self reloadData];
    [self.mj_header endRefreshing];
}

- (void)updateBannerAutoScroll:(BOOL)isAuto {
    
//    [self.mCollectionRouter updateBannerAutoScroll:isAuto];
}

//- (void)dealloc {
//    
//    DebugLog(@"");
//}

@end


@implementation WVRRecommendPageMIXViewInfo

@end
