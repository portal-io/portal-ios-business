//
//  Target_program.m
//  WhaleyVR
//
//  Created by qbshen on 2017/8/15.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "Target_pay.h"

#import "WVRMyTicketVC.h"
#import "WVRPayManager.h"
#import "WVRInAppPurchaseManager.h"

#import "WVRCheckDeviceUseCase.h"
#import "WVRPayReportDeviceUseCase.h"

@implementation Target_pay

- (UIViewController *)Action_nativeFetchMyTicketViewController:(NSDictionary *)params {
    
    WVRMyTicketVC * vc = [[WVRMyTicketVC alloc] init];
    return vc;
}


- (void)Action_nativePayForVideo:(NSDictionary *)params {
    
    WVRItemModel *model = params[@"itemModel"];
    WVRStreamType type = [params[@"streamType"] integerValue];
    RACCommand *cmd = params[@"cmd"];
    
    WVRPayModel * payModel = [WVRPayModel createWithDetailModel:model streamType:type];
    
    [[WVRPayManager shareInstance] showPayAlertViewWithPayModel:payModel viewController:[UIViewController getCurrentVC] resultCallback:^(WVRPayManageResultStatus status) {
        
        NSMutableDictionary *resDict = [NSMutableDictionary dictionary];
        resDict[@"success"] = @(status == WVRPayManageResultStatusSuccess);
        resDict[@"msg"] = [WVRPayManager messageForStatus:status];
        [cmd execute:resDict];
    }];
}

- (void)Action_nativeCheckDevice:(NSDictionary *)params {
    
    RACCommand * cmd = params[@"cmd"];
    
    WVRCheckDeviceUseCase * checkDeviceUC = [[WVRCheckDeviceUseCase alloc] init];
    
    [[checkDeviceUC buildUseCase] subscribeNext:^(NSNumber *  _Nullable x) {
        if (!x.boolValue) {
            [cmd execute:x];
        }
    }];
    [[checkDeviceUC buildErrorCase] subscribeNext:^(id  _Nullable x) {
        
    }];
    [[checkDeviceUC getRequestCmd] execute:nil];
}

- (void)Action_nativePayReportDevice:(NSDictionary *)params {
    
    RACCommand * cmd = params[@"cmd"];
    
    WVRPayReportDeviceUseCase * reportDeviceUC = [[WVRPayReportDeviceUseCase alloc] init];
    
    [[reportDeviceUC buildUseCase] subscribeNext:^(NSNumber *  _Nullable x) {
        if (!x.boolValue) {
            [cmd execute:x];
        }
    }];
    [[reportDeviceUC buildErrorCase] subscribeNext:^(id  _Nullable x) {
        
    }];
    [[reportDeviceUC getRequestCmd] execute:nil];
}

- (void)Action_nativeCheckIsPaied:(NSDictionary *)params {
    
    RACCommand * cmd = params[@"cmd"];
    
    WVRItemModel *item = params[@"item"];
    NSArray *items = params[@"items"];
    
    if (item) {
        [self checkIsPaiedForVideo:item cmd:cmd];
    } else if (items) {
        [self checkIsPaidForVideos:items cmd:cmd];
    } else {
        DDLogError(@"params error!");
    }
}

- (void)Action_nativeReportLostInAppPurchaseOrders:(NSDictionary *)params {
    
    [WVRInAppPurchaseManager reportLostInAppPurchaseOrders];
}

#pragma mark - private func

- (void)checkIsPaiedForVideo:(WVRItemModel *)item cmd:(RACCommand *)cmd {
    
    if (![item isKindOfClass:[WVRItemModel class]]) {
        DDLogError(@"params error!");
        return;
    }
    
}

- (void)checkIsPaidForVideos:(NSArray<WVRItemModel *> *)items cmd:(RACCommand *)cmd {
    
    if (![items isKindOfClass:[NSArray class]]) {
        DDLogError(@"params error!");
        return;
    }
    
}

@end
