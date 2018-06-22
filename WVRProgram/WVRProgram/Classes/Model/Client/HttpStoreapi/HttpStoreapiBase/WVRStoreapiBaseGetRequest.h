//
//  WVRWAccountPostRequest.h
//  WhaleyVR
//
//  Created by qbshen on 16/10/19.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRGetRequest.h"
#import "WVRUserModel.h"
#import "WVRStoreapiBaseResponse.h"


#define HTTP_FROM_WHALEYVR (@"whaleyVR")

@interface WVRStoreapiBaseGetRequest : WVRGetRequest

- (NSString *)dictionaryToJson:(NSDictionary *)dic;

@end
