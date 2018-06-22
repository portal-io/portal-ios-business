//
//  WVRManualArrangePresenter.h
//  WhaleyVR
//
//  Created by qbshen on 2017/7/21.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRPresenter.h"
#import "WVRManualArrangeViewCProtocol.h"

@interface WVRManualArrangePresenter : WVRPresenter

@property (nonatomic, weak, readonly) id<WVRManualArrangeViewCProtocol> gView;

@property (nonatomic, strong, readonly) id args;

- (NSArray *)iconStrs;

@end
