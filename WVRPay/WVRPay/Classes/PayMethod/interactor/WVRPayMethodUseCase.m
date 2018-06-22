//
//  WVRPayMethodUseCase.m
//  WhaleyVR
//
//  Created by Bruce on 2017/9/12.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRPayMethodUseCase.h"
#import "WVRHttpPayMethod.h"
#import "WVRErrorViewModel.h"
#import "WVRPayGoodsType.h"

#define kIOSPurchaseType @"40582FD9679C057B"

@implementation WVRPayMethodUseCase

- (void)initRequestApi {
    
    self.requestApi = [[WVRHttpPayMethod alloc] init];
}

- (RACSignal *)buildUseCase {
    
    @weakify(self);
    return [[self.requestApi.executionSignal map:^id _Nullable(WVRNetworkingResponse *  _Nullable value) {
        
        @strongify(self);
        NSArray *result = [self dealWithResponse:value];
        
        return result;
    }] doNext:^(id  _Nullable x) {
        
    }];
}

- (RACSignal *)buildErrorCase {
    
    return [[self.requestApi.requestErrorSignal map:^id _Nullable(WVRNetworkingResponse *  _Nullable value) {
        WVRErrorViewModel *error = [[WVRErrorViewModel alloc] init];
        error.errorCode = value.content[@"code"];
        error.errorMsg = value.content[@"msg"];
        return error;
    }] doNext:^(id  _Nullable x) {
        
    }];
}

- (NSDictionary *)paramsForAPI:(WVRAPIBaseManager *)manager {
    
    return [NSDictionary dictionary];
}

- (NSArray *)dealWithResponse:(WVRNetworkingResponse *)response {
    
    NSDictionary *dic = response.content;
    
    int code = [dic[@"code"] intValue];
    NSArray *result = nil;
    if (code == 200) {
        
        NSDictionary *dict = dic[@"data"];
        NSMutableArray *typeList = [NSMutableArray arrayWithCapacity:4];
        
        // 预留 鲸币
//        if ([dict[@"whaleyCurrency"] boolValue]) {
//            [typeList addObject:@(WVRPayMethodWhaleyCurrency)];
//        }
        if ([dict[@"alipay"] boolValue]) {
            [typeList addObject:@(WVRPayMethodAlipay)];
        }
        if ([dict[@"weixin"] boolValue]) {
            [typeList addObject:@(WVRPayMethodWeixin)];
        }
        if ([dict[@"appStore"] boolValue]) {
            [typeList addObject:@(WVRPayMethodAppStore)];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:typeList forKey:kIOSPurchaseType];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        result = typeList;
        
    } else {
        NSArray *methodList = [[NSUserDefaults standardUserDefaults] objectForKey:kIOSPurchaseType];
        if (![methodList isKindOfClass:[NSArray class]] || methodList.count == 0) {
            methodList = nil;
            [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:kIOSPurchaseType];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        if (!methodList) {
            methodList = @[ @(WVRPayMethodAppStore) ];
        }
        result = methodList;
    }
    
    return result;
}

@end
