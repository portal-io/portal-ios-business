//
//  WVRHTTPClient.m
//  WhaleyVR
//
//  Created by Snailvr on 16/8/4.
//  Copyright © 2016年 Snailvr. All rights reserved.

// 通用json数据接口 无baseURL

#import "WVRHTTPClient.h"
#import "WVRAPIHandle.h"

@implementation WVRHTTPClient

+ (instancetype)sharedClient {
    
    static WVRHTTPClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once (&onceToken, ^{
        _sharedClient = [[WVRHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    });
    return _sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    
    if (self) {
        
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        
        ((AFJSONResponseSerializer *)self.responseSerializer).removesKeysWithNullValues = YES;
        
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", @"text/html", @"text/xml", nil];
        
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [self.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        self.requestSerializer.timeoutInterval = 10;
    }
    
    return self;
}

//GET请求
- (void)GETService:(NSString *)URLStr withParams:(NSDictionary *)params completionBlock:(APIResponseBlock)block {
    
    [self GET:URLStr parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        DDLogInfo(@"WVRHTTPClient_GET %@", task.currentRequest.URL.absoluteString);
        block(responseObject, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        DDLogInfo(@"WVRHTTPClient_GET %@", task.currentRequest.URL.absoluteString);
        DDLogError(@"WVRHTTPClient_GET %@", [error localizedDescription]);
        
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)task.response;
        DDLogError(@"WVRHTTPClient_GET %ld", (long)res.statusCode);
        
        block(nil, error);
    }];
}

//POST 请求封装
- (void)POSTService:(NSString *)URLStr withParams:(NSDictionary *)params completionBlock:(APIResponseBlock)block {
    
    [self POST:URLStr parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        DDLogInfo(@"WVRHTTPClient_POST %@", task.currentRequest.URL.absoluteString);
        block(responseObject, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        DDLogInfo(@"WVRHTTPClient_POST %@", task.currentRequest.URL.absoluteString);
        DDLogError(@"WVRHTTPClient_POST %@", [error localizedDescription]);
        
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)task.response;
        DDLogError(@"WVRHTTPClient_POST %ld", (long)res.statusCode);
        
        block(nil, error);
    }];
}

- (void)cancelOperations {
    
    [self.operationQueue cancelAllOperations];
}


@end
