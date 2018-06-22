//
//  WVRSQFindModel.m
//  WhaleyVR
//
//  Created by qbshen on 16/11/14.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRSQFindModel.h"
#import "WVRLiveShowModel.h"
#import "WVRFootballModel.h"

@interface WVRSQFindModel ()

@property (nonatomic) NSMutableDictionary * movieModelDic;

@end


@implementation WVRSQFindModel

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma http movie
- (void)http_recommendPageWithCode:(NSString*)code successBlock:(void(^)(NSDictionary*, NSString*, NSString*))successBlock failBlock:(void(^)(NSString*))failBlock {
    
    kWeakSelf(self);
    WVRHtttpRecommendPage  * cmd = [WVRHtttpRecommendPage new];
    cmd.code = code;    // kHttpParams_RecommendPage_code_movie;
//    if (self.haveTV) {
        NSMutableDictionary * params = [NSMutableDictionary dictionary];
        params[kHttpParams_HaveTV] = @"1";
        cmd.bodyParams = params;
//    }
    cmd.successedBlock = ^(WVRHttpRecommendPageDetailParentModel* args) {
        [weakself httpSuccessBlock:args successBlock:^(NSDictionary *args, NSString* name, NSString* pageName) {
            successBlock(args, name, pageName);
        }];
    };
    
    cmd.failedBlock = ^(id args) {
        if ([args isKindOfClass:[NSString class]]) {
            failBlock(args);
        }
    };
    [cmd execute];
}

- (void)httpSuccessBlock:(WVRHttpRecommendPageDetailParentModel* )args successBlock:(void(^)(NSDictionary *, NSString *, NSString *))successBlock {
    
    self.movieModelDic = [NSMutableDictionary dictionary];
    NSArray * recommendAreas = [[args data] recommendAreas];
    for (WVRHttpRecommendArea* recommendArea in recommendAreas) {
        WVRSectionModel * sectionModel = [self parseSectionHttpModel:recommendArea];
        self.movieModelDic[ @([recommendAreas indexOfObject:recommendArea]) ] = sectionModel;
    }
    successBlock(self.movieModelDic, [[recommendAreas firstObject] name], args.data.name);
}

- (WVRSectionModel *)parseSectionHttpModel:(WVRHttpRecommendArea *)recommendArea {
    
    WVRSectionModel* sectionModel = [WVRSectionModel new];
    WVRSectionModelType sectionType = [sectionModel parseSectionTypeWithHttpRecAreaType:recommendArea.type];
    sectionModel.sectionType = sectionType;
    
    if (sectionType == WVRSectionModelTypeTag) {
        sectionModel.itemModels = [self parseTagHttpRecommendArea:recommendArea];
    } else if (sectionType == WVRSectionModelTypeHot ) {//后台填写hot和tag类型的元素都是文本格式的，这儿要兼容这个两个（实际应该填图片格式的）
        sectionModel.itemModels = [self parseHotHttpRecommendArea:recommendArea sectionModel:sectionModel];
    } else {
        sectionModel.itemModels = [self parseDefaultHttpRecommendArea:recommendArea sectionModel:sectionModel];
    }
    return sectionModel;
}

- (NSMutableArray*)parseTagHttpRecommendArea:(WVRHttpRecommendArea *)recommendArea {
    
    NSMutableArray * models = [NSMutableArray array];
    for (WVRHttpRecommendElement* element in [recommendArea recommendElements]) {
        WVRItemModel * model = [self parseHttpPngElement:element];
        if (model) {
            [models addObject:model];
        }
    }
    return models;
}

- (NSMutableArray*)parseHotHttpRecommendArea:(WVRHttpRecommendArea*)recommendArea sectionModel:(WVRSectionModel*)sectionModel {
    
    NSMutableArray * models = [NSMutableArray array];
    WVRHttpRecommendElement* element = [[recommendArea recommendElements] firstObject];
    if (element) {
        [self parseHttpTextElement:element recommendArea:recommendArea sectionModel:sectionModel];
    }
    for (WVRHttpRecommendElement* element in [recommendArea recommendElements]) {
        
        WVRItemModel * model = [self parseHttpPngElement:element];
        if (model) {
            [models addObject:model];
        }
    }
    return models;
}

- (NSMutableArray *)parseDefaultHttpRecommendArea:(WVRHttpRecommendArea*)recommendArea sectionModel:(WVRSectionModel *)sectionModel {
    
    NSMutableArray * models = [NSMutableArray array];
    for (WVRHttpRecommendElement* element in [recommendArea recommendElements]) {
        if ([element.type isEqualToString:@"1"]) {//是文本格式（头或尾）后台管理需要对应填入相应类型
            [self parseHttpTextElement:element recommendArea:recommendArea sectionModel:sectionModel];
        } else {
            WVRItemModel * model = [self parseHttpPngElement:element];
            if (model) {
                [models addObject:model];
            }
        }
    }
    return models;
}

- (void)parseHttpTextElement:(WVRHttpRecommendElement* )element recommendArea:(WVRHttpRecommendArea*)recommendArea sectionModel:(WVRSectionModel* )sectionModel {
    
    if (element == [[recommendArea recommendElements] firstObject]) {
        [self parseHttpTextHeader:element recommendArea:recommendArea sectionModel:sectionModel];
    }
    if (element == [[recommendArea recommendElements] lastObject]) {
        if (element.linkArrangeValue.length > 0) {
            WVRSectionModel* footModel = [self parseHttpTextFooter:element recommendArea:recommendArea sectionModel:sectionModel];
            sectionModel.footerModel = footModel;
        }
    }
}

- (void)parseHttpTextHeader:(WVRHttpRecommendElement* )element recommendArea:(WVRHttpRecommendArea*)recommendArea sectionModel:(WVRSectionModel* )sectionModel {
    
    sectionModel.recommendAreaCode = [element.recommendAreaCodes firstObject];
    
    sectionModel.name = element.name;
    sectionModel.subTitle = element.subtitle;
    sectionModel.linkArrangeValue = element.linkArrangeValue;
    sectionModel.linkArrangeType = element.linkArrangeType;
    sectionModel.videoType = element.videoType;
    sectionModel.type = sectionModel.type;
    sectionModel.thubImageUrl = element.picUrlNew;
    sectionModel.recommendPageType = element.recommendPageType;
    sectionModel.recommendAreaCodes = element.recommendAreaCodes;
}

- (WVRSectionModel*)parseHttpTextFooter:(WVRHttpRecommendElement* )element recommendArea:(WVRHttpRecommendArea*)recommendArea sectionModel:(WVRSectionModel* )sectionModel {
    
    WVRSectionModel * footerModel = [WVRSectionModel new];
    footerModel.recommendAreaCode = [element.recommendAreaCodes firstObject];
    footerModel.name = element.name;
    footerModel.subTitle = element.subtitle;
    footerModel.linkArrangeValue = element.linkArrangeValue;
    footerModel.linkArrangeType = element.linkArrangeType;
    footerModel.videoType = element.videoType;
    footerModel.type = sectionModel.type;
    footerModel.thubImageUrl = element.picUrlNew;
    footerModel.recommendPageType = element.recommendPageType;
    footerModel.recommendAreaCodes = element.recommendAreaCodes;
    return footerModel;
}

- (WVRItemModel*)parseHttpPngElement:(WVRHttpRecommendElement* )element {
    
    WVRItemModel *itemModel = nil;
    if ([element.linkArrangeType isEqualToString:LINKARRANGETYPE_LIVE]) {
        WVRSQLiveItemModel * curLiveModel = [WVRSQLiveItemModel new];
        curLiveModel.liveStatus = element.liveStatus;
        
        curLiveModel.liveOrderCount = element.liveOrderCount;
        curLiveModel.startDateFormat = element.liveBeginTime;
        curLiveModel.displayMode = [element.displayMode integerValue];
        itemModel= curLiveModel;
    } else if ([element.linkArrangeType isEqualToString:LINKARRANGETYPE_SHOW]) {
        WVRLiveShowModel * curLiveModel = [WVRLiveShowModel new];
        curLiveModel.liveStatus = element.liveStatus;
        
        curLiveModel.roomId = element.linkArrangeValue;
        curLiveModel.liveOrderCount = element.liveOrderCount;
        curLiveModel.startDateFormat = element.liveBeginTime;
        itemModel= curLiveModel;
    } else
    {
        itemModel = [WVRItemModel new];
    }
    itemModel.playUrl = element.videoUrl;
    itemModel.code = element.code;
    itemModel.name = element.name;
    itemModel.subTitle = element.subtitle;
    itemModel.thubImageUrl = element.picUrlNew;
    itemModel.intrDesc = element.introduction;
    itemModel.linkArrangeValue = element.linkArrangeValue;
    itemModel.linkArrangeType = element.linkArrangeType;
    itemModel.unitConut = element.detailCount;
    itemModel.logoImageUrl = element.logoImageUrl;
    itemModel.infUrl = element.infUrl;
    itemModel.infTitle = element.infTitle;
    itemModel.price = element.price;
    itemModel.isChargeable = element.isChargeable;
    itemModel.recommendPageType = element.recommendPageType;
    itemModel.videoType = element.videoType;
    itemModel.programType = element.programType;
    itemModel.recommendAreaCodes = element.recommendAreaCodes;
    itemModel.arrangeShowFlag = element.arrangeShowFlag;
    itemModel.duration = element.duration;
    itemModel.behavior = element.behavior;
    
    itemModel.renderType = element.renderType;
    
    itemModel.srcDisplayName = element.statQueryDto.srcDisplayName;
    if (itemModel.duration.length == 0) {
        itemModel.duration = element.programPlayTime;
    }
    itemModel.type = element.type;
    
    itemModel.playCount = element.statQueryDto.playCount;

    NSMutableArray * array = [NSMutableArray new];
    
    for (WVRHttpArrangeElement * cur in element.arrangeElements) {
        WVRItemModel* curModel = [WVRItemModel new];
        curModel.name = cur.itemName;
        curModel.thubImageUrl = cur.picUrl;
        curModel.playUrl = cur.videoUrl;
        curModel.downloadUrl = cur.downloadUrl;
        curModel.subTitle = cur.subtitle;
        curModel.linkArrangeValue = cur.linkId;
        curModel.linkArrangeType = cur.linkType;
        curModel.duration = cur.duration;
        curModel.programType = cur.programType;
        curModel.playCount = cur.statQueryDto.playCount;
        curModel.renderType = cur.renderType;
        [array addObject:curModel];
    }
    itemModel.arrangeElements = array;
    
    return itemModel;
}

@end
