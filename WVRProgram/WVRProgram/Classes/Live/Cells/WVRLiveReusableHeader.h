//
//  WVRLiveReusableHeader.h
//  WhaleyVR
//
//  Created by qbshen on 2016/12/6.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "SQCollectionViewDelegate.h"

@class WVRSQLiveItemModel;
@interface WVRLiveReusableHeaderInfo : SQCollectionViewHeaderInfo

@property (nonatomic) NSArray <WVRSQLiveItemModel*>* itemModels;

@property (nonatomic,copy) void(^livingBlock)();
@property (nonatomic,copy) void(^reserveCalendarBlock)();
@property (nonatomic,copy) void(^reviewBlock)();

@property (nonatomic,copy) void(^itemDidSelectBlock)(NSInteger);

@property (nonatomic) BOOL isRefresh;
@end
@interface WVRLiveReusableHeader : SQBaseCollectionReusableHeader

@end
