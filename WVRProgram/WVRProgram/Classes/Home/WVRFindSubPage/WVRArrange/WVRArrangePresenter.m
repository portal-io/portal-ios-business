//
//  WVRArrangePresenterImpl.m
//  WhaleyVR
//
//  Created by qbshen on 2017/3/27.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRArrangePresenter.h"
#import "WVRAutoArrangeModel.h"
#import "WVRSmallPlayerPresenter.h"
#import "WVRSectionModel.h"
#import "WVRBaseViewSection.h"
#import "WVRBaseCollectionView.h"
#import "WVRViewModelDispatcher.h"
#import "SQRefreshFooter.h"

@interface WVRArrangePresenter()

@property (nonatomic, strong) NSMutableDictionary * originDic;

@property (nonatomic, strong) WVRAutoArrangeModel * arrangeModel;

@property (nonatomic, weak) WVRCollectionViewSectionInfo * mSinglPlayerSection;

@end

@implementation WVRArrangePresenter

@page(([NSString stringWithFormat:@"%d",(int)WVRLinkTypeList]), NSStringFromClass([WVRArrangePresenter class]))

- (instancetype)initWithParams:(id)params attchView:(id<WVRCollectionViewProtocol>)view
{
    self = [super init];
    if (self) {
        self.args = params;
        self.collectionViewDelegte = [SQCollectionViewDelegate new];
        kWeakSelf(self);
        self.collectionViewDelegte.scrollDidScrolling = ^(CGFloat y){
            [weakself checkBannerVisibleBlock:y];
        };
        self.gView = view;
    }
    return self;
}

- (void)checkBannerVisibleBlock:(CGFloat) y
{
    if (y<fitToWidth(290.f)) {
        if ([[WVRSmallPlayerPresenter shareInstance] prepared]) {
            if (![WVRSmallPlayerPresenter shareInstance].isPlaying) {
                if ([WVRReachabilityModel sharedInstance].isWifi) {
                    [[WVRSmallPlayerPresenter shareInstance] start];
                }
            }
        }
        [[WVRSmallPlayerPresenter shareInstance] setShouldPause:NO];
    }else if(y>fitToWidth(290.f)){
        [[WVRSmallPlayerPresenter shareInstance] setShouldPause:YES];
        if ([WVRSmallPlayerPresenter shareInstance].isPlaying) {
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
    kWeakSelf(self);
    if (self.originDic.count==0) {
        [self.gView showLoadingWithText:nil];
    }
    if (!self.arrangeModel) {
        self.arrangeModel = [WVRAutoArrangeModel new];
    }
    [self.arrangeModel http_recommendPage:[self.args linkArrangeValue] successBlock:^(NSDictionary *args) {
        [weakself.gView hidenLoading];
        [weakself parseInfoToOriginDic:args];
    } failBlock:^(NSString *failDes) {
        [weakself.gView hidenLoading];
        if (weakself.originDic.count == 0) {
            [weakself.gView showNetErrorVWithreloadBlock:^{
                [weakself requestInfo];
            }];
            //            [weakself.gView showErrorRequestView:nil collectionViewPresenter:weakself];
        }
    }];
}

- (void)requestInfo:(id)requestParams
{
    self.args = requestParams;
    [self requestInfo];
}

- (void)requestInfoForFirst:(id)requestParams
{
    if (self.originDic.count == 0) {
        [self requestInfo:requestParams];
    }
}

- (void) headerRefreshRequestInfo:(id)requestParams
{
    [self headerRefreshRequest:YES requestParams:requestParams? requestParams:self.args];
}

- (void)footerMoreRequestInfo:(id)requestParams
{
    if (self.arrangeModel.sectionModel.pageNum == self.arrangeModel.sectionModel.totalPages-1) {
        [self.gView stopFooterMore:YES];
        return;
    }
    if (self.arrangeModel.sectionModel.itemModels.count==0) {
        [self.gView showLoadingWithText:nil];
    }
    [self footerMoreRequest:YES requestParams:requestParams? requestParams:self.args];
}

- (void)headerRefreshRequest:(BOOL)firstRequest requestParams:(id)requestParams
{
    kWeakSelf(self);
    if (!self.arrangeModel) {
        self.arrangeModel = [WVRAutoArrangeModel new];
    }
    [self.arrangeModel http_recommendPage:[requestParams linkArrangeValue] successBlock:^(NSDictionary *args) {
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

- (void)footerMoreRequest:(BOOL)firstRequest requestParams:(id)requestParams
{
    kWeakSelf(self);
    
    if (!self.arrangeModel) {
        self.arrangeModel = [WVRAutoArrangeModel new];
    }
    [self.arrangeModel http_recommendPageMore:[requestParams linkArrangeValue] successBlock:^(NSDictionary *args) {
        [weakself parseInfoToOriginDic:args];
    } failBlock:^(NSString *failDes) {
        if (weakself.originDic.count == 0) {
            [weakself.gView showNetErrorVWithreloadBlock:^{
                [weakself requestInfo];
            }];
        }
        [weakself.gView stopFooterMore:NO];
    }];
}

- (void)parseInfoToOriginDic:(NSDictionary *)args
{
    if (!self.originDic) {
        self.originDic = [NSMutableDictionary dictionary];
    }
    [self.originDic removeAllObjects];
    
    for (NSNumber *key in [args allKeys]) {
        WVRSectionModel * sectionModel = args[key];
        if (sectionModel.pageNum == sectionModel.totalPages) {
            [self.gView stopFooterMore:YES];
        }else{
            [self.gView stopFooterMore:NO];
        }
        WVRBaseViewSection * sectionInfo = [self sectionInfo:sectionModel];
        kWeakSelf(self);
        kWeakSelf(sectionInfo);
        sectionInfo.refreshBlock = ^{
                [(WVRBaseCollectionView *)weakself.collectionView updateWithSectionIndex:weaksectionInfo.sectionIndex];
        };
        self.originDic[key] = sectionInfo;
        if ([key integerValue] == WVRSectionModelTypeSinglePlay) {
            self.mSinglPlayerSection = sectionInfo;
        }
        break;
    }
    [self.gView setDelegate:self.collectionViewDelegte andDataSource:self.collectionViewDelegte];
//    if (!self.collectionView.delegate) {
//        self.collectionView.delegate = self.collectionViewDelegte;
//        self.collectionView.dataSource = self.collectionViewDelegte;
//    }
    
    [self.collectionViewDelegte loadData:self.originDic];
//    if (!self.collectionView.mj_footer) {
//        kWeakSelf(self);
//        SQRefreshFooter * footer = [SQRefreshFooter footerWithRefreshingBlock:^{
//            [weakself footerMoreRequestInfo:nil];
//        }];
//        self.collectionView.mj_footer = footer;
//    }
    
    [self.gView reloadData];
}



- (void)reloadPlayer
{
    if (self.args) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NAME_NOTF_RELOAD_PLAYER object:self.mSinglPlayerSection];
    }
}
@end
