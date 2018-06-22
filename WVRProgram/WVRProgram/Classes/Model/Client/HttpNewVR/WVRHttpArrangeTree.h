//
//  WVRHttpArrangeTree.h
//  WhaleyVR
//
//  Created by Xie Xiaojian on 2016/10/28.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRNewVRBaseGetRequest.h"
#import "WVRHttpArrangeTreeModel.h"

@interface WVRHttpArrangeTreeDetailModel : WVRNewVRBaseResponse

@property (nonatomic) WVRHttpArrangeTreeModel * data;

@end


@interface WVRHttpArrangeTree : WVRNewVRBaseGetRequest

@property (nonatomic) NSString * arrangeCode;

@end
