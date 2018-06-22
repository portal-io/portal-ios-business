//
//  WVRSQDefaultFindMoreModel.m
//  WhaleyVR
//
//  Created by qbshen on 16/11/15.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRAutoArrangeModel.h"
#import "WVRHttpArrangeElements.h"
#import "WVRHttpTVRecommendPage.h"

@interface WVRAutoArrangeModel ()



@end

@implementation WVRAutoArrangeModel

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.modelDic = [NSMutableDictionary dictionary];
        self.sectionModel = [WVRSectionModel new];
        self.sectionModel.pageSize = 18;
        self.sectionModel.pageNum = 0;
    }
    return self;
}

#pragma http movie
-(void)http_recommendPage:(NSString*)code successBlock:(void(^)(NSDictionary*))successBlock failBlock:(void(^)(NSString*))failBlock
{
    WVRHttpArrangeElements  * cmd = [WVRHttpArrangeElements new];
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[@"code"] = code;
    params[@"page"] = [NSString stringWithFormat:@"%ld", (long)(self.sectionModel.pageNum=0)];
    params[@"size"] = [NSString stringWithFormat:@"%ld", (long)self.sectionModel.pageSize];
    params[@"v"] = @"1";
    cmd.bodyParams = params;
    cmd.successedBlock = ^(WVRHttpArrangePageModel* args) {
        [self httpSuccessBlock:args successBlock:^(NSDictionary *args) {
            successBlock(args);
        } isMore:NO];
    };
    
    cmd.failedBlock = ^(id args) {
        if ([args isKindOfClass:[NSString class]]) {
            failBlock(args);
        }
    };
    [cmd execute];
}

#pragma http movie
-(void)http_recommendPageMore:(NSString*)code successBlock:(void(^)(NSDictionary*))successBlock failBlock:(void(^)(NSString*))failBlock
{
    WVRHttpArrangeElements  * cmd = [WVRHttpArrangeElements new];
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[@"code"] = code;
    params[@"page"] = [NSString stringWithFormat:@"%ld", ++ self.sectionModel.pageNum];
    params[@"size"] = [NSString stringWithFormat:@"%ld", (long)self.sectionModel.pageSize];
    params[@"v"] = @"1";
    cmd.bodyParams = params;
    
    cmd.successedBlock = ^(WVRHttpArrangePageModel* args){
        [self httpSuccessBlock:args successBlock:^(NSDictionary *args) {
            successBlock(args);
        } isMore:YES];
    };
    
    cmd.failedBlock = ^(id args){
        if ([args isKindOfClass:[NSString class]]) {
            failBlock(args);
        }
    };
    [cmd execute];
}


- (void)httpSuccessBlock:(WVRHttpArrangePageModel* )args successBlock:(void(^)(NSDictionary*))successBlock isMore:(BOOL)isMore
{
    self.sectionModel.totalPages = [[[args data] totalPages] integerValue];
    NSMutableArray * itemModels = [NSMutableArray array];
    for (WVRHttpArrangeElementModel* elementModel in [[args data] content]) {
        WVRItemModel * itemModel = [WVRItemModel new];
        itemModel.name = elementModel.itemName;
        itemModel.code = elementModel.code;
        itemModel.linkArrangeType = elementModel.linkType;
        itemModel.linkArrangeValue = elementModel.linkId;
        itemModel.thubImageUrl = elementModel.picUrl;
        itemModel.subTitle = elementModel.subtitle;
        itemModel.isChargeable = elementModel.isChargeable;
        itemModel.videoType = elementModel.videoType;
        itemModel.programType = elementModel.programType;
        [itemModels addObject:itemModel];
    }
    if (isMore) {
        if (!self.sectionModel.itemModels) {
            self.sectionModel.itemModels = [NSMutableArray array];
        }
        [self.sectionModel.itemModels addObjectsFromArray:itemModels];
    }else{
        self.sectionModel.itemModels = itemModels;
    }
    self.modelDic[@(0)] = self.sectionModel;
    successBlock(self.modelDic);
}

#pragma http TV
- (void)http_recommendTVPage:(NSString*)code successBlock:(void(^)(NSDictionary*))successBlock failBlock:(void(^)(NSString*))failBlock
{
    WVRHttpTVRecommendPage  * cmd = [WVRHttpTVRecommendPage new];
    
    NSArray * codes = [code componentsSeparatedByString:@"-"];
    cmd.code = [[[@"" stringByAppendingString:[codes firstObject]] stringByAppendingString:@"/"] stringByAppendingString:[codes lastObject]];
    cmd.pageNum = [NSString stringWithFormat:@"/%ld",(long)(self.sectionModel.pageNum=0)];
    cmd.pageSize = [NSString stringWithFormat:@"/%ld",(long)self.sectionModel.pageSize];
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[@"v"] = @"1";
    cmd.bodyParams = params;
    cmd.successedBlock = ^(WVRHttpTVRecommendPageModel* args){
        [self httpTVSuccessBlock:args successBlock:^(NSDictionary *args) {
            successBlock(args);
        } isMore:NO];
    };
    
    cmd.failedBlock = ^(id args){
        if ([args isKindOfClass:[NSString class]]) {
            failBlock(args);
        }
    };
    [cmd execute];
}

#pragma http TV
-(void)http_recommendTVPageMore:(NSString*)code successBlock:(void(^)(NSDictionary*))successBlock failBlock:(void(^)(NSString*))failBlock
{
    WVRHttpTVRecommendPage  * cmd = [WVRHttpTVRecommendPage new];
    NSArray * codes = [code componentsSeparatedByString:@"-"];
    cmd.code = [[[@"" stringByAppendingString:[codes firstObject]] stringByAppendingString:@"/"] stringByAppendingString:[codes lastObject]];
    cmd.pageSize = [NSString stringWithFormat:@"/%ld", ++ self.sectionModel.pageNum];
    cmd.pageNum = [NSString stringWithFormat:@"/%ld", (long)self.sectionModel.pageSize];
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[@"v"] = @"1";
    cmd.bodyParams = params;
    cmd.successedBlock = ^(WVRHttpTVRecommendPageModel* args) {
        [self httpTVSuccessBlock:args successBlock:^(NSDictionary *args) {
            successBlock(args);
        } isMore:YES];
    };
    
    cmd.failedBlock = ^(id args){
        if ([args isKindOfClass:[NSString class]]) {
            failBlock(args);
        }
    };
    [cmd execute];
}

-(void)httpTVSuccessBlock:(WVRHttpTVRecommendPageModel* )args successBlock:(void(^)(NSDictionary*))successBlock isMore:(BOOL)isMore
{
    self.sectionModel.totalPages = [[[args data] totalPages] integerValue];
    NSMutableArray * itemModels = [NSMutableArray array];
    for (WVRHttpTVElementModel* elementModel in [[args data] content]) {
        WVRItemModel * itemModel = [WVRItemModel new];
        itemModel.name = elementModel.itemName;
        itemModel.code = elementModel.code;
        itemModel.linkArrangeType = elementModel.linkArrangeType;
        itemModel.linkArrangeValue = elementModel.linkArrangeValue;
        itemModel.thubImageUrl = elementModel.picUrl;
        itemModel.subTitle = elementModel.subtitle;
        itemModel.isChargeable = elementModel.isChargeable;
        itemModel.videoType = elementModel.videoType;
        itemModel.programType = elementModel.programType;
        [itemModels addObject:itemModel];
    }
    if (isMore) {
        if (!self.sectionModel.itemModels) {
            self.sectionModel.itemModels = [NSMutableArray array];
        }
        [self.sectionModel.itemModels addObjectsFromArray:itemModels];
    }else{
        self.sectionModel.itemModels = itemModels;
    }
    self.modelDic[@(0)] = self.sectionModel;
    successBlock(self.modelDic);
}

@end
