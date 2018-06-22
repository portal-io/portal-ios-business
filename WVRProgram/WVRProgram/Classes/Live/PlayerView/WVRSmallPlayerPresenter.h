//
//  WVRSmallPlayerPresenter.h
//  WhaleyVR
//
//  Created by qbshen on 2017/2/15.
//  Copyright © 2017年 Snailvr. All rights reserved.
//


#import "WVRItemModel.h"
#import "WVRPlayerPresenterProtocol.h"

@class WVRMediaModel;

@interface WVRSmallPlayerPresenter : NSObject

+ (instancetype)shareInstance;

@property (nonatomic,weak) UIViewController * controller;

@property (nonatomic, weak) UIView * contentView;
@property (nonatomic) NSString * curPlayUrl;
@property (nonatomic, weak) WVRMediaModel * mCurMediaModel;
//@property (nonatomic) NSString * HDPlayUrl;
@property (nonatomic) NSString * videoId;

@property (nonatomic, strong) WVRItemModel * itemModel;

@property (nonatomic, assign) BOOL isLive;

@property (nonatomic, assign) BOOL prepared;

@property (nonatomic, assign) BOOL shouldPause;

@property (nonatomic, assign) BOOL isLaunch;

- (UIView *)getView;
//- (void)reloadData;

- (void)stop;

- (void)start;

- (void)destroy;

- (void)destroyForLauncher;

- (void)restart;

- (BOOL)isPlaying;
- (BOOL)isPaused;

- (BOOL)canPlay;

- (void)updateCanPlay:(BOOL)canPlay;

- (void)restartForLaunch;

- (void)startPlayWithUrl:(NSString*)url;

- (void)responseCurPage:(NSInteger)pageNumber itemModel:(WVRItemModel *)itemModel contentView:(UIView *)contentView;

@end
