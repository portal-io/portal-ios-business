//
//  WVRVideoDetailModel.m
//  WhaleyVR
//
//  Created by qbshen on 2017/1/4.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRTVVideoDetailModel.h"
#import "WVRHttpProgramDetail.h"


@implementation WVRTVVideoDetailModel

#pragma mark - http movie

- (void)http_detailWithCode:(NSString*)code successBlock:(void(^)(WVRTVItemModel*))successBlock failBlock:(void(^)(NSString*))failBlock {
    
    kWeakSelf(self);
    WVRHttpProgramDetail *cmd = [WVRHttpProgramDetail new];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[kHttpParams_programDetail_code] = code;
    cmd.bodyParams = params;
    cmd.successedBlock = ^(WVRHttpProgramDetailModel* args) {
        [weakself httpSuccessBlock:args successBlock:^(WVRTVItemModel *itemModel) {
            successBlock(itemModel);
        }];
    };
    
    cmd.failedBlock = ^(id args) {
        if ([args isKindOfClass:[NSString class]]) {
            failBlock(args);
        }
    };
    [cmd execute];
}

- (void)httpSuccessBlock:(WVRHttpProgramDetailModel *)args successBlock:(void(^)(WVRTVItemModel *))successBlock {
    
    WVRTVItemModel * itemModel = [WVRTVItemModel new];
    itemModel.code = args.data.code;
    itemModel.parentCode = args.data.parentCode;
    itemModel.name = args.data.displayName;
    itemModel.playCount = args.data.stat.playCount;
    itemModel.intrDesc = args.data.desc;
    itemModel.curEpisode = args.data.curEpisode;
    itemModel.thubImageUrl = args.data.smallPic;
    itemModel.actors = args.data.actors;
    itemModel.area = args.data.area;
    itemModel.year = args.data.year;
    itemModel.director = args.data.director;
    itemModel.duration = args.data.duration;
    itemModel.score = args.data.score;
    if (itemModel.thubImageUrl.length <= 0) {
        itemModel.thubImageUrl = args.data.pics;
    }
    
    itemModel.playUrlModels = [self parsePlayUrlModel:args.data.medias];
    itemModel.tags_ = [args.data.tags componentsSeparatedByString:@","];
    if (args.data.series) {
        [self parseSerise:args.data.series itemModel:itemModel];
    }
    successBlock(itemModel);
}

- (NSMutableArray *)parsePlayUrlModel:(NSArray<WVRHttpProgramMediasModel *> *)medias {
    
    NSMutableArray * playUrlModels = [NSMutableArray array];
    for (WVRHttpProgramMediasModel * model in medias) {
        WVRTVPlayUrlModel * tvPlayModel = [WVRTVPlayUrlModel new];
        tvPlayModel.playUrl = model.playUrl;
        tvPlayModel.source = model.source;
        tvPlayModel.threedType = model.threedType;
        
        [playUrlModels addObject:tvPlayModel];
    }
    return playUrlModels;
}

#pragma mark - http tv series

- (void)http_SerieswithCode:(NSString *)code successBlock:(void(^)(WVRTVItemModel *))successBlock failBlock:(void(^)(NSString *))failBlock {
    
    kWeakSelf(self);
    WVRHttpProgramDetail  * cmd = [WVRHttpProgramDetail new];
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[kHttpParams_programDetail_code] = code;
//    params[@"s"] = @"1";//返回部分数据
    
    cmd.bodyParams = params;
    cmd.successedBlock = ^(WVRHttpProgramDetailModel* args) {
        [weakself httpSeriesSuccessBlock:args successBlock:^(WVRTVItemModel *itemModel) {
            successBlock(itemModel);
        }];
    };
    
    cmd.failedBlock = ^(id args) {
        if ([args isKindOfClass:[NSString class]]) {
            failBlock(args);
        }
    };
    [cmd execute];
}

- (void)httpSeriesSuccessBlock:(WVRHttpProgramDetailModel *)args successBlock:(void(^)(WVRTVItemModel *))successBlock {
    
    WVRTVItemModel * itemModel = [WVRTVItemModel new];
    itemModel.code = args.data.code;
    itemModel.parentCode = args.data.parentCode;
    itemModel.name = args.data.displayName;
    itemModel.playCount = args.data.stat.playCount;
    itemModel.intrDesc = args.data.desc;
    itemModel.curEpisode = args.data.curEpisode;
    itemModel.thubImageUrl = args.data.smallPic;
    itemModel.actors = args.data.actors;
    itemModel.area = args.data.area;
    itemModel.year = args.data.year;
    itemModel.director = args.data.director;
    itemModel.duration = args.data.duration;
    itemModel.score = args.data.score;
    if (itemModel.thubImageUrl.length <= 0) {
        itemModel.thubImageUrl = args.data.pics;
    }
    itemModel.playUrlModels = [self parsePlayUrlModel:args.data.medias];
    itemModel.tags_ = [args.data.tags componentsSeparatedByString:@","];
    
    [self parseSerise:args.data.series itemModel:itemModel];
    successBlock(itemModel);
}

- (void)parseSerise:(NSArray<WVRHttpProgramModel*>*)series itemModel:(WVRTVItemModel*)itemModel {
    
    NSMutableArray* seriesModels = [NSMutableArray array];
    for (WVRHttpProgramModel* model in series) {
        WVRTVItemModel * itemModel = [WVRTVItemModel new];
        itemModel.code = model.code;
        itemModel.name = model.displayName;
        itemModel.playCount = model.stat.playCount;
        itemModel.curEpisode = model.curEpisode;
        itemModel.thubImageUrl = model.smallPic;
        itemModel.actors = model.actors;
        itemModel.area = model.area;
        itemModel.year = model.year;
        itemModel.director = model.director;
        itemModel.duration = model.duration;
        itemModel.score = model.score;
        if (itemModel.thubImageUrl.length <= 0) {
            itemModel.thubImageUrl = model.pics;
        }
        itemModel.playUrlModels = [self parsePlayUrlModel:model.medias];
        [seriesModels addObject:itemModel];
    }
    
    itemModel.tvSeries = seriesModels;
}

@end
