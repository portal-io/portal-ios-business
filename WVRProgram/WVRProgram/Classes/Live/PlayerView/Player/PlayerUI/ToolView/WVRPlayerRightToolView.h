//
//  WVRPlayerLeftToolView.h
//  WhaleyVR
//
//  Created by qbshen on 2017/2/17.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRPlayerToolVProtocol.h"

@protocol WVRPlayerRightToolVDelegate <NSObject>

- (void)resetBtnOnClick:(UIButton*)sender;

@end


@interface WVRPlayerRightToolView : UIView<WVRPlayerToolVProtocol>

@property (nonatomic, weak) id<WVRPlayerRightToolVDelegate> clickDelegate;

@end
