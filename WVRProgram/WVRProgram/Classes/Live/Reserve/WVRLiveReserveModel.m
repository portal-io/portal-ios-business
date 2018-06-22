//
//  WVRLiveReserveModel.m
//  WhaleyVR
//
//  Created by qbshen on 2016/12/7.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRLiveReserveModel.h"
#import "WVRHttpLiveList.h"
#import "SQDateTool.h"
#import "WVRHttpLiveOrder.h"
#import "WVRHttpLiveOrderList.h"

@implementation WVRLiveReserveModel

- (void)http_liveOrder_listSuccessBlock:(void(^)(NSArray*))successBlock failBlock:(void(^)(NSString*))failBlock
{
    WVRHttpLiveOrderList *cmd = [[WVRHttpLiveOrderList alloc] init];
    kWeakSelf(self);
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[kHttpParams_liveOrderList_uid] = [WVRUserModel sharedInstance].accountId;
    params[kHttpParams_liveOrderList_token] = [WVRUserModel sharedInstance].sessionId;
    params[kHttpParams_liveOrderList_device_id] = [WVRUserModel sharedInstance].deviceId;
    cmd.bodyParams = params;
    cmd.successedBlock = ^(WVRHttpLiveOrderListModel *data) {
        [weakself httpLiveOrderListSuccessBlock:data successBlock:^(NSArray *args) {
            successBlock(args);
        }];
    };
    cmd.failedBlock = ^(NSString* errMsg) {
        NSLog(@"fail msg: %@",errMsg);
        failBlock(errMsg);
    };
    [cmd execute];
}

- (void)httpLiveOrderListSuccessBlock:(WVRHttpLiveOrderListModel *)args successBlock:(void(^)(NSArray *))successBlock
{
    NSMutableArray * originArray = [NSMutableArray array];
    for (WVRHttpLiveDetailModel* item in args.data) {
        WVRSQLiveItemModel * itemModel = [self parseLiveDetail:item];
        itemModel.thubImageUrl = item.poster;
        if (itemModel.liveStatus != WVRLiveStatusNotStart) {
            continue;
        }
        [originArray addObject:itemModel];
    }
    successBlock(originArray);
}

+ (void)http_liveOrder:(BOOL)isAdd itemId:(NSString *)itemId successBlock:(void(^)())successBlock failBlock:(void(^)(NSString *err))failBlock {
    
    WVRHttpLiveOrder *cmd = [[WVRHttpLiveOrder alloc] initIsadd:isAdd];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[kHttpParams_liveOrder_uid] = [WVRUserModel sharedInstance].accountId;
    params[kHttpParams_liveOrder_token] = [WVRUserModel sharedInstance].sessionId;
    params[kHttpParams_liveOrder_device_id] = [WVRUserModel sharedInstance].deviceId;
    params[kHttpParams_liveOrder_code] = itemId;
    cmd.bodyParams = params;
    
    cmd.successedBlock = ^(WVRHttpLiveListParentModel* args) {
        successBlock();
    };
    
    cmd.failedBlock = ^(id args) {
        if ([args isKindOfClass:[NSString class]]) {
            failBlock(args);
        }
    };
    
    [cmd execute];
}

//临时在直播未开始的直播详情界面获取已预约列表，以筛选此直播是否已预约
- (void)http_liveOrderForLiveDetailCheckReserve_listSuccessBlock:(void(^)(NSArray *))successBlock failBlock:(void(^)(NSString *))failBlock
{
    WVRHttpLiveOrderList * cmd = [[WVRHttpLiveOrderList alloc] init];
    kWeakSelf(self);
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    params[kHttpParams_liveOrderList_uid] = [WVRUserModel sharedInstance].accountId;
    params[kHttpParams_liveOrderList_token] = [WVRUserModel sharedInstance].sessionId;
    params[kHttpParams_liveOrderList_device_id] = [WVRUserModel sharedInstance].deviceId;
    cmd.bodyParams = params;
    cmd.successedBlock = ^(WVRHttpLiveOrderListModel *data) {
        [weakself httpLiveOrderListForLiveDetailCheckReserveSuccessBlock:data successBlock:^(NSArray *args) {
            successBlock(args);
        }];
    };
    cmd.failedBlock = ^(NSString *errMsg) {
        NSLog(@"fail msg: %@", errMsg);
        failBlock(errMsg);
    };
    [cmd execute];
}

- (void)httpLiveOrderListForLiveDetailCheckReserveSuccessBlock:(WVRHttpLiveOrderListModel *)args successBlock:(void(^)(NSArray *))successBlock
{
    NSMutableArray * originArray = [NSMutableArray array];
    for (WVRHttpLiveDetailModel* item in args.data) {
        WVRSQLiveItemModel * itemModel = [self parseLiveDetail:item];
        itemModel.thubImageUrl = item.poster;
        if (itemModel.liveStatus != WVRLiveStatusNotStart) {
            continue;
        }
        if ([itemModel.hasOrder intValue] != 1) {
            continue;
        }
        [originArray addObject:itemModel];
    }
    successBlock(originArray);
}

@end


@implementation WVRLReSectionModel

@end


@implementation WVRLiveReserveDayInfo

@end
