//
//  WVRWebSocketStatusHandle.m
//  WhaleyVR
//
//  Created by qbshen on 2017/5/22.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRWebSocketStatusHandle.h"
#import "WVRWebSocketPrepare.h"

@interface WVRWebSocketStatusHandle ()

@property (nonatomic, strong) WVRWebSocketPrepare * gSocketPrepare;

@property (nonatomic, assign) BOOL gIsComin;
@property (nonatomic, assign) BOOL gIsAuth;
@property (nonatomic, assign) BOOL gIsGuestAuth;

@end

@implementation WVRWebSocketStatusHandle

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.gSocketPrepare = [WVRWebSocketPrepare new];
        self.gSocketPrepare.delegate = self;
    }
    return self;
}

-(void)prepareForConnect:(WVRWebSocketConfig*)config
{
    [self.gSocketPrepare defaultAuth:config];
}

-(BOOL)canSendMsg
{
    return (self.gIsComin&self.gIsAuth)||(self.gIsComin&self.gIsGuestAuth);
}

-(void)cominStatus:(BOOL)success
{
    self.gIsComin = success;
    [self trySendMsg];
}

-(void)authStatus:(BOOL)success
{
    self.gIsAuth = success;
    [self trySendMsg];
}

-(void)guestAuthStatus:(BOOL)success
{
    self.gIsGuestAuth = success;
}


-(void)trySendMsg
{
    if ([self canSendMsg]) {
        if (self.canConnectSocketBlock) {
            self.canConnectSocketBlock();
        }
    }
}
@end
