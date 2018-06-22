//
//  WVRWAccountPostRequest.m
//  WhaleyVR
//
//  Created by qbshen on 16/10/19.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRStoreapiBaseGetRequest.h"
//#import "WVRHttpRefreshToken.h"

#import "WVRUserModel.h"
#import "WVRNewVRCodeHead.h"
#import "SQDateTool.h"

#import <WVRMediator+AccountActions.h>

@implementation WVRStoreapiBaseGetRequest

- (void)onRequestSuccess:(id)responesObject {
    
    NSDictionary *result = (NSMutableDictionary *)responesObject;
    self.originResponse = responesObject;
//    NSLog(@"\n-------分割线-------\nresponesObject:\n %@\n-------分割线-------\n", [self dictionaryToJson:responesObject]);
    WVRStoreapiBaseResponse *baseResponse = [WVRStoreapiBaseResponse yy_modelWithDictionary:result];
    NSInteger status = baseResponse.status;
    if (status == 1) {
        [self onDataSuccess:baseResponse];
    }
    else {
        [self onDataFailed:baseResponse.msg];
    }
}

#pragma http forgotPW smsCode

- (void)httpRefreshToken {
    
//    @weakify(self);
//    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
//        
//        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
//            @strongify(self);
//            [self httpRefreshTokenSuccessBlock:input];
//            return nil;
//        }];
//    }];
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    dict[@"cmd"] = command;
//    dict[@"code"] = @"152";
//    
//    [[WVRMediator sharedInstance] WVRMediator_RefreshToken:dict];
}

//- (void)httpRefreshTokenSuccessBlock:(id)result {
//    
//    [self.bodyParams setValue:[WVRUserModel sharedInstance].sessionId forKeyPath:@"accesstoken"];
//    [self execute];
//}


- (NSString *)dictionaryToJson:(NSDictionary *)dic {
    
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

/* WVRBaseRequest method*/

- (NSString *)getHost {
    
    return [WVRUserModel kSnailvrBaseURL];
}

- (NSString *)getUrl {
    
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:self.bodyParams];
    dic[kHttpParams_storapi_timestamp] = [NSString stringWithFormat:@"%ld",(long)[SQDateTool sysTimeSec]];
    self.bodyParams = dic;
    NSString * str = [super getUrl];
    str = [str stringByAppendingString:@"&sign="];
    str = [str stringByAppendingString:[self signParamsMD5]];
    NSLog(@"\n-------分割线-------\nrequestURL:\n %@\n-------分割线-------\n", str);
    return str;
}
@end
