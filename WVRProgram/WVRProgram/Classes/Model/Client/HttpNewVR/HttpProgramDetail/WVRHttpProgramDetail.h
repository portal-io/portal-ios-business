//
//  WVRPostRequest.h
//  VRManager
//
//  Created by Wang Tiger on 16/6/20.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRNewVRBaseGetRequest.h"
#import "WVRHttpProgramModel.h"

extern NSString * const kHttpParams_programDetail_code ;

@interface WVRHttpProgramDetailModel : WVRNewVRBaseResponse

@property (nonatomic) WVRHttpProgramModel * data;

@end


@interface WVRHttpProgramDetail : WVRNewVRBaseGetRequest

@end
