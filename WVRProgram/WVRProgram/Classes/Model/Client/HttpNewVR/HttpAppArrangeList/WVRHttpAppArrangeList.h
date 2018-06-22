//
//  WVRPostRequest.h
//  VRManager
//
//  Created by Wang Tiger on 16/6/20.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRNewVRBaseGetRequest.h"
//#import "WVRHttpUserModel.h"
#import "WVRHttpArrangeModel.h"


@interface WVRHttpAppArrangeList : WVRNewVRBaseGetRequest

@end


@interface WVRHttpAppArrangeListModel : WVRNewVRBaseResponse

@property (nonatomic) NSArray<WVRHttpArrangeModel *>* data;

@end
