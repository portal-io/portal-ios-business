//
//  WVRPlayerModel.h
//  WhaleyVR
//
//  Created by qbshen on 2017/3/8.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRSQLiveItemModel.h"
#import "WVRVideoEntity.h"

@interface WVRLiveShowModel : WVRSQLiveItemModel

@property (nonatomic, copy) NSString * roomId;

@end


@interface WVRLaunchModel : WVRItemModel

@property (nonatomic) WVRRenderType _renderType;

@property (nonatomic, copy) NSString * defiKey;
@property (nonatomic, copy) NSString * renderTypeStr;

@property (nonatomic, assign) WVRStreamType streamType;

@property (nonatomic, strong) NSDictionary<NSString*, NSString*> * playUrlDic;

@property (nonatomic) long position;
@property (nonatomic) long videoDuration;

- (void)setIsFootball:(BOOL)isFootball;

@end
