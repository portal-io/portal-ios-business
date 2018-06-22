//
//  WVRPlayerVCTopic.m
//  WhaleyVR
//
//  Created by qbshen on 2017/6/7.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRPlayerVCTopic.h"
#import "WVRVideoEntityTopic.h"
#import "WVRVideoDetailViewModel.h"

@interface WVRPlayerVCTopic () {
    
    WVRVideoEntityTopic *_videoEntity;
}

@property (nonatomic, strong, readonly) WVRVideoDetailViewModel *gVideoDetailViewModel;

@end


@implementation WVRPlayerVCTopic
@synthesize gVideoDetailViewModel = _tmpVideoDetailViewModel;

#pragma mark - setter getter

- (void)setVideoEntity:(WVRVideoEntityTopic *)videoEntity {
    
    _videoEntity = videoEntity;
}

- (WVRVideoEntityTopic *)videoEntity {
    
    return _videoEntity;
}

- (WVRVideoDetailViewModel *)gVideoDetailViewModel {
    
    if (!_tmpVideoDetailViewModel) {
        _tmpVideoDetailViewModel = [[WVRVideoDetailViewModel alloc] init];
    }
    return _tmpVideoDetailViewModel;
}

#pragma mark - overwrite func

- (void)setupRequestRAC {
    
    @weakify(self);
    [[self.gVideoDetailViewModel gSuccessSignal] subscribeNext:^(WVRVideoDetailViewModel *_Nullable x) {
        @strongify(self);
        [self dealWithDetailData:x.dataModel];
    }];
    
    [[self.gVideoDetailViewModel gFailSignal] subscribeNext:^(WVRErrorViewModel *_Nullable x) {
        
        SQToastInKeyWindow(kNetError);
    }];
}

- (void)checkFreeTime {
    
    if (!self.isCharged) {
        
        long time = [self.vPlayer getCurrentPosition] / 1000;
        if (time >= self.detailBaseModel.freeTime) {
            
            [self.vPlayer destroyPlayer];
            [self.playerUI execFreeTimeOverToCharge:self.detailBaseModel.freeTime];
            self.curPosition = 0.1;
            self.vPlayer.dataParam.position = 0;
        }
    }
}

- (void)requestForDetailData {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"code"] = self.videoEntity.sid;
    self.gVideoDetailViewModel.requestParams = dict;
    [self.gVideoDetailViewModel.gDetailCmd execute:nil];
}

- (void)dealWithDetailData:(WVRVideoDetailVCModel *)model {
    
    if (![self.videoEntity isKindOfClass:[WVRVideoEntityTopic class]]) {
        
        _videoEntity = [[WVRVideoEntityTopic alloc] init];
        _videoEntity.sid = model.sid;
        _videoEntity.videoTitle = model.name;
    }
    
    _videoEntity.renderTypeStr = model.renderType;
    
    self.isFootball = [model isFootball];
    
    _videoEntity.biEntity.totalTime = model.duration.intValue;
    
    [super dealWithDetailData:model];
}

- (void)buildInitData {
    if (![WVRReachabilityModel isNetWorkOK]) {
        return;
    }
    [super buildInitData];
}

- (void)registerObserverEvent {
    
}

#pragma mark - timer

- (void)syncScrubber {
    
    [super syncScrubber];
    
    long speed = [[WVRAppModel sharedInstance] checkInNetworkflow];
    if (![self.vPlayer isPlaying]) {
        
        [self.playerUI execDownloadSpeedUpdate:speed];
        
    } else {
        long position = [self.vPlayer getCurrentPosition];
        long buffer = [self.vPlayer getPlayableDuration];
        
        [self.playerUI execPositionUpdate:position buffer:buffer duration:[self.vPlayer getDuration]];
    }
}

@end
