//
//  WVRSQLiveDetailModel.m
//  WhaleyVR
//
//  Created by qbshen on 2016/11/21.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRSQLiveDetailModel.h"
#import "WVRHttpLiveDetail.h"

@implementation WVRSQLiveDetailModel

- (void)http_recommendLiveDetailWithCode:(NSString *)code successBlock:(void(^)(WVRSQLiveItemModel*))successBlock failBlock:(void(^)(NSString *))failBlock {
    
    WVRHttpLiveDetail *cmd = [[WVRHttpLiveDetail alloc] init];
    NSMutableDictionary * httpDic = [NSMutableDictionary dictionary];
    httpDic[kHttpParams_liveDetail_code] = code;
    if ([WVRUserModel sharedInstance].accountId.length > 0) {
        httpDic[@"uid"] = [WVRUserModel sharedInstance].accountId;
    }
    cmd.bodyParams = httpDic;
    cmd.successedBlock = ^(WVRHttpLiveDetailParentModel* args) {
        [self httpPageDetailSuccessBlock:args successBlock:^(WVRSQLiveItemModel *model) {
            successBlock(model);
        }];
    };
    
    cmd.failedBlock = ^(id args) {
        if ([args isKindOfClass:[NSString class]]) {
            failBlock(args);
        }
    };
    [cmd execute];
}

- (void)httpPageDetailSuccessBlock:(WVRHttpLiveDetailParentModel *)args successBlock:(void(^)(WVRSQLiveItemModel *))successBlock {
    
    WVRSQLiveItemModel* itemModel = [self parseLiveDetail:args.data];
    itemModel.intrDesc = args.data.descriptionStr;
    itemModel.subTitle = args.data.subtitle;
    itemModel.thubImageUrl = args.data.poster;
    itemModel.liveOrderCount = args.data.liveOrderCount;
    itemModel.bgPic = args.data.bgPic;
    
    successBlock(itemModel);
}


@end
