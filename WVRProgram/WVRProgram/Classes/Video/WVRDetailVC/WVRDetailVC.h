//
//  WVRDetailVC.h
//  WhaleyVR
//
//  Created by Snailvr on 16/9/9.
//  Copyright © 2016年 Snailvr. All rights reserved.
//
// 详情页基类，请勿直接使用

#import <UIKit/UIKit.h>
#import "WVRUIEngine.h"
#import "WVRItemModel.h"

#import "WVRDetailFooterView.h"
#import "WVRPlayerTool.h"

#import "WVRSQLiteManager.h"

#import "WVRUMShareView.h"
#import "WVRPlayerHelper.h"

#import "WVRDetailBottomVTool.h"

#import "WVRNavigationBar.h"

#import "WVRPlayerUIManager.h"

@class WVRVideoEntity;

@interface WVRDetailVC : UIViewController

@property (nonatomic, strong) WVRDetailNavigationBar *bar;
@property (nonatomic, copy) NSString *sid;                          // linkArrangeValue、code

- (void)buildData;
- (void)drawUI;
- (void)navBackSetting;
- (void)navShareSetting;
- (void)recordHistory;

#pragma mark - download

@property (nonatomic, strong) WVRItemModel *detailBaseModel;

@property (nonatomic, weak  ) UIButton  *downloadBtn;

@property (nonatomic, strong) NSArray   *parserdURLList;

@property (nonatomic, assign) BOOL isCharged;                // 已付费

@property (nonatomic, strong) WVRPlayerHelper *vPlayer;

@property (nonatomic, strong, readonly) WVRPlayerUIManager *playerUI;

/// 是否为足球
@property (nonatomic, assign) BOOL isFootball;


#pragma mark - player

@property (strong, nonatomic) WVRVideoEntity *videoEntity;

@property (nonatomic, weak) UIView *playerContentView;
@property (nonatomic, assign) NSInteger errorCode;

//@property (nonatomic, assign) BOOL isGoCache;

@property (nonatomic, assign) long curPosition;

- (void)startToPlay;        // 暴露给子类的方法，调用之前要先给videoEntity赋值
- (void)actionResume;
- (void)actionPause;
- (void)actionGotoBuy;

- (void)purchaseBtnHideWithAnimation;

// 子类实现上传次数方法
- (void)uploadViewCount;
- (void)uploadPlayCount;


- (void)leftBarButtonClick;
- (void)rightBarShareItemClick;

// 电视剧 播放失败后尝试另外一个URL
- (BOOL)reParserPlayUrl;

- (void)playNextVideo;      // 电视剧，自动播放下一个

//- (NSInteger)playerStatus;
//- (long)totalPosition;
//- (void)showLoadingView;
//- (void)hidenLoadingView;

- (void)watch_online_record:(BOOL)isComin;

@end
