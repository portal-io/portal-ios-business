//
//  WVRWAccountPostRequest.h
//  WhaleyVR
//
//  Created by qbshen on 16/10/19.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRPostRequest.h"
#import "WVRNewVRBaseStatusResponse.h"
#import "WVRHttpSessionManager.h"
//#import "WVRHttpRefreshToken.h"

#import "WVRUserModel.h"
#import "WVRNewVRCodeHead.h"


#define HTTP_FROM_WHALEYVR (@"whaleyVR")

@interface WVRNewVRBasePostStatusRequest : WVRPostRequest

- (NSString *)dictionaryToJson:(NSDictionary *)dic;

@end
