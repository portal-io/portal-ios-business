//
//  WVRLivePlayerCompleteStrategy.m
//  WhaleyVR
//
//  Created by qbshen on 2017/5/23.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRLivePlayerCompleteStrategy.h"
#import "WVRLiveDetailModel.h"
#import "WVRLivePlayerStrategyConfig.h"

@interface WVRLivePlayerCompleteStrategy ()

@property (nonatomic, strong) WVRLivePlayerStrategyConfig * gStrategyConfig;

@property (nonatomic, copy) void(^completeBlock)(void);

@property (nonatomic, copy) void(^restartBlock)(void(^successRestartBlock)(void));

@property (nonatomic, copy) void(^overLimitBlock)(void);

@property (nonatomic, assign) NSInteger gCheckCount;

@property (nonatomic, assign) NSInteger gSec;

@property (nonatomic, assign) BOOL gInvalidTimer;
@property (nonatomic, assign) BOOL gtimerRunning;

@end


@implementation WVRLivePlayerCompleteStrategy

- (instancetype)initWithConfig:(WVRLivePlayerStrategyConfig *)config completeBlock:(void(^)())completeBlock restartBlock:(void(^)(void(^successRestartBlock)(void)))restartBlock overLimitBlock:(void(^)())overLimitBlock {
    
    self = [super init];
    if (self) {
        self.gStrategyConfig = config;
        self.completeBlock = completeBlock;
        self.restartBlock = restartBlock;
        self.overLimitBlock = overLimitBlock;
    }
    return self;
}

- (void)http_liveStatus {
    
    if (!self.gtimerRunning) {
        [self setUpTimer];
    }
    if ([self checkCount]) {
        return;
    }
    self.gCheckCount ++;
    kWeakSelf(self);
    [WVRLiveDetailModel requestForLiveDetailWithCode:self.gStrategyConfig.code block:^(WVRLiveDetailModel *responseObj, NSError *error) {
        
        [weakself http_liveStatusSuccessBlock:responseObj];
    }];
}

- (void)setUpTimer {
    
    self.gInvalidTimer = NO;
    [self runningTimer];
    self.gtimerRunning = YES;
}

- (void)runningTimer {
    
    if (self.gInvalidTimer) {
        return;
    }
    if (self.gSec > 5) {
        [self invalidTimer];
        return;
    }
    kWeakSelf(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"second:%d", (int)weakself.gSec);
        weakself.gSec ++;
        [weakself runningTimer];
    });
}

- (void)invalidTimer {
    
    self.gInvalidTimer = YES;
    self.gtimerRunning = NO;
    self.gSec = 0;
}

- (BOOL)checkCount {
    
    if (self.gCheckCount >= 5) {
        NSLog(@"检查已超过5次");
        if (self.overLimitBlock) {
            self.overLimitBlock();
        }
        return YES;
    } else {
        if (self.gSec < self.gCheckCount) {
            NSLog(@"延时一秒");
            [self performSelector:@selector(http_liveStatus) withObject:nil afterDelay:1];
            return YES;
        }
        return NO;
    }
}

- (void)http_liveStatusSuccessBlock:(WVRLiveDetailModel *)model {
    
    if (model.status != WVRLiveStatusPlaying) {
        NSLog(@"直播已结束");
        if (self.completeBlock) {
            self.completeBlock();
        }
    }else{
        NSLog(@"重新启动播放器");
        if (self.restartBlock) {
            kWeakSelf(self);
            void(^successRestartBlcok)() = ^{
                weakself.gCheckCount = 0;
            };
            self.restartBlock(successRestartBlcok);
        }
    }
}

- (void)resetStatus {
    
    [self invalidTimer];
    self.gCheckCount = 0;
}

@end
