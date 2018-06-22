//
//  WVRWAccountPostRequest.m
//  WhaleyVR
//
//  Created by qbshen on 16/10/19.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRStoreapiPostRequest.h"
//#import "WVRHttpRefreshToken.h"

#import "WVRUserModel.h"
#import "SQDateTool.h"
#import "AFHTTPSessionManager.h"
#import "WVRRequestOptManager.h"

@implementation WVRStoreapiPostRequest

- (void)onRequestSuccess:(id)responesObject
{
//    NSDictionary *result = (NSMutableDictionary*)responesObject;
//    self.originResponse = responesObject;
////    NSLog(@"\n-------分割线-------\nresponesObject:\n %@\n-------分割线-------\n", [self dictionaryToJson:responesObject]);
//    WVRWAccountBaseResponse *baseResponse = [WVRWAccountBaseResponse yy_modelWithDictionary:result];
//    NSInteger status = baseResponse.status;
//    if (status == 1) {
//        [self onDataSuccess:baseResponse];
//    } else {
//        [self onDataFailed:baseResponse.msg];
//    }
}

/* protocol WVRRequestProtocol method */
- (id)execute {
    AFHTTPSessionManager *manager = [[WVRRequestOptManager sharedInstance] getAFManagerInstance];//[self afnetworkOperationManager];
    
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    //    requestSerializer.timeoutInterval = 10;
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    //   [requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    
    manager.requestSerializer = requestSerializer;
    
    manager.securityPolicy.allowInvalidCertificates=YES;
    
    manager.responseSerializer.acceptableContentTypes =
    [NSSet setWithObjects:@"text/html",@"text/json",@"application/json",@"text/plain", nil];
    
    [manager POST:(NSString *)[self getUrl] parameters:[self getBodyParam] progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self onRequestSuccess:responseObject];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (task.response) {
            [self onRequestSuccess:task.response];
        }else{
            [self onRequestFailed:error];
        }
    }];
    return manager;
}

- (AFHTTPSessionManager *)afnetworkOperationManager
{
    return [AFHTTPSessionManager manager];
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

- (void)httpRefreshTokenSuccessBlock:(id)result
{
    [self.bodyParams setValue:[WVRUserModel sharedInstance].sessionId forKeyPath:@"accesstoken"];
    [self execute];
}

- (NSString *)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

/* WVRBaseRequest method*/
- (NSString *)getHost
{
    return [WVRUserModel kSnailvrBaseURL];
}

//- (void)updateUserDefaultInfo:(WVRHttpUserModel *)resSuccess {
//    
//    [WVRUserModel sharedInstance].username = resSuccess.username;
//    [WVRUserModel sharedInstance].accountId = resSuccess.heliosid.length > 0 ? resSuccess.heliosid : resSuccess.account_id;
//    [WVRUserModel sharedInstance].sessionId = resSuccess.accesstoken;
//    [WVRUserModel sharedInstance].expiration_time = resSuccess.expiretime;
//    [WVRUserModel sharedInstance].refreshtoken = resSuccess.refreshtoken;
//    [WVRUserModel sharedInstance].mobileNumber = resSuccess.mobile;
//    [WVRUserModel sharedInstance].loginAvatar = resSuccess.avatar;
//}

- (NSDictionary *)getBodyParam {
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[self bodyParams]];
    params[kHttpParams_storapi_timestamp] = [NSString stringWithFormat:@"%ld",(long)[SQDateTool sysTimeSec]];
    for (NSString * key in [WVRAppModel sharedInstance].commenParams) {
        params[key] = [WVRAppModel sharedInstance].commenParams[key];
    }
    self.bodyParams = params;
    params[@"sign"] = [self signParamsMD5];
    NSLog(@"\n-------分割线-------\n3bodyParams--:\n %@\n-------分割线-------\n", [self dictionaryToJson:params]);
    return params;
}
@end
