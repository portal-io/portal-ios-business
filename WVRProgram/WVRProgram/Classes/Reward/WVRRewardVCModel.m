//
//  WVRRewardModel.m
//  WhaleyVR
//
//  Created by qbshen on 2016/12/14.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRRewardVCModel.h"
#import "WVRHttpRewardList.h"
#import "WVRHttpGetAddress.h"

@implementation WVRRewardVCModel

+ (void)http_myRewardWithSuccessBlock:(void(^)(WVRRewardVCModel*))successBlock failBlock:(void(^)(NSString*))failBlock
{
    WVRHttpRewardList  * cmd = [WVRHttpRewardList new];
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[kHttpParams_rewardList_whaleyuid] = [[WVRUserModel sharedInstance] accountId];
    cmd.bodyParams = params;
    
    cmd.successedBlock = ^(WVRHttpRewardListModel* args){
        WVRRewardVCModel * vcModel = [WVRRewardVCModel new];
//        args.prizesdata = [vcModel revokeData];
        vcModel.addressModel = [[WVRAddressModel alloc] initWithHttpModel:args.addressdata];
        
        if (args.prizesdata.count==0) {
            
        }else{
            NSArray<WVRRewardSectionModel*>* sectionModels = [vcModel parseRewardList:args.prizesdata];
            vcModel.sectionRewards = sectionModels;
        }
        successBlock(vcModel);
    };
    
    cmd.failedBlock = ^(id args){
        if ([args isKindOfClass:[NSString class]]) {
            failBlock(args);
        }
    };
    [cmd execute];
}

//- (NSArray<WVRHttpRewardModel *> *)revokeData
//{
//    NSMutableArray *list =[NSMutableArray array];
//    for (int i = 0; i < 20; i++) {
//        WVRHttpRewardModel * model = [WVRHttpRewardModel new];
//        model.name = [NSString stringWithFormat:@"%d",i];
//        model.picture = @"http://image.aginomoto.com/image/get-image/10000004/14790273771354939764.jpg/zoom/540/304";
//        model.dateline = [NSString stringWithFormat:@"%ld",(long)148170204*((i+2)/2)*1000];
//        model.goodstype = [NSString stringWithFormat:@"%d",i/2];
//        if (i/2==2) {
//            model.info = [NSString stringWithFormat:@"用户券号：qwertyu%d\n密码：123456",i/2];
//        }else{
//            model.info = [NSString stringWithFormat:@"qwertyu%d",i/2];
//        }
//        [list addObject:model];
//    }
//    return list;
//}

- (NSArray<WVRRewardSectionModel *> *)parseRewardList:(NSArray<WVRHttpRewardModel *> *)list
{
    NSMutableArray * rewardSections = [NSMutableArray array];
//    list = [list sortedArrayUsingComparator:^NSComparisonResult(WVRHttpRewardModel*  _Nonnull obj1, WVRHttpRewardModel*  _Nonnull obj2) {
//        if (obj1.dateline.doubleValue > obj2.dateline.doubleValue) {
//            return NSOrderedDescending;
//        }else{
//            return NSOrderedAscending;
//        }
//    }];
    NSMutableArray * resultList = [NSMutableArray array];
    NSMutableArray * rewardTimekeys = [NSMutableArray array];
    for (WVRHttpRewardModel* cur in list) {
        WVRRewardModel * model = [WVRRewardModel new];
        model.title = cur.name;
        model.formatDateStr = [SQDateTool month_day_hour_minute:[cur.dateline doubleValue]*1000 withFormatStr:@"MM月dd日 HH:mm"];
        model.formatDateKey = [SQDateTool month_day:[cur.dateline doubleValue]*1000];
        model.thubImageStr = cur.picture;
        model.rewardType = [cur.goodstype integerValue];
        model.rewardInfo = cur.info;
        
        [resultList addObject:model];
        if (![rewardTimekeys containsObject:model.formatDateKey]) {
            [rewardTimekeys addObject:model.formatDateKey];
        }
    }
    
    for (NSString * key in rewardTimekeys) {
        WVRRewardSectionModel * sectionModel = [WVRRewardSectionModel new];
        NSMutableArray * rewards = [NSMutableArray array];
        sectionModel.formatDateKey = key;
        for (WVRRewardModel* model in resultList) {
            if ([model.formatDateKey isEqualToString:key]) {
                [rewards addObject:model];
            }
        }
        sectionModel.rewards = rewards;
        [rewardSections addObject:sectionModel];
    }
    return rewardSections;
}

+ (void)http_getAddressWithSuccessBlock:(void(^)(WVRAddressModel *))successBlock failBlock:(void(^)(NSString *))failBlock
{
    WVRHttpGetAddress  * cmd = [WVRHttpGetAddress new];
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[kHttpParams_getAddress_whaleyuid] = [[WVRUserModel sharedInstance] accountId];

    cmd.bodyParams = params;
    
    cmd.successedBlock = ^(WVRHttpGetAddressModel* args){
        WVRAddressModel * addressModel = [[WVRAddressModel alloc] initWithHttpModel:args.member_addressdata];
        successBlock(addressModel);
    };

    cmd.failedBlock = ^(id args){
        if ([args isKindOfClass:[NSString class]]) {
            failBlock(args);
        }
    };
    [cmd execute];
}

@end


@implementation WVRRewardSectionModel

@end
