//
//  WVRPlayerLeftToolView.h
//  WhaleyVR
//
//  Created by qbshen on 2017/2/17.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRPlayerToolVProtocol.h"

@protocol WVRPlayerLeftToolVDelegate <NSObject>

- (void)clockBtnOnClick:(UIButton*)sender;

@end


@interface WVRPlayerLeftToolView : UIView<WVRPlayerToolVProtocol>

@property (nonatomic) id<WVRPlayerLeftToolVDelegate> clickDelegate;

- (void)updateClockStatus:(BOOL)isClock;

@end
