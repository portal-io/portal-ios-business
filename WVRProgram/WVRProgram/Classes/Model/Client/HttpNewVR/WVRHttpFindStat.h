//
//  WVRHttpFindStat.h
//  WhaleyVR
//
//  Created by Xie Xiaojian on 2016/10/31.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRNewVRBaseGetRequest.h"
#import "WVRHttpFindStatModel.h"

extern NSString * const kHttpParams_findStat_srcCode;

@interface WVRHttpFindStatParentModel : WVRNewVRBaseResponse

@property (nonatomic) WVRHttpFindStatModel* data;

@end


@interface WVRHttpFindStat : WVRNewVRBaseGetRequest

@end
