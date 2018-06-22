//
//  WVRAllChannelViewModel.m
//  WhaleyVR
//
//  Created by qbshen on 2017/3/28.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRAllChannelViewModel.h"
#import "WVRApiHttpAllChannel.h"
#import "WVRHttpRecommendPageDetailModel.h"
#import "WVRModelErrorInfo.h"
#import "WVRItemModel.h"
#import "WVRHttpAllChannelReformer.h"

@interface WVRAllChannelViewModel ()

@end


@implementation WVRAllChannelViewModel

-(void)dealloc
{
    DebugLog(@"");
}

-(void)http_allChannel:(void(^)(NSArray<WVRItemModel*>*))successBlock andFailBlock:(void(^)(NSString*))failBlock
{
    WVRApiHttpAllChannel* api = [[WVRApiHttpAllChannel alloc] init];
    api.successedBlock = successBlock;
    api.failedBlock = failBlock;
    [api loadData];
}

@end
