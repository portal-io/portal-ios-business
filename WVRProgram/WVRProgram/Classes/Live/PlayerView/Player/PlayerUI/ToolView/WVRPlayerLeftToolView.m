//
//  WVRPlayerLeftToolView.m
//  WhaleyVR
//
//  Created by qbshen on 2017/2/17.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRPlayerLeftToolView.h"

@interface WVRPlayerLeftToolView ()

@property (nonatomic) WVRPlayerToolVQuality quality;

- (IBAction)clockBtnOnClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *clockBtn;

@end


@implementation WVRPlayerLeftToolView

- (void)updateFrame:(CGRect)frame
{
    self.frame = frame;
}

- (CGSize)getViewSize
{
    return self.size;
}

- (void)updateClockStatus:(BOOL)isClock
{
    self.clockBtn.selected = isClock;
}

- (void)hiddenV:(BOOL)hidden
{
    self.hidden = hidden;
}

- (BOOL)isHiddenV
{
    return self.hidden;
}

- (WVRPlayerToolVQuality)getQuality
{
    return _quality;
}

- (IBAction)clockBtnOnClick:(id)sender {
    if ([self.clickDelegate respondsToSelector:@selector(clockBtnOnClick:)]) {
        [self.clickDelegate clockBtnOnClick:sender];
    }
}

- (void)updateStatus:(WVRPlayerToolVStatus)status
{
    switch (status) {
        case WVRPlayerToolVStatusDefault:
            
            break;
        case WVRPlayerToolVStatusPrepare:
            
            break;
        case WVRPlayerToolVStatusPlaying:
            
            break;
        case WVRPlayerToolVStatusPause:
            
            break;
        case WVRPlayerToolVStatusStop:
            
            break;
        case WVRPlayerToolVStatusError:
            
            break;

        default:
            break;
    }
}

@end
