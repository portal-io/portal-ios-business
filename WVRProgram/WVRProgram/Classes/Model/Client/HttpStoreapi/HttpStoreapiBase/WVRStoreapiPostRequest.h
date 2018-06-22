//
//  WVRWAccountPostRequest.h
//  WhaleyVR
//
//  Created by qbshen on 16/10/19.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRPostRequest.h"
#import "WVRUserModel.h"
#import "WVRStoreapiBaseResponse.h"


static NSString * const SUCCESS_CODE_STOREAPI = @"000";
static NSString * const SUCCESS_ACCESSTOKEN_EXPIRE_STOREAPI = @"152";
static NSString * const SUCCESS_NEED_BIND_ACCOUNT_STOREAPI = @"144";
static NSString * const SUCCESS_NEED_CAPTCHA_STOREAPI = @"141";
static NSString * const SUCCESS_CODE_ERROR_STOREAPI = @"104";
static NSString * const SUCCESS_CHANGE_PW_OLDPW_ERROR_STOREAPI = @"148";
static NSString * const SUCCESS_CODE_FINDPW_ERROR_STOREAPI = @"106";
static NSString * const SUCCESS_CODE_FINDPW_ERROR_MSG_STOREAPI = @"该账号不存在";

static NSString * const SUCCESS_CODE_CAPTCHA_ERROR_STOREAPI = @"101";
static NSString * const SUCCESS_CODE_CAPTCHA_ERROR_MSG_STOREAPI = @"图形验证码验证失败";
static NSString * const SUCCESS_CODE_ERROR_MSG_STOREAPI = @"安全码错误";


#define HTTP_FROM_WHALEYVR (@"whaleyVR")

@class WVRHttpUserModel;

@interface WVRStoreapiPostRequest : WVRPostRequest

- (NSString*)dictionaryToJson:(NSDictionary *)dic;

//-(void)updateUserDefaultInfo:(WVRHttpUserModel*)resSuccess;

@end
