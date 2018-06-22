//
//  WVRHttpStatUpdate.h
//  WhaleyVR
//
//  Created by Xie Xiaojian on 2016/10/31.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRNewVRBasePostRequest.h"
#import "WVRHttpStatUpdateModel.h"

extern NSString * const kHttpParams_programDetail_srcCode;
extern NSString * const kHttpParams_programDetail_contentType;
extern NSString * const kHttpParams_programDetail_type;
extern NSString * const kHttpParams_programDetail_sec;

@interface WVRHttpStatUpdateParentModel : WVRNewVRBaseResponse

@property (nonatomic) WVRHttpStatUpdateModel* data;

@end


@interface WVRHttpStatUpdate : WVRNewVRBasePostRequest

@end
