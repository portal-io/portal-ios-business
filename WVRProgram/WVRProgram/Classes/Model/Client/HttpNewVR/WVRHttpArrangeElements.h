//
//  WVRHttpArrangeElements.h
//  WhaleyVR
//
//  Created by Xie Xiaojian on 2016/10/28.
//  Copyright © 2016年 Snailvr. All rights reserved.
//
#import "WVRNewVRBaseGetRequest.h"
#import "WVRHttpArrangeElementsPageModel.h"


@interface WVRHttpArrangePageModel : WVRNewVRBaseResponse

@property (nonatomic, strong) WVRHttpArrangeElementsPageModel* data;

@end


@interface WVRHttpArrangeElements : WVRNewVRBaseGetRequest

@property (nonatomic, copy) NSString * treeNodeCode;
@property (nonatomic, copy) NSString * pageNum;
@property (nonatomic, copy) NSString * pageSize;

@end

