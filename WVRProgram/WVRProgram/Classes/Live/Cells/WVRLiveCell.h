//
//  WVRLiveCell.h
//  WhaleyVR
//
//  Created by qbshen on 2016/12/7.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "SQCollectionViewDelegate.h"

@class WVRSQLiveItemModel;

@interface WVRLiveCellInfo : SQCollectionViewCellInfo

@property (nonatomic) WVRSQLiveItemModel* itemModel;

@end


@interface WVRLiveCell : SQBaseCollectionViewCell

@end
