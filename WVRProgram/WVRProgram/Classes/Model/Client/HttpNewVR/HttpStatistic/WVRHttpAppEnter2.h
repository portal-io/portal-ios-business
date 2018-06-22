//
//  WVRHttpAppEnter.h
//  WhaleyVR
//
//  Created by Xie Xiaojian on 2016/11/22.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WVRNewVRBasePostRequest.h"

extern NSString * const kHttpParams_enter2_content;

extern NSString * const cKey2;
@interface WVRHttpAppEnter2 : WVRNewVRBasePostRequest

@end

@interface WVRHttpAppEnter2Model : WVRNewVRBaseResponse
@property (nonatomic) NSString* time;
@end
