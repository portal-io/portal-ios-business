//
//  WVRLiveReserveCell.h
//  WhaleyVR
//
//  Created by qbshen on 2017/2/10.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "SQCollectionViewDelegate.h"
#import "WVRSQLiveItemModel.h"

@interface WVRLiveReserveCellInfo : SQCollectionViewCellInfo
@property (nonatomic) WVRSQLiveItemModel * itemModel;

@property (nonatomic,copy) void(^reserveBlock)(UIButton*);

@end
@interface WVRLiveReserveCell : SQBaseCollectionViewCell

@end
