//
//  WVRTVDetailBaseController.m
//  WhaleyVR
//
//  Created by qbshen on 2017/1/11.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRTVDetailBaseController.h"
#import "WVRVideoEntityMoreTV.h"

@interface WVRTVDetailBaseController ()

@end


@implementation WVRTVDetailBaseController

- (WVRTVItemModel *)shouldCollectionModel {
    
    return self.httpItemModel;
}

- (void)requestInfo {
    
//    self.sid = self.createArgs.linkArrangeValue;
}

- (void)loadSubView:(WVRTVItemModel *)itemModel {
    
    WVRTVDetailViewInfo * vInfo = [WVRTVDetailViewInfo new];
    vInfo.frame = self.view.bounds;
    vInfo.itemModel = itemModel;
    WVRTVDetailView* tvDV = [WVRTVDetailView createWithInfo:vInfo];
    tvDV.delegate = self;
    self.mtvDetailV = tvDV;
    [self.view addSubview:tvDV];
    
    [super drawUI];
    
    [self playAction];      // 开始播放
}

- (void)requestCollectionStatus {
    
    kWeakSelf(self);
    [WVRCollectionVCModel http_CollectionOneWithModel:[self shouldCollectionModel] successBlock:^(WVRCollectionModel *collectionModel) {
        
        [weakself httpCollectionStatusBlock:collectionModel];
    
    } failBlock:^(NSString *errMsg) {
        
        [weakself httpCollectionStatusBlock:nil];
    }];
}

- (void)httpCollectionStatusBlock:(WVRCollectionModel *)collectionModel {
    
    SQHideProgress;
    [self.mErrorView removeFromSuperview];
    self.httpItemModel.haveCollection = collectionModel? YES:NO;
    [self.mtvDetailV updateCollectionStatus:self.httpItemModel.haveCollection];
}

- (void)networkFaild:(NSString*)errMsg {
    
    self.bar.hidden = NO;
    [self.view bringSubviewToFront:self.bar];
    
    SQHideProgress;
    SQToast(@"网络异常");
    kWeakSelf(self);
    if (!self.mErrorView) {
        WVRNetErrorView *view = [WVRNetErrorView errorViewForViewReCallBlock:^{
            [weakself.mErrorView removeFromSuperview];
            [weakself requestInfo];
        } withParentFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        self.mErrorView = view;
    }
    if (!self.httpItemModel) {
        [self.view addSubview:self.mErrorView];
    }
}

#pragma detailView - delegate

- (void)onClickItemType:(WVRVideoDBottomViewType)type bottomView:(WVRVideoDetailBottomView *)view {
    
    switch (type) {
        case WVRVideoDBottomViewTypeDown:
            SQToast(@"版权原因，暂不提供缓存");
            break;
        case WVRVideoDBottomViewTypeCollection:
            [self httpCollection:view];
            break;
        case WVRVideoDBottomViewTypeShare:
            [self shareOnClick];
            break;
        default:
            break;
    }
}

- (void)didSelectItemModel:(WVRTVItemModel *)itemModel {
    
}

- (void)httpCollection:(WVRVideoDetailBottomView *)view {
    
//    if ([WVRLoginTool checkAndAlertLogin]) {
//        if (self.httpItemModel.haveCollection) {
//            [self httpCollectionDel:view];
//        }else{
//            [self httpCollectionSave:view];
//        }
//    }
}

- (void)httpCollectionSave:(WVRVideoDetailBottomView *)view {
    
    kWeakSelf(self);

    [WVRCollectionVCModel http_CollectionSaveWithModel:[self shouldCollectionModel] successBlock:^{
        SQToastInKeyWindow(kToastCollectionSuccess);
        [view updateCollectionDone:YES];
        weakself.httpItemModel.haveCollection = YES;
    } failBlock:^(NSString *errMsg) {
        SQToastInKeyWindow(kToastCollectionFail);
    }];
}

- (void)httpCollectionDel:(WVRVideoDetailBottomView *)view {
    
    kWeakSelf(self);
    [WVRCollectionVCModel http_CollectionDelWithModel:[self shouldCollectionModel] successBlock:^{
        SQToastInKeyWindow(kToastCancelCollectionSuccess);
        [view updateCollectionDone:NO];
        weakself.httpItemModel.haveCollection = NO;
    } failBlock:^(NSString *errMsg) {
        SQToastInKeyWindow(kToastCancelCollectionFail);
    }];
}

#pragma mark - share

- (void)shareOnClick {
    // 分享功能模块
    WVRShareType type = WVRShareTypeMoreTV;
    if (self.httpItemModel.linkType_ == WVRLinkTypeMoreTV) {
        type = WVRShareTypeMoreTV;
    } else if (self.httpItemModel.linkType_ == WVRLinkTypeMoreMovie) {
        type = WVRShareTypeMoreMovie;
    }
    WVRUMShareView *shareView = [WVRUMShareView shareWithContainerView:self.view
                                                                  sID:self.httpItemModel.code
                                                              iconUrl:self.httpItemModel.thubImageUrl
                                                                title:self.httpItemModel.name
                                                                intro:self.httpItemModel.intrDesc
                                                                mobId:nil
                                                            shareType:type ];
    
}

#pragma mark - play

- (void)playAction {
    
//    [WVRTrackEventMapping trackEvent:@"subjectDetail" flag:@"play"];
    
    [self valuationForVideoEntityWithModel:self.httpItemModel];
    
    [self uploadPlayCount];
    
    [self startToPlay];
}

- (void)uploadViewCount {       // 上传浏览次数
    
    [self uploadCountWithType:@"view"];
}

- (void)uploadPlayCount {
    
    [self uploadCountWithType:@"play"];
}

- (void)uploadCountWithType:(NSString *)type {       // 上传统计次数
    
    // beta
//    [WVRAppModel uploadViewInfoWithCode:self.videoEntity.sid programType:@"moretv_tv" videoType:@"moretv_2d" type:type sec:nil title:nil];
}

- (BOOL)reParserPlayUrl {
    
    BOOL canRetry = self.videoEntity.canTryNext;
    if (canRetry) {
        [self.videoEntity nextPlayUrlForVE];
    }
    
    return canRetry;
}

- (void)valuationForVideoEntityWithModel:(WVRTVItemModel *)model {
    
    WVRVideoEntityMoreTV *ve = (WVRVideoEntityMoreTV *)self.videoEntity;
        
    if (nil == ve || ![ve isKindOfClass:[WVRVideoEntityMoreTV class]]) {
        ve = [[WVRVideoEntityMoreTV alloc] init];
    }
    ve.videoTitle = model.name;
    ve.sid = model.sid;
    ve.needCharge = model.isChargeable;
    ve.price = model.price;
    ve.biEntity.totalTime = model.duration.intValue;
    ve.code = model.code;
    
    ve.needParserURL = [model.playUrlArray firstObject];
    ve.playUrls = model.playUrlArray;
    ve.detailItemModels = model.tvSeries;
    
    self.videoEntity = ve;
}

@end
