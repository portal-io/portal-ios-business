//
//  Target_danmu.m
//  WVRDanmu
//
//  Created by Bruce on 2017/9/13.
//  Copyright © 2017年 snailvr. All rights reserved.
//

#import "Target_danmu.h"
#import "WVRWebSocketClient.h"

@implementation Target_danmu

- (BOOL)Action_nativeConnectIsActive:(NSDictionary *)params {
    
    return ([WVRWebSocketClient shareInstance].gSocketStatus == WVRWebSocketClientStatusOpen);
}

- (void)Action_nativeConnectForDanmu:(NSDictionary *)params {
    
    void(^block)(WVRWebSocketMsg *msg) = params[@"block"];
    
    WVRWebSocketConfig *config = [[WVRWebSocketConfig alloc] init];
    config.programId = params[@"programId"];
    config.programName = params[@"programName"];
    
    [[WVRWebSocketClient shareInstance] connectWithConfig:config showMsgBlock:block];
}

- (void)Action_nativeSendMessage:(NSDictionary *)params {
    
    // @{ @"successBlock":(void(^)()), @"msg":NSString }
    void(^successBlock)() = params[@"successBlock"];
    NSString *msg = params[@"msg"];
    
    [[WVRWebSocketClient shareInstance] sendTextMsg:msg successBlock:successBlock];
}

- (void)Action_nativeCloseForDanmu:(NSDictionary *)params {
    
    NSString *programId = params[@"programId"];
    
    [[WVRWebSocketClient shareInstance] closeWithProgramId:programId];
}

- (void)Action_nativeAuthAfterLogin:(NSDictionary *)params {
    
    [[WVRWebSocketClient shareInstance] authAfterLogin];
}

@end
