//
//  WVRTVDetailController.m
//  WhaleyVR
//
//  Created by qbshen on 2017/1/4.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRTVDetailController.h"
#import "WVRTVVideoDetailModel.h"
#import "WVRCollectionVCModel.h"
//#import "WVRLoginTool.h"

@interface WVRTVDetailController () {
    NSInteger _currentEpisode;
}

@property (nonatomic) WVRTVItemModel * mParentModel;

@end


@implementation WVRTVDetailController

+ (instancetype)createViewController:(id)createArgs {
    
    WVRTVDetailController * vc = [[WVRTVDetailController alloc] init];
    vc.view.backgroundColor = [UIColor whiteColor];
    vc.createArgs = createArgs;
    [vc requestInfo];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self navBackSetting];
}

- (WVRTVItemModel *)shouldCollectionModel {
    
    return self.mParentModel;
}

- (void)requestInfo {
    [super requestInfo];
    
    if (!self.mDetailModel) {
        self.mDetailModel = [WVRTVVideoDetailModel new];
    }
    SQShowProgress;
    kWeakSelf(self);
    [self.mDetailModel http_detailWithCode:self.createArgs.linkArrangeValue successBlock:^(WVRTVItemModel *itemModel) {
        [weakself httpDetailSuccessBlock:itemModel];
    } failBlock:^(NSString *errMsg) {
        [weakself networkFaild:@"网络异常"];
    }];
}

- (void)httpDetailSuccessBlock:(WVRTVItemModel *)tvitemModel {
    
    self.httpItemModel = tvitemModel;
    if (!tvitemModel.tvSeries) {//是详情,再去请求一遍系列
        [self requestSeriesInfo:tvitemModel.parentCode];
        self.sid = tvitemModel.code;
    }else{//是系列再去请求一遍详情
        [self initParentModel:tvitemModel];
        [self httpItemRequest];
    }
}

#pragma mark 某个详情
-(void)httpItemRequest {
    
    WVRTVItemModel * firtsModel = [self.httpItemModel.tvSeries firstObject];
    self.httpItemModel.parentCode = self.httpItemModel.code;
    self.httpItemModel.code = firtsModel.code;
    self.sid = self.httpItemModel.code;
    SQShowProgress;
    kWeakSelf(self);
    [self.mDetailModel http_detailWithCode:self.httpItemModel.code successBlock:^(WVRTVItemModel *itemModel) {
        [weakself httpItemSuccessBlock:itemModel];
    } failBlock:^(NSString *errMsg) {
        [weakself networkFaild:@"网络异常"];
    }];
}

-(void)httpItemSuccessBlock:(WVRTVItemModel*)model {
    
    SQHideProgress;
    [self.mErrorView removeFromSuperview];
    self.httpItemModel.code = model.code;
    // 是系列的时候，没有parentCode，把code赋值给parentCode以便收藏系列使用
    self.httpItemModel.name = model.name;
    self.httpItemModel.playCount = model.playCount;
    if (model.thubImageUrl) {
        self.httpItemModel.thubImageUrl = model.thubImageUrl;
    }
    if (model.intrDesc) {
        self.httpItemModel.intrDesc = model.intrDesc;
    }
    self.httpItemModel.curEpisode = model.curEpisode;
    self.httpItemModel.playUrlModels = model.playUrlModels;
    self.httpItemModel.programType = self.createArgs.programType;
    self.httpItemModel.linkArrangeType = self.createArgs.linkArrangeType;
    
    [self loadSubView:self.httpItemModel];
    [self requestCollectionStatus];
}

#pragma mark 系列
- (void)requestSeriesInfo:(NSString*)parentCode {
    
    if (!self.mDetailModel) {
        self.mDetailModel = [WVRTVVideoDetailModel new];
    }
    SQShowProgress;
    kWeakSelf(self);
    [self.mDetailModel http_SerieswithCode:parentCode successBlock:^(WVRTVItemModel *tvitemModel) {
        [weakself httpSeriesInfoSuccessBlock:tvitemModel];
    } failBlock:^(NSString *errMsg) {
        [weakself networkFaild:@"网络异常"];
    }];
}

-(void)httpSeriesInfoSuccessBlock:(WVRTVItemModel*)tvitemModel {
    
    [self initParentModel:tvitemModel];
    SQHideProgress;
    [self.mErrorView removeFromSuperview];
    if (!self.httpItemModel.intrDesc) {
        self.httpItemModel.intrDesc = tvitemModel.intrDesc;
    }
    self.httpItemModel.tvSeries = tvitemModel.tvSeries;
    if (!self.httpItemModel.thubImageUrl) {
        self.httpItemModel.thubImageUrl = tvitemModel.thubImageUrl;
    }
    self.httpItemModel.programType = self.createArgs.programType;
    self.httpItemModel.linkArrangeType = self.createArgs.linkArrangeType;
    [self loadSubView:self.httpItemModel];
    [self requestCollectionStatus];
}

-(void)initParentModel:(WVRTVItemModel*)model {
    
    if (!self.mParentModel) {
        self.mParentModel = [WVRTVItemModel new];
    }
    self.mParentModel.code = model.code;
    self.mParentModel.name = model.name;
    self.mParentModel.playCount = model.playCount;
    self.mParentModel.intrDesc = model.intrDesc;
    self.mParentModel.thubImageUrl = model.thubImageUrl;
    self.mParentModel.actors = model.actors;;
    self.mParentModel.area = model.area;
    self.mParentModel.year = model.year;
    self.mParentModel.director = model.director;
    self.mParentModel.duration = model.duration;
    self.mParentModel.programType = PROGRAMTYPE_MORETV_TV;
}


// 剧集选择
- (void)didSelectItemModel:(WVRTVItemModel *)itemModel {
    
//    [WVRTrackEventMapping trackEvent:@"subjectDetail" flag:@"play"];
//    [self requestCollectionStatus];
    
    [self httpSelectItemRequest];
}

#pragma mark 某个详情
-(void)httpSelectItemRequest {
    
    SQShowProgress;
    kWeakSelf(self);
    [self watch_online_record:NO];
    [self.mDetailModel http_detailWithCode:self.httpItemModel.code successBlock:^(WVRTVItemModel *itemModel) {
        [weakself selectItemHttpUIBlock:itemModel];
    } failBlock:^(NSString *errMsg) {
        [weakself networkFaild:@"网络异常"];
    }];
}

-(void)selectItemHttpUIBlock:(WVRTVItemModel*)model {
    
    SQHideProgress;
    self.httpItemModel.playCount = model.playCount;
    self.httpItemModel.thubImageUrl = model.thubImageUrl;
    self.httpItemModel.playUrl = model.playUrl;
    self.httpItemModel.name = model.name;
    self.httpItemModel.curEpisode = model.curEpisode;
    self.httpItemModel.playUrlModels = model.playUrlModels;
    if (model.thubImageUrl) {
        self.httpItemModel.thubImageUrl = model.thubImageUrl;
    }
    if (model.intrDesc) {
        self.httpItemModel.intrDesc = model.intrDesc;
    }
    [self.mtvDetailV reloadData];
    [self recordHistory];
    [self valuationForVideoEntityWithModel:self.httpItemModel];
    
    [self uploadPlayCount];
    [self startToPlay];
    
}

- (void)playNextVideo {
    
//    [self.videoEntity nextVideoEntity];
    [self.mtvDetailV selectNextItem];
    [self httpSelectItemRequest];
    
//    [self requestCollectionStatus];
//    [self uploadPlayCount];
    
//
//    [self startToPlay];
}

@end
