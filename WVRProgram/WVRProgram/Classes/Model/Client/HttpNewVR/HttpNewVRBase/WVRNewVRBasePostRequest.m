//
//  WVRWAccountPostRequest.m
//  WhaleyVR
//
//  Created by qbshen on 16/10/19.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRNewVRBasePostRequest.h"
//#import "WVRHttpRefreshToken.h"

#import "WVRUserModel.h"
#import "WVRNewVRCodeHead.h"

@implementation WVRNewVRBasePostRequest

- (void)onRequestSuccess:(id)responesObject {
    self.originResponse = responesObject;
    
    [self onDataSuccess:responesObject];
    
//    NSLog(@"\n-------分割线-------\nresponesObject:\n %@\n-------分割线-------\n",responesObject);

//    NSLog(@"\n-------分割线-------\nresponesObject:\n %@\n-------分割线-------\n",[self dictionaryToJson:responesObject]);
//    WVRWAccountBaseResponse *baseResponse = [WVRWAccountBaseResponse yy_modelWithDictionary:result];
//    NSInteger code = baseResponse.code.intValue;
//    if (code == NEWVR_SUCCESS_CODE) {
//        [self onDataSuccess:baseResponse];
//    } else if(code == NEWVR_SUCCESS_ACCESSTOKEN_EXPIRE) {
//        [self httpRefreshToken];
//    } else if(code == NEWVR_SUCCESS_NEED_BIND_ACCOUNT) {
//        [self onDataSuccess:responesObject];
//    } else if(code == NEWVR_SUCCESS_NEED_CAPTCHA) {
//        [self onDataSuccess:responesObject];
//    } else if(code == NEWVR_SUCCESS_CODE_ERROR) {
//        [self onDataFailed:baseResponse.msg];
//    }
//    else {
//        [self onDataFailed:baseResponse.msg];
//    }
}

#pragma mark - http forgotPW smsCode

- (void)httpRefreshToken {
//    WVRHttpRefreshToken * cmd = [[WVRHttpRefreshToken alloc] init];
//    NSMutableDictionary * httpDic = [[NSMutableDictionary alloc] init];
//    httpDic[kHttpParams_refreshToken_refreshtoken] = [WVRUserModel sharedInstance].refreshtoken;
//    httpDic[kHttpParams_refreshToken_device_id] = [WVRUserModel sharedInstance].deviceId;
//    httpDic[kHttpParams_refreshToken_accesstoken] = [WVRUserModel sharedInstance].sessionId;
//    cmd.bodyParams = httpDic;
//    cmd.successedBlock = ^(id result){
//        [self httpRefreshTokenSuccessBlock:result];
//    };
//    cmd.failedBlock = ^(NSString* errMsg){
//        NSLog(@"fail msg: %@",errMsg);
//        
//    };
//    [cmd execute];
}

- (void)httpRefreshTokenSuccessBlock:(id)result {
    
    [self.bodyParams setValue:[WVRUserModel sharedInstance].sessionId forKeyPath:@"accesstoken"];
    
    [self execute];
}


- (NSString *)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    if (!dic) {
        return @"dic is nil";
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

/* WVRBaseRequest method*/
- (NSString *)getHost {
    
    return [WVRUserModel kNewVRBaseURL];
}

- (void)dealloc {
    
    DebugLog(@"");
}

@end
