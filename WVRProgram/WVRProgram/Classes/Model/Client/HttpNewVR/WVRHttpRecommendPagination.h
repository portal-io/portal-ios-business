//
//  WVRHttpArrangeElements.h
//  WhaleyVR
//
//  Created by Xie Xiaojian on 2016/10/28.
//  Copyright © 2016年 Snailvr. All rights reserved.
//
#import "WVRNewVRBaseGetRequest.h"
#import "WVRHttpRecommendPageDetailModel.h"

extern NSString * const kAppTypeRecommendPage;
extern NSString * const kBusiVersionRecommendPage;


@interface WVRHttpRecommendPaginationContentModel : WVRNewVRBaseResponse

@property (nonatomic) NSString * number;
@property (nonatomic) NSString * numberOfElements;
@property (nonatomic) NSString * totalPages;
@property (nonatomic) NSString * size;
@property (nonatomic) NSString * last;
@property (nonatomic) NSString * totalElements;
@property (nonatomic) NSString * first;
@property (nonatomic) NSArray<WVRHttpRecommendElement *>* content;

@end


@interface WVRHttpRecommendPaginationModel : WVRNewVRBaseResponse

@property (nonatomic) WVRHttpRecommendPaginationContentModel* data;

@end


@interface WVRHttpRecommendPagination : WVRNewVRBaseGetRequest

@property (nonatomic) NSString * code;
@property (nonatomic) NSString * subCode;
@property (nonatomic) NSString * pageNum;
@property (nonatomic) NSString * pageSize;

@end

