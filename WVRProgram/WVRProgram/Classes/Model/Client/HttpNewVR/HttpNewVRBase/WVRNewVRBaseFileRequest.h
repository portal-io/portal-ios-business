//
//  WVRPostRequest.h
//  VRManager
//
//  Created by Wang Tiger on 16/6/15.
//  Copyright © 2016年 Snailvr. All rights reserved.
//
#import "WVRBaseFileRequest.h"

@interface WVRNewVRBaseFileRequest : WVRBaseFileRequest
- (NSString*)dictionaryToJson:(NSDictionary *)dic;
@end
