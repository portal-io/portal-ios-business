//
//  WVRHistoryViewModel.m
//  WhaleyVR
//
//  Created by qbshen on 2017/3/30.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRHistoryViewModel.h"
#import "WVRApiHttpHistoryList.h"
#import "WVRHistoryModel.h"
#import "WVRHistoryModelReformer.h"
#import "WVRApiHttpHistoryDels.h"
#import "WVRApiHttpHistoryDelAll.h"
#import "WVRSectionModel.h"

@interface WVRHistoryViewModel ()

@end
@implementation WVRHistoryViewModel


-(void)dealloc
{
    DebugLog(@"");
}

-(void)http_historyList:(void(^)(NSArray<WVRSectionModel*>*))successBlock andFailBlock:(void(^)(NSString*))failBlock
{
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    params[history_list_uid] = [WVRUserModel sharedInstance].accountId;
    params[history_list_device_id] = [WVRUserModel sharedInstance].deviceId;
    params[history_list_page] = @"0";
    params[history_list_size] = @"100";
    params[history_list_dataSource] = @"app";
    
    WVRApiHttpHistoryList *api = [[WVRApiHttpHistoryList alloc] init];
    api.bodyParams = params;
    api.successedBlock = successBlock;
    api.failedBlock = failBlock;
    [api loadData];
}


-(void)http_history_dels:(NSString * )delIds successBlock:(void(^)(NSArray<WVRHistoryModel*>*))successBlock andFailBlock:(void(^)(NSString*))failBlock
{
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    params[history_dels_dataSource] = @"app";
    params[history_dels_uid] = [WVRUserModel sharedInstance].accountId;
    params[history_dels_deviceId] = [WVRUserModel sharedInstance].deviceId;
    params[history_dels_delIds] = delIds;
    
    WVRApiHttpHistoryDels *api = [[WVRApiHttpHistoryDels alloc] init];
    api.bodyParams = params;
    api.successedBlock = successBlock;
    api.failedBlock = failBlock;
    [api loadData];
}

-(void)http_history_delAll:(void(^)(NSArray<WVRHistoryModel*>*))successBlock andFailBlock:(void(^)(NSString*))failBlock
{
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    params[history_delAll_dataSource] = @"app";
    params[history_delAll_uid] = [WVRUserModel sharedInstance].accountId;
    params[history_delAll_deviceId] = [WVRUserModel sharedInstance].deviceId;
    
    WVRApiHttpHistoryDelAll *api = [[WVRApiHttpHistoryDelAll alloc] init];
    api.bodyParams = params;
    api.successedBlock = successBlock;
    api.failedBlock = failBlock;
    [api loadData];
}
@end
