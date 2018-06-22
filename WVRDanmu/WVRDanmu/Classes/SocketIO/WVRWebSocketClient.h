//
//  WVRWebSocketClient.h
//  WhaleyVR
//
//  Created by qbshen on 2017/5/6.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WVRWebSocketConfig.h"
@class WVRWebSocketMsg;

typedef NS_ENUM(NSInteger, WVRWebSocketClientStatus) {
    WVRWebSocketClientStatusClose,
    WVRWebSocketClientStatusOpen,
};


@interface WVRWebSocketClient : NSObject

+ (instancetype)shareInstance;

@property (nonatomic, assign, readonly) WVRWebSocketClientStatus gSocketStatus;

- (void)connectWithConfig:(WVRWebSocketConfig *)config showMsgBlock:(void(^)(WVRWebSocketMsg *msg))receiveMsgCallback;

- (void)sendTextMsg:(NSString *)msg successBlock:(void(^)())successBlock;

- (void)closeWithProgramId:(NSString *)programId;

- (void)authAfterLogin;

@end
