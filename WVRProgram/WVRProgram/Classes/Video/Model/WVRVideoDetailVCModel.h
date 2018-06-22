//
//  WVRVideoDetailVCModel.h
//  VRManager
//
//  Created by Snailvr on 16/6/24.
//  Copyright © 2016年 Snailvr. All rights reserved.

// 全景视频/华数3D电影详情页Model

#import "WVRItemModel.h"
#import "WVRMediaDto.h"
#import "WVRAPIManagerDataReformer.h"
@class WVRStat, WVRDownloadDto;


@interface WVRVideoDetailDataReformer : NSObject <WVRAPIManagerDataReformer>

@end


@interface WVRVideoDetailVCModel : WVRItemModel

- (NSArray *)tags_;
- (NSString *)downloadUrl;

- (NSString *)playUrl;
- (NSInteger)viewCount;
- (NSInteger)playSeconds;
- (NSString *)introduction;
- (NSString *)webURL;
- (NSArray *)playUrlArray;

@property (nonatomic, copy) NSString *age;

@property (nonatomic, copy) NSString *curEpisode;
@property (nonatomic, copy) NSString *descriptionStr;

@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *language;

@property (nonatomic, strong) WVRStat *stat;

@property (nonatomic, strong) NSArray<WVRDownloadDto *> *downloadDtos;

@property (nonatomic, copy) NSString *pubStatus;
@property (nonatomic, copy) NSString *publishTime;

@property (nonatomic, copy) NSString *smallPic;
@property (nonatomic, copy) NSString *lunboPic;

@property (nonatomic, copy) NSString *bigPic;
@property (nonatomic, copy) NSString *vipPic;

@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *superscript;
@property (nonatomic, copy) NSString *tagCode;
@property (nonatomic, copy) NSString *totalEpisode;
@property (nonatomic, copy) NSString *typeName;

@property (nonatomic, assign) int isFollow;
@property (nonatomic, copy) NSString *cpCode;
@property (nonatomic, assign) long fansCount;
@property (nonatomic, copy) NSString *headPic;

@end


@interface WVRStat : NSObject

@property (nonatomic, assign) NSInteger viewCount;
@property (nonatomic, assign) NSInteger playCount;
@property (nonatomic, assign) NSInteger playSeconds;
@property (nonatomic, copy) NSString *programType;
@property (nonatomic, copy) NSString *srcCode;
@property (nonatomic, copy) NSString *srcDisplayName;
@property (nonatomic, copy) NSString *videoType;

@end


@interface WVRDownloadDto : NSObject

@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, copy) NSString *downloadUrl;
@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *parentCode;
@property (nonatomic, copy) NSString *prefer;
@property (nonatomic, copy) NSString *publishTime;
@property (nonatomic, copy) NSString *renderType;
@property (nonatomic, copy) NSString *resolution;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *threedType;
@property (nonatomic, copy) NSString *updateTime;
@property (nonatomic, copy) NSString *videoType;

@end

