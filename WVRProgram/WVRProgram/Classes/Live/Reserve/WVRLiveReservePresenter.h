//
//  WVRReserveController.h
//  WhaleyVR
//
//  Created by qbshen on 2016/12/7.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "SQBaseCollectionPresenter.h"

@interface WVRLiveReservePresenter : SQBaseCollectionPresenter

+ (instancetype)createPresenter:(id)createArgs;

- (UIView *)getView;

@end
