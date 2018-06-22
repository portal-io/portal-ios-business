//
//  WVRPayBIModel.m
//  WhaleyVR
//
//  Created by Bruce on 2017/8/11.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRPayBIModel.h"
#import "WVRPayModel.h"

@implementation WVRPayBIModel

+ (void)trackEventForPayWithAction:(BIPayActionType)action payModel:(WVRPayModel *)payModel fromVC:(UIViewController *)fromVC {
    
    WVRBIModel *model = [[WVRBIModel alloc] init];
    model.logInfo.currentPageId = @"payDetails";
    model.logInfo.eventId = @"browse_view";
    model.logInfo.nextPageId = model.logInfo.currentPageId;
    
    NSMutableDictionary *currentPageProp = [NSMutableDictionary dictionary];
    NSMutableDictionary *eventProp = [NSMutableDictionary dictionary];
    
    if (action == BIPayActionTypeSuccess) {
        
        currentPageProp[@"voucherId"] = payModel.goodsCode;
        currentPageProp[@"voucherName"] = payModel.goodsName;
        currentPageProp[@"voucherType"] = payModel.relatedType;
        
        model.logInfo.eventId = @"pay_success";
    } else {
        
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:2];
        
        NSMutableDictionary *voucherModel = [NSMutableDictionary dictionary];
        
        voucherModel[@"voucherId"] = payModel.goodsCode;
        voucherModel[@"voucherName"] = payModel.goodsName;
        voucherModel[@"voucherType"] = payModel.relatedType;
        
        [arr addObject:voucherModel];
        
        if (payModel.programPackModel.couponDto.code) {
            
            NSMutableDictionary *voucherModel2 = [NSMutableDictionary dictionary];
            
            voucherModel2[@"voucherId"] = payModel.programPackModel.couponDto.code;
            voucherModel2[@"voucherName"] = payModel.programPackModel.couponDto.displayName;
            voucherModel2[@"voucherType"] = payModel.programPackModel.couponDto.relatedType;
            
            [arr addObject:voucherModel2];
        }
        currentPageProp[@"voucherModel"] = arr;
    }
    
    currentPageProp[@"isUnity"] = (nil == fromVC) ? @1 : @0;
    
    if (payModel.payComeFromType == WVRPayComeFromTypeProgramLive) {
        
        if (payModel.liveStatus == WVRLiveStatusNotStart) {
            
            currentPageProp[@"fromType"] = @"livePrevue";
        } else {
            currentPageProp[@"fromType"] = @"live";
        }
    } else if (payModel.payComeFromType == WVRPayComeFromTypeProgramPackage) {
        
        currentPageProp[@"fromType"] = @"content_packge";
    } else {
        
        currentPageProp[@"fromType"] = @"recorded";
    }
    
    model.logInfo.eventProp = eventProp;
    model.logInfo.currentPageProp = currentPageProp;
    
    [model saveToSQLite];
}

@end
