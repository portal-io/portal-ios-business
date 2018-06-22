//
//  WVRPostRequest.m
//  VRManager
//
//  Created by Wang Tiger on 16/6/15.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRStoreapiFileRequest.h"
#import "WVRRequestPage.h"
#import "AFHTTPSessionManager.h"
#import "WVRRequestOptManager.h"
//#import "WVRWAccountBaseResponse.h"
#import "YYModel.h"


@implementation WVRStoreapiFileRequest

- (void)onRequestSuccess:(id)responesObject
{
//    NSDictionary *result = (NSMutableDictionary*)responesObject;
//    self.originResponse = responesObject;
//    NSLog(@"\n-------分割线-------\nresponesObject:\n %@\n-------分割线-------\n", [self dictionaryToJson:responesObject]);
//    WVRWAccountBaseResponse *baseResponse = [WVRWAccountBaseResponse yy_modelWithDictionary:result];
//    NSString * code = baseResponse.code;
//    if ([code isEqualToString:@"000"]) {
//        [self onDataSuccess:baseResponse];
//    } else {
//        [self onDataFailed:baseResponse.msg];
//    }
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
    return [WVRUserModel kWhaleyAccountBaseURL];
}

@end
