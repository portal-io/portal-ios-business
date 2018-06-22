//
//  WVRSearchCell.h
//  WhaleyVR
//
//  Created by qbshen on 2017/1/9.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "SQTableViewDelegate.h"
#import "WVRItemModel.h"

@interface WVRSearchCellInfo : SQBaseTableViewInfo

@property (nonatomic) WVRItemModel * itemModel;

@end
@interface WVRSearchCell : SQBaseTableViewCell

@end
