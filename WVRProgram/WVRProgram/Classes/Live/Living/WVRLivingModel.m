//
//  WVRLivingModel.m
//  WhaleyVR
//
//  Created by qbshen on 2016/12/8.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRLivingModel.h"
#import "WVRSectionModel.h"
#import "WVRHttpLiveList.h"

@implementation WVRLivingModel
-(void)httpPageDetailSuccessBlock:(WVRHttpLiveListParentModel* )args successBlock:(void(^)(NSArray*))successBlock
{
    NSMutableArray * originArray = [NSMutableArray array];
    for (WVRHttpLiveDetailModel* item in args.data) {
        WVRSQLiveItemModel * itemModel = [self parseLiveDetail:item];
        itemModel.thubImageUrl = item.poster;
        if (itemModel.liveStatus != WVRLiveStatusPlaying) {
            continue;
        }
        [originArray addObject:itemModel];
    }
    successBlock(originArray);
}


@end
