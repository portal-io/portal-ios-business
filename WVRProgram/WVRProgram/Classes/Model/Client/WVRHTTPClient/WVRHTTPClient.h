//
//  WVRHTTPClient.h
//  WhaleyVR
//
//  Created by Snailvr on 16/8/4.
//  Copyright © 2016年 Snailvr. All rights reserved.

// 通用json数据接口 无baseURL

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "WVRUserModel.h"

@interface WVRHTTPClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

- (void)GETService:(NSString *)URLStr withParams:(NSDictionary *)params completionBlock:(APIResponseBlock)block;

- (void)POSTService:(NSString *)URLStr withParams:(NSDictionary *)params completionBlock:(APIResponseBlock)block;

- (void)cancelOperations;

@end
