//
//  WVRVideoEntityLive.m
//  WhaleyVR
//
//  Created by Bruce on 2017/5/3.
//  Copyright © 2017年 Snailvr. All rights reserved.
//
// VR直播VideoEntity

#import "WVRVideoEntityLive.h"
#import "WVRLiveDetailModel.h"
#import <SecurityFramework/Security.h>

@implementation WVRVideoEntityLive
@synthesize currentUrlIndex = _currentUrlIndex;
@synthesize parserdUrlModelList = _parserdUrlModelList;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.streamType = STREAM_VR_LIVE;
    }
    return self;
}

#pragma mark - getter

- (NSString *)icon {
    
    return _icon ?: @"";
}

#pragma mark - parserURL

- (void)parserPlayUrl:(complationBlock)complation {
    
    NSMutableArray *arr = [NSMutableArray array];
    
    for (WVRMediaDto *dto in self.mediaDtos) {
        
        NSURL *url = [[self class] playUrlForUrlStr:dto.playUrl needCharge:self.needCharge];
        if (!url) { continue; }
        
        WVRPlayUrlModel *model = [[WVRPlayUrlModel alloc] init];
        model.url = url;
        model.renderType = dto.renderType;
        model.definition = dto.curDefinition;
        model.cameraStand = dto.source;
        
        [arr addObject:model];
    }
    
    _parserdUrlModelList = arr;
    
    if (complation) {
        complation();
    }
}

/**
 直播地址解析(裸流)
 
 @param urlStr 源链接地址
 @param needCharge 是否需要付费
 @return 解析完成的URL对象
 */
+ (NSURL * _Nullable)playUrlForUrlStr:(NSString * _Nonnull)urlStr needCharge:(BOOL)needCharge {
    
    if (urlStr.length < 1) { return nil; }
    
    NSString *playUrl = urlStr;
    if (needCharge) {
        
        Security *secu = [Security getInstance];
        playUrl = [secu Security_StandardDecrypt:playUrl withAlgid:secu.payAlgid];
    }
    
    if (([playUrl hasPrefix:@"rtmp://"] || [playUrl containsString:@".m3u8"]) && [playUrl containsString:@"&flag"]) {
        
        NSArray *tmpArr = [playUrl componentsSeparatedByString:@"&flag"];
        playUrl = [tmpArr firstObject];
    }
    
    NSURL *url = [NSURL URLWithUTF8String:playUrl];
    
    return url;
}

@end
