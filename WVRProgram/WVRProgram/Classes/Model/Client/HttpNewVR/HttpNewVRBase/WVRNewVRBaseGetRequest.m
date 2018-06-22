//
//  WVRWAccountPostRequest.m
//  WhaleyVR
//
//  Created by qbshen on 16/10/19.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRNewVRBaseGetRequest.h"
//#import "WVRApiHttpRefreshToken.h"
#import "WVRNewVRBaseResponse.h"

#import "WVRUserModel.h"
#import "WVRNewVRCodeHead.h"

@implementation WVRNewVRBaseGetRequest

- (void)onRequestSuccess:(id)responesObject {
    
    self.originResponse = responesObject;
    
    [self onDataSuccess:responesObject];
}

#pragma http forgotPW smsCode

- (void)httpRefreshToken {
    
//    WVRApiHttpRefreshToken * cmd = [[WVRApiHttpRefreshToken alloc] init];
//    NSMutableDictionary * httpDic = [[NSMutableDictionary alloc] init];
//    httpDic[refreshToken_refreshtoken] = [WVRUserModel sharedInstance].refreshtoken;
//    httpDic[refreshToken_device_id] = [WVRUserModel sharedInstance].deviceId;
//    httpDic[refreshToken_accesstoken] = [WVRUserModel sharedInstance].sessionId;
//    cmd.bodyParams = httpDic;
//    cmd.successedBlock = ^(id result) {
//        [self httpRefreshTokenSuccessBlock:result];
//    };
//    cmd.failedBlock = ^(NSString *errMsg) {
//        NSLog(@"fail msg: %@",errMsg);
//        
//    };
//    [cmd loadData];
}

- (void)httpRefreshTokenSuccessBlock:(id)result
{
    [self.bodyParams setValue:[WVRUserModel sharedInstance].sessionId forKeyPath:@"accesstoken"];
    [self execute];
}

- (NSString *)dictionaryToJson:(NSDictionary *)dic {
    
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

/* WVRBaseRequest method*/

- (NSString *)getHost
{
    return [WVRUserModel kNewVRBaseURL];
}

- (void)dealloc {
    
    DebugLog(@"");
}

@end
