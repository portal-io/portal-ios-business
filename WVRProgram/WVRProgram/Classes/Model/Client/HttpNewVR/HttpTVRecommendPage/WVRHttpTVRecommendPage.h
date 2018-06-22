//
//  WVRHttpArrangeElements.h
//  WhaleyVR
//
//  Created by Xie Xiaojian on 2016/10/28.
//  Copyright © 2016年 Snailvr. All rights reserved.
//
#import "WVRNewVRBaseGetRequest.h"
#import "WVRHttpTVRecommendElementsModel.h"

extern NSString * const kHttpParams_TVHaveTV ;


@interface WVRHttpTVRecommendPageModel : WVRNewVRBaseResponse

@property (nonatomic, strong) WVRHttpTVRecommendElementsModel* data;

@end

@interface WVRHttpTVRecommendPage : WVRNewVRBaseGetRequest

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * pageNum;
@property (nonatomic, retain) NSString * pageSize;

@end

