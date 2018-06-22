//
//  WVRManualArrangeViewCProtocol.h
//  WhaleyVR
//
//  Created by qbshen on 2017/7/21.
//  Copyright © 2017年 Snailvr. All rights reserved.
//


#import "WVRCollectionViewProtocol.h"

@class UICollectionView;

@protocol WVRManualArrangeViewCProtocol <WVRCollectionViewProtocol>

- (UICollectionView*)getCollectionView;

- (void)scrollDidScrollingBlock:(CGFloat)y;

@end
