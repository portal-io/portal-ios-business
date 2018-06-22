//
//  WVRLiveModel.m
//  WhaleyVR
//
//  Created by qbshen on 2016/12/7.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRLiveModel.h"

@implementation WVRLiveModel

-(NSMutableArray*)parseHotHttpRecommendArea:(WVRHttpRecommendArea*)recommendArea sectionModel:(WVRSectionModel*)sectionModel
{
    NSMutableArray *models = [self parseDefaultHttpRecommendArea:recommendArea sectionModel:sectionModel];
    return models;
}


@end
