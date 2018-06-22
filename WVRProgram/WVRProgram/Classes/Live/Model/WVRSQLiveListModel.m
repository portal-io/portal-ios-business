//
//  WVRSQLiveListModel.m
//  WhaleyVR
//
//  Created by qbshen on 2016/11/21.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRSQLiveListModel.h"
#import "WVRHttpLiveList.h"

@interface WVRSQLiveListModel ()

@property (nonatomic) NSArray * originArray;

@end


@implementation WVRSQLiveListModel

#pragma http movie
-(void)http_recommendPageDetail:(void(^)(NSArray*))successBlock failBlock:(void(^)(NSString*))failBlock
{
    WVRHttpLiveList  * cmd = [WVRHttpLiveList new];
    
    cmd.successedBlock = ^(WVRHttpLiveListParentModel* args){
        [self httpPageDetailSuccessBlock:args successBlock:^(NSArray *args) {
            successBlock(args);
        }];
    };
    
    cmd.failedBlock = ^(id args){
        if ([args isKindOfClass:[NSString class]]) {
            failBlock(args);
        }
    };
    [cmd execute];
}

-(void)httpPageDetailSuccessBlock:(WVRHttpLiveListParentModel* )args successBlock:(void(^)(NSArray*))successBlock
{
    NSMutableArray * originArray = [NSMutableArray array];
    for (WVRHttpLiveDetailModel* item in args.data) {
        
        [originArray addObject:[self parseLiveDetail:item]];
    }
    successBlock(originArray);
}

- (WVRSQLiveItemModel *)parseLiveDetail:(WVRHttpLiveDetailModel *)item
{
    WVRSQLiveItemModel* iModel = [[WVRSQLiveItemModel alloc] init];
    
    iModel.code = item.code;
    iModel.linkArrangeValue = item.code;
    iModel.linkArrangeType = LINKARRANGETYPE_LIVE;
    iModel.name = item.displayName;
    iModel.thubImageUrl = item.pic;
    iModel.address = item.address;
    iModel.subTitle = item.subtitle;
    iModel.liveStatus = [item.liveStatus integerValue];
    iModel.beginTime = item.beginTime;
    iModel.guests = [self parseGuests:item.guests];
    iModel.liveMediaDtos = [self parseMediaDtos:item.liveMediaDtos];
    
    iModel.mediaDtos = item.liveMediaDtos;
    
    iModel.viewCount = item.stat.viewCount;
    iModel.playCount = item.stat.playCount;
    iModel.type = item.type;
    iModel.videoType = item.videoType;
    iModel.programType = item.programType;
    iModel.isDanmu = item.isDanmu;
    iModel.isLottery = item.isLottery;
    iModel.payType = item.payType;
    iModel.radius = item.radius;
    
    iModel.couponDto = item.couponDto;
    iModel.contentPackageQueryDtos = item.contentPackageQueryDtos;
    
    if (item.liveOrdered) {
        iModel.hasOrder = [NSString stringWithFormat:@"%d", item.liveOrdered];
    } else {
        iModel.hasOrder = item.hasOrder;
    }
    iModel.isChargeable = item.isChargeable;
    iModel.price = item.price;
    iModel.liveOrderCount = item.liveOrderCount;
    iModel.timeLeftSeconds = item.timeLeftSeconds;
    iModel.behavior = item.behavior;
    
    return iModel;
}

- (NSArray *)parseGuests:(NSArray *)data {
    
    NSMutableArray * guests = [NSMutableArray array];
    for (WVRHttpGuestModel* cur in data) {
        WVRSQLiveGuestModel * guest = [WVRSQLiveGuestModel new];
        guest.guestName = cur.guestName;
        guest.guestPic = cur.guestPic;
        [guests addObject:guest];
    }
    return guests;
}

- (NSArray *)parseMediaDtos:(NSArray *)data
{
    NSMutableArray * guests = [NSMutableArray array];
    for (WVRMediaDto *cur in data) {
        WVRSQLiveMediaModel * media = [WVRSQLiveMediaModel new];
//        media.code = cur.code;
        media.playUrl = cur.playUrl;
        media.resolution = cur.resolution;
        media.renderType = cur.renderType;
        media.cameraStand = cur.source;
        media.definition = cur.curDefinition;
        
        [guests addObject:media];
    }
    return guests;
}

@end
