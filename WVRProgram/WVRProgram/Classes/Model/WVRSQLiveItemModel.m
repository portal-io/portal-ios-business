//
//  WVRSQLiveItemModel.m
//  WhaleyVR
//
//  Created by qbshen on 2016/12/8.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRSQLiveItemModel.h"

@implementation WVRSQLiveItemModel

- (instancetype)copyNewItemModel {
    
    WVRSQLiveItemModel* itemModel = self;
    
    WVRSQLiveItemModel * cur = [[WVRSQLiveItemModel alloc] init];
    cur.code = itemModel.code;
    cur.name = itemModel.name;
    cur.subTitle = itemModel.subTitle;
    cur.intrDesc = itemModel.intrDesc;
    cur.thubImageUrl = itemModel.thubImageUrl;
    cur.scaleThubImage = itemModel.scaleThubImage;
    cur.linkArrangeType = itemModel.linkArrangeType;
    cur.linkArrangeValue = itemModel.linkArrangeValue;
    cur.unitConut = itemModel.unitConut;
    cur.logoImageUrl = itemModel.logoImageUrl;
    cur.playUrl = itemModel.playUrl;
    cur.duration = itemModel.duration;
    cur.infUrl = itemModel.infUrl;
    cur.infTitle = itemModel.infTitle;
    cur.programType = itemModel.programType;
    cur.type = itemModel.type;
    cur.videoType = itemModel.videoType;
    cur.playCount = itemModel.playCount;
    cur.behavior = itemModel.behavior;
    
    cur.liveStatus = itemModel.liveStatus;
    cur.address = itemModel.address;
    cur.beginTime = itemModel.beginTime;
    cur.guests = itemModel.guests;
    cur.liveMediaDtos = itemModel.liveMediaDtos;
    cur.mediaDtos = itemModel.mediaDtos;
    
    cur.viewCount = itemModel.viewCount;
    cur.hasOrder = itemModel.hasOrder;
    cur.liveOrderCount = itemModel.liveOrderCount;
    cur.startDateFormat = itemModel.startDateFormat;
    cur.isChargeable = itemModel.isChargeable;
    cur.price = itemModel.price;
    cur.contentPackageQueryDtos = itemModel.contentPackageQueryDtos;
    
    return cur;
}

- (NSString *)parseMililiveOrderCount {
    
    return [WVRComputeTool numberToString:self.liveOrderCount.longLongValue];
}

#pragma mark - getter

- (NSString *)tags {
    
    return nil;
}

- (NSArray *)guestPics {
    
    NSMutableArray * pics = [NSMutableArray array];
    for (WVRSQLiveGuestModel * cur in self.guests) {
        [pics addObject:cur.guestPic];
    }
    return pics;
}

- (NSArray *)guestNames {
    
    NSMutableArray * names = [NSMutableArray array];
    for (WVRSQLiveGuestModel * cur in self.guests) {
        [names addObject:cur.guestName];
    }
    return names;
}

- (BOOL)isFootball {
    
    if ([self.type isEqualToString:@"live_football"]) {
        return YES;
    }
    if ([self.contentType isEqualToString:@"live_football"]) {
        return YES;
    }
    return NO;
}

@end


@implementation WVRSQLiveGuestModel

@end


@implementation WVRSQLiveMediaModel

- (NSString *)resolution {
    
    return [_resolution uppercaseString];
}

@end
