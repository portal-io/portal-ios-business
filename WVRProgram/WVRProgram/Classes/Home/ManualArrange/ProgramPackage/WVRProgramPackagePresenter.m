//
//  WVRProgramPackagePresenter.m
//  WhaleyVR
//
//  Created by qbshen on 2017/7/21.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRProgramPackagePresenter.h"
#import "WVRProgramPackageViewModel.h"
//#import "WVRMyOrderItemModel.h"

#import "WVRSectionModel.h"
//#import "WVRInAppPurchaseManager.h"


@implementation WVRProgramPackagePresenter


#pragma mark - request

- (void)httpRequest {
    [self.gView showLoadingWithText:nil];
    [self requestListDetail];
}

- (void)requestListDetail {
    
    kWeakSelf(self);
    [WVRProgramPackageViewModel http_programPackageWithCode:[self.args linkArrangeValue] successBlock:^(WVRSectionModel *args) {
        [weakself httpSuccessBlock:args];
    } failBlock:^(NSString *args) {
        [weakself httpFailBlock:args];
    }];
}

- (void)httpSuccessBlock:(WVRSectionModel *)args {
    // 普通专题（手动编排）
    if (![self.args isChargeable]) {
//        [super httpSuccessBlock:args];
        return;
    }
    
    [self.args setHaveCharged:[self.args programPackageHaveCharged]];
    
    if ([[WVRUserModel sharedInstance] isisLogined] && ![self.args haveCharged]) {
//        kWeakSelf(self);
//        if ([[WVRUserModel sharedInstance] isisLogined]) {
//            [WVRMyOrderItemModel requestForQueryProgramCharged:[self.args linkArrangeValue] goodsType:PurchaseProgramTypeCollection block:^(BOOL isCharged, NSError *error) {
//                
//                [weakself.args setHaveCharged:isCharged];
//                // 只能购买合集，单个节目没有对应券，不需要判断其是否已购买
////                if (isCharged || [[weakself.args type] isEqualToString:@"0"]) {
////                    
////                    [weakself.gView updatePayStatus:args];
////                } else {
////                    [weakself requestForListItemCharged:args];
////                }
//            }];
//        }
    } else {
        [self.args setHaveCharged:NO];
//        [self updatePayStatus:args];
    }
}

-(void)httpFailBlock:(NSString*)args
{

}

- (void)requestForListItemCharged:(WVRSectionModel *)args {
    
    kWeakSelf(self)
    NSMutableArray *arr = [NSMutableArray array];
    for (WVRItemModel *item in args.itemModels) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
        dict[@"sid"] = item.code;
        dict[@"type"] = item.contentType;
        
        [arr addObject:dict];
    }
//    [WVRInAppPurchaseManager requestCheckGoodsPayedList:arr block:^(NSArray *list, NSError *error) {
//        
//        int count = 0;
//        for (NSDictionary *resDic in list) {
//            
//            if (args.itemModels.count > count) {
//                int isCharged = [resDic[@"result"] intValue];
//                NSString *goodsNo = resDic[@"goodsNo"];
//                WVRItemModel *itemModel = [args.itemModels objectAtIndex:count];
//                
//                if ([goodsNo isEqualToString:itemModel.linkArrangeValue]) {
//                    
//                    itemModel.packageItemCharged = @(isCharged);
//                }
//            }
//            
//            count += 1;
//        }
//        
////        [weakself updatePayStatus:args];
//    }];
}


@end
