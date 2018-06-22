//
//  WVRPlayerLeftToolView.m
//  WhaleyVR
//
//  Created by qbshen on 2017/2/17.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRPlayerRightToolView.h"

@interface WVRPlayerRightToolView ()

@property (nonatomic,readonly) WVRPlayerToolVQuality quality;

- (IBAction)resetBtnOnClick:(id)sender;

@end


@implementation WVRPlayerRightToolView

- (void)updateFrame:(CGRect)frame {
    
    self.frame = frame;
}

- (CGSize)getViewSize {
    
    return self.size;
}

- (void)hiddenV:(BOOL)hidden {
    
    self.hidden = hidden;
}

- (BOOL)isHiddenV {
    
    return self.hidden;
}

- (WVRPlayerToolVQuality)getQuality {
    
    return _quality;
}

- (IBAction)resetBtnOnClick:(id)sender {
    if ([self.clickDelegate respondsToSelector:@selector(resetBtnOnClick:)]) {
        [self.clickDelegate resetBtnOnClick:sender];
    }
}

- (void)updateStatus:(WVRPlayerToolVStatus)status {
    
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
