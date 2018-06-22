//
//  WVRHttpAppEnter.h
//  WhaleyVR
//
//  Created by Xie Xiaojian on 2016/11/22.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WVRNewVRBasePostRequest.h"

extern NSString * const kHttpParams_enter_content;
extern NSString * const cKey;

@interface WVRHttpAppEnter : WVRNewVRBasePostRequest

@end


@interface WVRHttpAppEnterModel : WVRNewVRBaseResponse

@property (nonatomic) NSString* time;

@end
