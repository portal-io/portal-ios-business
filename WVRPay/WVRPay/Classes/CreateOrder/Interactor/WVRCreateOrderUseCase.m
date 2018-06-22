//
//  WVRCreateOrderUseCase.m
//  WhaleyVR
//
//  Created by qbshen on 2017/8/31.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRCreateOrderUseCase.h"
#import "WVRApiHttpCreateOrder.h"
#import "WVRErrorViewModel.h"
#import "WVROrderModel.h"
#import "WVRHttpCreateOrderReformer.h"
#import "WVRUserModel.h"

@implementation WVRCreateOrderUseCase
- (void)initRequestApi {
    self.requestApi = [[WVRApiHttpCreateOrder alloc] init];
}

- (RACSignal *)buildUseCase {
    return [[self.requestApi.executionSignal map:^id _Nullable(WVRNetworkingResponse *  _Nullable value) {
        WVROrderModel * orderModel = [self.requestApi fetchDataWithReformer:[WVRHttpCreateOrderReformer new]];
        return orderModel;
    }] doNext:^(id  _Nullable x) {
        
    }];
    
}

- (RACSignal *)buildErrorCase {
    return [self.requestApi.requestErrorSignal map:^id _Nullable(WVRNetworkingResponse *  _Nullable value) {
        WVRErrorViewModel *error = [[WVRErrorViewModel alloc] init];
        error.errorCode = value.content[@"code"];
        error.errorMsg = value.content[@"msg"];
        return error;
    }];
}

// WVRUseCaseProtocol delegate
- (NSDictionary *)paramsForAPI:(WVRAPIBaseManager *)manager {
    NSDictionary *params = @{};
    if (manager == self.requestApi) {
        params = @{
                   kHttpParam_CreateOrder_uid:[[WVRUserModel sharedInstance] sessionId],
                   kHttpParam_CreateOrder_goodsNo:self.goodCode,
                   kHttpParam_CreateOrder_goodsType:self.goodType,
                   kHttpParam_CreateOrder_price:@(self.goodPrice),
                   kHttpParam_CreateOrder_payMethod:[self payPlatformName:self.payPlatform],
                   kHttpParam_CreateOrder_sign:[self sign]
                   };
    }
    return params;
}

-(NSString*)payPlatformName:(WVRPayPlatform)platform
{
    switch (platform) {
        case WVRPayPlatformWeixin:
            return @"weixin";
            break;
        case WVRPayPlatformAlipay:
            return @"alipay";
            break;
        default:
            return @"";
            break;
    }
}

-(NSString*)sign
{
    NSString *unSignStr = [NSString stringWithFormat:@"%@%@%@%ld%@%@", [[WVRUserModel sharedInstance] sessionId], self.goodCode, self.goodType, self.goodPrice, [self payPlatformName:self.payPlatform], [WVRUserModel CMCPURCHASE_sign_secret]];
    
    NSString *signStr = [WVRGlobalUtil md5HexDigest:unSignStr];
    return signStr;
}

-(RACCommand *)createOrderCmd
{
    return self.requestApi.requestCmd;
}
@end

