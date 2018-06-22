//
//  WVRSQClassifyCell.h
//  WhaleyVR
//
//  Created by qbshen on 16/11/11.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "SQCollectionViewDelegate.h"
#import "WVRVideoModel.h"

@interface WVRSQClassifyCellInfo : SQCollectionViewCellInfo

@property (nonatomic) WVRVideoModel* videoModel;

@end


@interface WVRSQClassifyCell : SQBaseCollectionViewCell

@end
