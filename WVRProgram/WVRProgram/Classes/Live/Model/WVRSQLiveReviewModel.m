//
//  WVRSQLiveReviewModel.m
//  WhaleyVR
//
//  Created by qbshen on 2016/11/21.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRSQLiveReviewModel.h"

@implementation WVRSQLiveReviewModel

- (WVRSectionModel*)parseSectionHttpModel:(WVRHttpRecommendArea *)recommendArea {
    
    WVRSectionModel* sectionModel = [[WVRSectionModel alloc] init];
    WVRSectionModelType sectionType = [sectionModel parseSectionTypeWithHttpRecAreaType:recommendArea.type];
    sectionModel.sectionType = sectionType;
    NSMutableArray * models = [NSMutableArray array];
    for (WVRHttpRecommendElement* element in [recommendArea recommendElements]) {
        if (element == [[recommendArea recommendElements] firstObject]) {
            sectionModel.name = element.name;
            sectionModel.subTitle = element.subtitle;
            sectionModel.linkArrangeValue = element.linkArrangeValue;
            sectionModel.linkArrangeType = element.linkArrangeType;
            sectionModel.videoType = element.videoType;
        }
        
        WVRItemModel *itemModel = [[WVRItemModel alloc] init];
        itemModel.code = element.code;
        itemModel.name = element.name;
        itemModel.thubImageUrl = element.picUrlNew;
        itemModel.intrDesc = element.introduction;
        itemModel.subTitle = element.subtitle;
        itemModel.linkArrangeValue = element.linkArrangeValue;
        itemModel.linkArrangeType = element.linkArrangeType;
        itemModel.unitConut = element.detailCount;
        itemModel.logoImageUrl = element.logoImageUrl;
        itemModel.videoType = element.videoType;
        [models addObject:itemModel];
    }
    
    sectionModel.itemModels = models;
    return sectionModel;
}

@end
