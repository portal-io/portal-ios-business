//
//  WVRWAccountPostRequest.h
//  WhaleyVR
//
//  Created by qbshen on 16/10/19.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRPostRequest.h"
#import "WVRUserModel.h"
#import "WVRNewVRBaseResponse.h"


#define HTTP_FROM_WHALEYVR (@"whaleyVR")

@interface WVRNewVRBasePostRequest : WVRPostRequest
- (NSString*)dictionaryToJson:(NSDictionary *)dic;
@end
