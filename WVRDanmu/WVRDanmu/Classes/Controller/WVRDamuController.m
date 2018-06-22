//
//  WVRDamuController.m
//  WVRDanmu
//
//  Created by Bruce on 2017/9/19.
//  Copyright © 2017年 snailvr. All rights reserved.
//

#import "WVRDamuController.h"
#import "WVRDanmuListView.h"

@interface WVRDamuController ()

@property (nonatomic, weak) WVRDanmuListView *danmuListView;

/**
 轮询弹幕开关
 */
@property (nonatomic, strong) NSTimer *timer;

@end


@implementation WVRDamuController

#pragma mark - WVRPlayerUIProtocol

- (BOOL)addControllerWithParams:(NSDictionary *)params {
    
    return NO;
}

- (void)PauseController {
    
}

- (void)removeController {
    
}

- (unsigned long)priority {
    
    return 1;
}

- (WVRPlayerUIEventCallBack *)dealWithEvent:(WVRPlayerUIEvent *)event {
    
    NSString *selName = [event.name stringByAppendingString:@":"];
    SEL sel = NSSelectorFromString(selName);
    
    // 不支持此方法，则返回nil
    if (![self respondsToSelector:sel]) { return nil; }
    
    [self performSelector:sel withObject:event.params];
    
    WVRPlayerUIEventCallBack *callback = [[WVRPlayerUIEventCallBack alloc] init];
    callback.isIntercept = YES;
    
    return callback;
}


@end
