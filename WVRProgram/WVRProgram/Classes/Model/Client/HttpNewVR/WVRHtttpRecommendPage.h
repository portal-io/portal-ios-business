//
//  WVRHttpArrangeElements.h
//  WhaleyVR
//
//  Created by Xie Xiaojian on 2016/10/28.
//  Copyright © 2016年 Snailvr. All rights reserved.
//
#import "WVRNewVRBaseGetRequest.h"
#import "WVRHttpRecommendPageDetailModel.h"

extern NSString * const kHttpParams_RecommendPage_code_movie ;
extern NSString * const kHttpParams_RecommendPage_code_vr;

extern NSString * const kHttpParams_HaveTV ;

@interface WVRHttpRecommendPageDetailParentModel : WVRNewVRBaseResponse

@property (nonatomic) WVRHttpRecommendPageDetailModel* data;

@end


@interface WVRHtttpRecommendPage : WVRNewVRBaseGetRequest

@property (nonatomic, retain) NSString * code;

@end

