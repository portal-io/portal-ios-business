//
//  WVRPostRequest.h
//  VRManager
//
//  Created by Wang Tiger on 16/6/20.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRNewVRBasePostRequest.h"
//#import "WVRHttpUserModel.h"
#import "WVRHttpArrangeModel.h"

extern NSString * const kHttpParams_statistic_id ;
extern NSString * const kHttpParams_statistic_ip ;
extern NSString * const kHttpParams_statistic_model ;
extern NSString * const kHttpParams_statistic_type ;


@interface WVRHttpStatisticModel : WVRNewVRBaseResponse

@end


@interface WVRHttpStatistic : WVRNewVRBasePostRequest

@end
