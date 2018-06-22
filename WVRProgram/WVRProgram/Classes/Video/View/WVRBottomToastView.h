//
//  WVRBottomToastView.h
//  WhaleyVR
//
//  Created by qbshen on 16/11/8.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WVRBottomToastViewInfo :NSObject

@property (nonatomic) NSString* title;
@property (nonatomic, copy) void(^dismissBlock)();

@end


@interface WVRBottomToastView : UIView

- (void)updateWithInfo:(WVRBottomToastViewInfo *)info;

@end
