//
//  WVRLiveDetailModel.m
//  WhaleyVR
//
//  Created by Snailvr on 2016/11/25.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRLiveDetailModel.h"
#import "WVRWhaleyHTTPManager.h"
#import "YYModel.h"
#import "WVRVideoEntity.h"

@interface WVRLiveDetailModel () {
    
    NSString *_definitionForPlayURL;
}

@end


@implementation WVRLiveDetailModel

#pragma mark - YYModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{ @"contentPackageQueryDtos" : [WVRContentPackageQueryDto class],
              @"guests": [WVRLiveDetailGuest class],
              @"liveMediaDtos" : [WVRMediaDto class],
              @"mediaDtos" : [WVRMediaDto class],
              };
}


+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{ @"Id" : @"id", @"picUrl_" : @"newPicUrl", @"description_" : @"description", @"mediaDtos" : @"liveMediaDtos" };
}

#pragma mark - getter

- (NSString *)tags {
    
    return @"";
}

- (NSString *)playUrl {
    
    // 蘑菇源的链接优先
    
    for (WVRMediaDto *model in self.mediaDtos) {
        if ([model.source isEqualToString:@"Public"] && model.playUrl.length > 0) {
            _definitionForPlayURL = model.curDefinition;
            return model.playUrl;
        }
    }
    
    for (WVRMediaDto *model in self.mediaDtos) {
        if ([model.source isEqualToString:@"vr"] && model.playUrl.length > 0) {
            _definitionForPlayURL = model.curDefinition;
            return model.playUrl;
        }
    }
    
    WVRMediaDto *dto = [self.mediaDtos firstObject];
    _definitionForPlayURL = dto.curDefinition;
    
    return dto.playUrl;
}

- (NSString *)renderType {
    
#if (kAppEnvironmentTest == 1)
    @throw [NSException exceptionWithName:@"error" reason:@"live renderType must with links" userInfo:nil];
#else
    DDLogError(@"live renderType must with links");
    return @"";
#endif
}

- (NSString *)definitionForPlayURL {
    
    if (_definitionForPlayURL.length < 1) {
        [self playUrl];
    }
    return _definitionForPlayURL;
}

- (NSInteger)viewCount { return self.stat.viewCount; }

- (NSString *)playCount { return [NSString stringWithFormat:@"%ld", self.stat.playCount]; }

- (NSInteger)playSeconds { return self.stat.playSeconds; }

- (NSString *)title { return self.displayName; }

- (NSString *)introduction { return self.description_; }

//- (NSString *)webURL {  }

- (NSString *)sid { return self.code; }

- (NSString *)intrDesc { return self.description_; }

- (NSString *)address { return _address; }


- (BOOL)isFootball {
    
    if ([self.type isEqualToString:@"live_football"]) {
        return YES;
    }
    if ([self.contentType isEqualToString:@"live_football"]) {
        return YES;
    }
    return NO;
}

+ (void)requestForLiveDetailWithCode:(NSString *)sid block:(void(^)(WVRLiveDetailModel *responseObj, NSError *error))block {
    
    if (!sid.length) {
        DDLogError(@"requestForLiveDetailWithCode: sid为空");
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", kAPI_SERVICE, @"liveProgram/findByCode"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"code"] = sid;
    if ([WVRUserModel sharedInstance].accountId.length > 0) {
        dict[@"uid"] = [WVRUserModel sharedInstance].accountId;
    }
    
    [WVRWhaleyHTTPManager GETService:urlStr withParams:dict completionBlock:^(id responseObj, NSError *error) {
        
        if (error) {
            
            block(nil, error);
            
        } else {
            NSDictionary *dict = responseObj;
            int code = [dict[@"code"] intValue];
            NSString *msg = [NSString stringWithFormat:@"%@", dict[@"msg"]];
            NSDictionary *dataDic = dict[@"data"];
            
            if (dataDic) {
                
                WVRLiveDetailModel *model = [WVRLiveDetailModel yy_modelWithDictionary:dataDic];
                
                block(model, nil);
                
            } else {
                NSError *err = [NSError errorWithDomain:msg code:code userInfo:nil];
                block(nil, err);
            }
        }
    }];
}

@end


@implementation WVRLiveDetailStat

@end


@implementation WVRLiveDetailGuest

@end
