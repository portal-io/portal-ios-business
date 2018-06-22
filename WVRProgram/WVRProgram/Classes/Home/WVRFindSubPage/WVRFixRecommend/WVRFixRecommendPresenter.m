//
//  WVRFixRecommendCollectionPresenter.m
//  WhaleyVR
//
//  Created by qbshen on 2017/3/21.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRFixRecommendPresenter.h"
#import "WVRSQFindModel.h"
#import "WVRSmallPlayerPresenter.h"
#import "WVRBaseViewSection.h"
#import "WVRViewModelDispatcher.h"
#import "SQRefreshHeader.h"
#import "WVRBaseCollectionView.h"

#import "WVRFixRecommendViewModel.h"

@interface WVRFixRecommendPresenter()

//@property (nonatomic, weak) id<WVRCollectionViewPresenterProtocol> mView;

@property (nonatomic, strong) NSMutableDictionary * originDic;

@property (nonatomic, strong) WVRSQFindModel * findModel;

@property (nonatomic, weak) WVRBaseViewSection * mSinglPlayerSection;

@property (nonatomic, strong) WVRFixRecommendViewModel * gFixRecommendViewModel;

@end

@implementation WVRFixRecommendPresenter

@page(([NSString stringWithFormat:@"%d%@",(int)WVRLinkTypeMix,RECOMMENDPAGETYPE_MIX]), NSStringFromClass([WVRFixRecommendPresenter class]))

- (instancetype)initWithParams:(id)params attchView:(id<WVRCollectionViewProtocol>)view {
    
    self = [super init];
    if (self) {
        self.args = params;
        self.collectionViewDelegte = [SQCollectionViewDelegate new];
        kWeakSelf(self);
        self.collectionViewDelegte.scrollDidScrolling = ^(CGFloat y){
            [weakself checkBannerVisibleBlock:y];
        };
        self.gView = view;
        [self installRAC];
    }
    return self;
}

-(WVRFixRecommendViewModel *)gFixRecommendViewModel
{
    if (!_gFixRecommendViewModel) {
        _gFixRecommendViewModel = [[WVRFixRecommendViewModel alloc] init];
    }
    return _gFixRecommendViewModel;
}

-(void)installRAC
{
    @weakify(self);
    [[self.gFixRecommendViewModel mCompleteSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self httpSuccessBlock:x];
    }];
    [[self.gFixRecommendViewModel mFailSignal] subscribeNext:^(WVRErrorViewModel*  _Nullable x) {
        @strongify(self);
        [self httpFailBlock:x.errorMsg];
    }];
}

- (void)checkBannerVisibleBlock:(CGFloat) y {
    
    if (y < fitToWidth(290.f)) {
        if ([[WVRSmallPlayerPresenter shareInstance] prepared]) {
            if ([WVRSmallPlayerPresenter shareInstance].isPaused) {
                if ([WVRReachabilityModel sharedInstance].isWifi) {
                    [[WVRSmallPlayerPresenter shareInstance] start];
                }
            }
        }
        [[WVRSmallPlayerPresenter shareInstance] setShouldPause:NO];
    } else if(y > fitToWidth(290.f)) {
        [[WVRSmallPlayerPresenter shareInstance] setShouldPause:YES];
        if (![WVRSmallPlayerPresenter shareInstance].isPaused) {
            [[WVRSmallPlayerPresenter shareInstance] stop];
        }
    }

}

-(void)fetchData
{
    [self requestInfo];
}

-(void)requestInfo
{
//    kWeakSelf(self);
    [self.gView clear];
    //    [self.mView removeErrorAndNullView:weakself];
    if (self.originDic.count==0) {
        [self.gView showLoadingWithText:nil];
    }
    self.gFixRecommendViewModel.code = [self.args linkArrangeValue] ;
    [[self.gFixRecommendViewModel getFixRecommendCmd] execute:nil];
//    if (!self.findModel) {
//        self.findModel = [WVRSQFindModel new];
//    }
//    [self.findModel http_recommendPageWithCode:[self.args linkArrangeValue] successBlock:^(NSDictionary *args,NSString* name, NSString* pageName) {
//        
//    } failBlock:^(NSString *failDes) {
//        [self.gView hidenLoading];
//        if (weakself.originDic.count == 0) {
//            [weakself.gView showNetErrorVWithreloadBlock:^{
//                [weakself requestInfo];
//            }];
//        }
//    }];
}

-(void)httpSuccessBlock:(id)args
{
    [self.gView hidenLoading];
    [self parseInfoToOriginDic:args];
}

-(void)httpFailBlock:(NSString*)msg
{
    [self.gView hidenLoading];
    if (self.originDic.count == 0) {
        @weakify(self);
        [self.gView showNetErrorVWithreloadBlock:^{
            @strongify(self);
            [self requestInfo];
        }];
    }
}

- (void)requestInfo:(id)requestParams {
    
    self.args = requestParams;
    [self requestInfo];
}

- (void)requestInfoForFirst:(id)requestParams {
    
    if (self.originDic.count == 0) {
        [self requestInfo:requestParams];
    }
}

- (void) headerRefreshRequestInfo:(id)requestParams {
    
    [self headerRefreshRequest:YES requestParams:requestParams? requestParams:self.args];
}


- (void)headerRefreshRequest:(BOOL)firstRequest requestParams:(id)requestParams {
    
    kWeakSelf(self);
    
    if (!self.findModel) {
        self.findModel = [WVRSQFindModel new];
    }
    [self.findModel http_recommendPageWithCode:[requestParams linkArrangeValue] successBlock:^(NSDictionary *args, NSString* name, NSString* pageName) {
        [weakself parseInfoToOriginDic:args];
        [weakself.gView stopHeaderRefresh];
    } failBlock:^(NSString *failDes) {
        if (weakself.originDic.count == 0) {
            [weakself.gView showNetErrorVWithreloadBlock:^{
                [weakself requestInfo];
            }];
        }
        [weakself.gView stopHeaderRefresh];
    }];
}

- (void)parseInfoToOriginDic:(NSDictionary *)args {
    
    if (!self.originDic) {
        self.originDic = [NSMutableDictionary dictionary];
    }
    [self.originDic removeAllObjects];
    
    NSArray * allKeys = [args allKeys];
    for (NSNumber *key in allKeys) {
//        NSLog(@"key:%@",key);
        WVRSectionModel * sectionModel = args[key];
        WVRBaseViewSection * sectionInfo = [self sectionInfo:sectionModel];
//        sectionInfo.viewController = self.viewController;
//        sectionInfo.collectionView = self.collectionView;
        kWeakSelf(self);
        kWeakSelf(sectionInfo)
        sectionInfo.refreshBlock = ^{
            [(WVRBaseCollectionView *)weakself.collectionView updateWithSectionIndex:weaksectionInfo.sectionIndex];
        };
        self.originDic[key] = sectionInfo;
        if (sectionModel.sectionType == WVRSectionModelTypeSinglePlay) {
            self.mSinglPlayerSection = sectionInfo;
        }
    }
//    if (!self.collectionView.delegate) {
//        self.collectionView.delegate = self.collectionViewDelegte;
//        self.collectionView.dataSource = self.collectionViewDelegte;
//    }
    [self.gView setDelegate:self.collectionViewDelegte andDataSource:self.collectionViewDelegte];
    [self.collectionViewDelegte loadData:self.originDic];
    [self.gView reloadData];
}

- (void)reloadPlayer {
    
    if (self.args) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NAME_NOTF_RELOAD_PLAYER object:self.mSinglPlayerSection];
    }
}
@end
