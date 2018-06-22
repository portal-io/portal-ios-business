//
//  WVRWAccountPostRequest.m
//  WhaleyVR
//
//  Created by qbshen on 16/10/19.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRNewVRBasePostStatusRequest.h"

@interface WVRNewVRBasePostStatusRequest ()

@property (nonatomic) AFHTTPSessionManager *manager;

@end


@implementation WVRNewVRBasePostStatusRequest

/* protocol WVRRequestProtocol method */
- (id)execute {
    
    AFHTTPSessionManager *manager = self.manager;
    
    NSURLSessionDataTask *task = [manager POST:[self getUrl] parameters:[self getBodyParam] constructingBodyWithBlock:^(id _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self onRequestSuccess:responseObject];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self onRequestFailed:kLoadError];
    }];
    
    [task resume];
    return task;
}

- (AFHTTPSessionManager *)manager {
    if (!_manager) {
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        //TODO: set the default HTTP headers
        
        configuration.HTTPShouldSetCookies = YES;
        /**
         HTTPShouldUsePipelining表示receiver(理解为iOS客户端)的下一个信息是否必须等到上一个请求回复才能发送。
         如果为YES表示可以，NO表示必须等receiver收到先前的回复才能发送下个信息。
         */
        configuration.HTTPShouldUsePipelining = NO;
        /**NSURLRequestReloadRevalidatingCacheData
         *  NSURLRequestUseProtocolCachePolicy = 0, 默认的缓存策略， 如果缓存不存在，直接从服务端获取。如果缓存存在，会根据response中的Cache-Control字段判断下一步操作，如: Cache-Control字段为must-revalidata, 则询问服务端该数据是否有更新，无更新的话直接返回给用户缓存数据，若已更新，则请求服务端
         */
        configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
        configuration.allowsCellularAccess = YES;
        configuration.timeoutIntervalForRequest = 10.0;
        configuration.URLCache = [[NSURLCache alloc] initWithMemoryCapacity:100 * 1024 * 1024
                                                               diskCapacity:150 * 1024 * 1024
                                                                   diskPath:@"com.alamofire.imagedownloader"];
        
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        manager.responseSerializer.acceptableContentTypes =
        [NSSet setWithObjects:@"text/html",@"application/json", @"text/json",@"text/plain",@"text/xml", nil];
        manager.requestSerializer=[AFHTTPRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        manager.securityPolicy.allowInvalidCertificates = NO;
        manager.requestSerializer.timeoutInterval = 10;
        _manager = manager;
    }
    return _manager;
}

- (void)onRequestSuccess:(id)responesObject
{
    NSDictionary *result = (NSMutableDictionary *)responesObject;
    self.originResponse = responesObject;
    
    NSLog(@"\n-------分割线-------\nresponesObject:\n %@\n-------分割线-------\n", [self dictionaryToJson:responesObject]);
    WVRNewVRBaseStatusResponse *baseResponse = [WVRNewVRBaseStatusResponse yy_modelWithDictionary:result];
    
    NSInteger code = baseResponse.status;
    
    if (code == NEWVR_SUCCESS_CODE) {
        [self onDataSuccess:baseResponse];
    } else {
        [self onDataFailed:baseResponse.msg];
    }
}

#pragma http forgotPW smsCode
- (void)httpRefreshToken {
    
//    WVRHttpRefreshToken * cmd = [[WVRHttpRefreshToken alloc] init];
//    NSMutableDictionary * httpDic = [[NSMutableDictionary alloc] init];
//    httpDic[kHttpParams_refreshToken_refreshtoken] = [WVRUserModel sharedInstance].refreshtoken;
//    httpDic[kHttpParams_refreshToken_device_id] = [WVRUserModel sharedInstance].deviceId;
//    httpDic[kHttpParams_refreshToken_accesstoken] = [WVRUserModel sharedInstance].sessionId;
//    cmd.bodyParams = httpDic;
//    cmd.successedBlock = ^(id result) {
//        [self httpRefreshTokenSuccessBlock:result];
//    };
//        
//    cmd.failedBlock = ^(NSString* errMsg){
//        NSLog(@"fail msg: %@",errMsg);
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
    return [WVRUserModel kNewVRBaseURL];
}

@end
