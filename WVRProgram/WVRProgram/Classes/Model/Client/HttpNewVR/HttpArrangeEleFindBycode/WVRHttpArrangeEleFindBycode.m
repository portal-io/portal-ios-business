//
//  WVRHttpArrangeElements.m
//  WhaleyVR
//
//  Created by Xie Xiaojian on 2016/10/28.
//  Copyright © 2016年 Snailvr. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "WVRHttpArrangeEleFindBycode.h"
#import "WVRSectionModel.h"

static NSString *kActionUrl = @"newVR-service/appservice/arrangeTree/findTreeNodeCode/%@";

@implementation WVRHttpArrangeEleFindBycode

/* protocol WVRRequestProtocol method */
- (void)onDataSuccess:(id)dataObject
{
    NSMutableDictionary *result = (NSMutableDictionary*)self.originResponse;
    WVRHttpArrangeEleFindBycodeModel *resSuccess = [WVRHttpArrangeEleFindBycodeModel yy_modelWithDictionary:result];
    self.successedBlock(resSuccess);
}

/* protocol WVRRequestProtocol method */
- (void)onDataFailed:(id)dataObject
{
    NSLog(@"%@ request failed", [self class]);
    self.failedBlock(dataObject);
}

/* WVRBaseRequest method*/
- (NSString *)getActionUrl
{
    return [NSString stringWithFormat:kActionUrl, _treeNodeCode];
}

@end


@implementation WVRHttpArrangeEleFindBycodeModel

- (WVRSectionModel *)convertToSectionModel {
    
    WVRSectionModel * sectionModel = [WVRSectionModel new];
    NSMutableArray * itemModels = [NSMutableArray array];
    NSArray * recommendAreas = [[self data] arrangeTreeElements];
    sectionModel.name = self.data.name;
    sectionModel.linkArrangeValue = self.data.code;
    sectionModel.thubImageUrl = self.data.bigImageUrl;
    sectionModel.subTitle = self.data.introduction;
    
    for (WVRHttpArrangeElementModel* element in recommendAreas) {
        WVRItemModel * model = [WVRItemModel new];
        
        model.code = element.code;
        model.name = element.itemName;
        model.thubImageUrl = element.picUrl;
        model.subTitle = element.subtitle;
        model.linkArrangeType = element.linkType;
        model.linkArrangeValue = element.linkId;
        if (model.code.length == 0) {   //手动编排列表没有code，用linkId表示唯一性
            model.code = model.linkArrangeValue;
        }
        model.playUrl = element.videoUrl;
        model.duration = element.duration;
        model.videoType = element.videoType;
        model.programType = element.programType;
        model.isChargeable = element.isChargeable;
        model.price = element.price;
        model.renderType = element.renderType;
        model.playCount = element.statQueryDto.playCount;
        model.detailCount = element.detailCount;
        model.intrDesc = element.introduction;
        [itemModels addObject:model];
    }
    sectionModel.itemModels = itemModels;
    sectionModel.itemCount = [NSString stringWithFormat:@"%d", (int)itemModels.count];
    
    return sectionModel;
}

@end


@implementation WVRHttpArrangeEleFByCModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{ @"Id" : @"id" };
}

+ (NSDictionary*)modelContainerPropertyGenericClass {
    return @{@"arrangeTreeElements": WVRHttpArrangeElementModel.class};
}

@end
