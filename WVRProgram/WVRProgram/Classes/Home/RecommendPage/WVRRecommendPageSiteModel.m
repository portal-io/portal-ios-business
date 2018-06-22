//
//  WVRRecommendPageSiteModel.m
//  WhaleyVR
//
//  Created by qbshen on 2017/1/3.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRRecommendPageSiteModel.h"
#import "WVRHtttpRecommendPage.h"
#import "WVRVideoModel.h"
#import "WVRHttpArrangeElements.h"


@interface WVRRecommendPageSiteModel ()


@property (nonatomic) NSMutableDictionary * sectionModelDic;
@end

@implementation WVRRecommendPageSiteModel
-(instancetype)init
{
    self = [super init];
    if (self) {
        self.sectionModelDic = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma http movie

-(void)http_recommendPageWithCode:(NSString*)code successBlock:(void(^)(NSDictionary*, NSString* ))successBlock failBlock:(void(^)(NSString*))failBlock
{
    WVRHtttpRecommendPage  * cmd = [WVRHtttpRecommendPage new];
    cmd.code = code;//@"recommend_title";
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[kHttpParams_HaveTV] = @"1";
    cmd.bodyParams = params;
    cmd.successedBlock = ^(WVRHttpRecommendPageDetailParentModel* args){
        [self httpSuccessBlock:args successBlock:^(NSDictionary *args,NSString*  name) {
            successBlock(args, name);
        }];
    };
    
    cmd.failedBlock = ^(id args){
        if ([args isKindOfClass:[NSString class]]) {
            failBlock(args);
        }
    };
    [cmd execute];
}


-(void)httpSuccessBlock:(WVRHttpRecommendPageDetailParentModel* )args successBlock:(void(^)(NSDictionary*, NSString* ))successBlock
{
    NSArray * recommendAreas = [[args data] recommendAreas];
    for (WVRHttpRecommendArea* recommendArea in recommendAreas) {
        [self parseSectionHttpModel:recommendArea];
    }
    successBlock(self.sectionModelDic, [[recommendAreas firstObject] name]);
}

-(void)parseSectionHttpModel:(WVRHttpRecommendArea*)recommendArea
{
    for (WVRHttpRecommendElement* element in [recommendArea recommendElements]) {
        NSInteger index = [[recommendArea recommendElements] indexOfObject:element];
        WVRSectionModel* sectionModel = self.sectionModelDic[@(index)];
        if (!sectionModel) {
            sectionModel = [WVRSectionModel new];
        }
        sectionModel.code = element.code;
        sectionModel.name = element.name;
        sectionModel.linkArrangeValue = element.linkArrangeValue;
        sectionModel.linkArrangeType = element.linkArrangeType;
        sectionModel.sectionType = [sectionModel parseSectionTypeWithHttpRecAreaType:element.type];
        sectionModel.videoType = element.videoType;
        sectionModel.recommendPageType = element.recommendPageType;
        self.sectionModelDic[@(index)] = sectionModel;
    }
}

- (WVRSectionModelType)parseSectionTypeWithHttpRecAreaType:(NSString*)areaType
{
    WVRSectionModelType type = WVRSectionModelTypeDefault;
    if ([areaType isEqualToString:@"1"]) {
        type = WVRSectionModelTypeDefault;
    }else if ([areaType isEqualToString:@"2"]){
        type = WVRSectionModelTypeBanner;
    }else if ([areaType isEqualToString:@"3"]){
        type = WVRSectionModelTypeAD;
    }else if ([areaType isEqualToString:@"4"]){
        type = WVRSectionModelTypeBrand;
    }else if ([areaType isEqualToString:@"5"]){
        type = WVRSectionModelTypeHot;
    }else if ([areaType isEqualToString:@"6"]){
        type = WVRSectionModelTypeTag;
    }
    return type;
}

#pragma http movie
-(void)http_recommendPageDetail:(WVRSectionModel*)sectionModel successBlock:(void(^)(NSDictionary*))successBlock failBlock:(void(^)(NSString*))failBlock
{
    WVRHttpArrangeElements  * cmd = [WVRHttpArrangeElements new];
    cmd.treeNodeCode = sectionModel.linkArrangeValue;
    cmd.pageNum = SQStrWithNSInteger(sectionModel.pageNum = 0);
    cmd.pageSize = SQStrWithNSInteger(sectionModel.pageSize = 18);
    cmd.successedBlock = ^(WVRHttpArrangePageModel* args){
        [self httpPageDetailSuccessBlock:args successBlock:^(NSDictionary *args) {
            successBlock(args);
        } sectionModel:sectionModel];
    };
    
    cmd.failedBlock = ^(id args){
        if ([args isKindOfClass:[NSString class]]) {
            failBlock(args);
        }
    };
    [cmd execute];
}

-(void)httpPageDetailSuccessBlock:(WVRHttpArrangePageModel* )args successBlock:(void(^)(NSDictionary*))successBlock sectionModel:(WVRSectionModel*)sectionModel
{
    sectionModel.itemModels = [self httpParseItemModels:args sectionModel:sectionModel];;
    successBlock(self.sectionModelDic);
}


#pragma http movie
-(void)http_recommendPageDetailMore:(WVRSectionModel*)sectionModel successBlock:(void(^)(NSDictionary*))successBlock failBlock:(void(^)(NSString*))failBlock
{
    WVRHttpArrangeElements  * cmd = [WVRHttpArrangeElements new];
    cmd.treeNodeCode = sectionModel.linkArrangeValue;
    cmd.pageNum = SQStrWithNSInteger(++sectionModel.pageNum);
    cmd.pageSize = SQStrWithNSInteger(sectionModel.pageSize); //[NSString stringWithFormat:@"%d",++ (sectionModel.pageSize)];
    cmd.successedBlock = ^(WVRHttpArrangePageModel* args){
        [self httpPageDetailMoreSuccessBlock:args successBlock:^(NSDictionary *args) {
            successBlock(args);
        } sectionModel:sectionModel];
    };
    
    cmd.failedBlock = ^(id args){
        if ([args isKindOfClass:[NSString class]]) {
            failBlock(args);
        }
    };
    [cmd execute];
}

-(void)httpPageDetailMoreSuccessBlock:(WVRHttpArrangePageModel* )args successBlock:(void(^)(NSDictionary*))successBlock sectionModel:(WVRSectionModel*)sectionModel
{
    
    [sectionModel.itemModels addObjectsFromArray:[self httpParseItemModels:args sectionModel:sectionModel]];
    successBlock(self.sectionModelDic);
}

- (NSMutableArray<WVRItemModel*>*)httpParseItemModels:(WVRHttpArrangePageModel* )args sectionModel:(WVRSectionModel*)sectionModel
{
    sectionModel.totalPages = [[[args data] totalPages] integerValue];
    NSArray * recommendAreas = [[args data] content];
    NSMutableArray * itemModels = [NSMutableArray array];
    for (WVRHttpArrangeElementModel * model in recommendAreas) {
        WVRItemModel * itemModel = [WVRItemModel new];
        itemModel.name = model.name;
        itemModel.code = model.code;
        itemModel.thubImageUrl = model.picUrl;
        itemModel.intrDesc = model.subtitle;
        itemModel.subTitle = model.subtitle;
        itemModel.linkArrangeType = model.linkType;
        itemModel.linkArrangeValue = model.linkId;
        itemModel.videoType = model.videoType;
        itemModel.programType = model.programType;
        if (!itemModel.name) {
            itemModel.name = model.itemName;
        }
        [itemModels addObject:itemModel];
    }
    return itemModels;
}

@end
