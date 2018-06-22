//
//  WVRSmallPlayerView.h
//  WhaleyVR
//
//  Created by qbshen on 2017/2/15.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WVRPlayerHelper.h"
#import "WVRSmallPlayerBottomToolView.h"
#import "WVRSlider.h"

#import "WVRFullSPlayerBottomToolView.h"
#import "WVRPlayerLoadingView.h"
#import "WVRPlayerTopToolView.h"
#import "WVRPlayerLeftToolView.h"
#import "WVRPlayerRightToolView.h"
#import "WVRUMShareView.h"

#import "WVRPlayerPresenterProtocol.h"

#import "WVRItemModel.h"

//暂时把WVRSmallPlayerView当作presenter来用，后面拆分出来
@interface WVRSmallPlayerViewPresenter : UIView<WVRPlayerPresenterProtocol, WVRPlayerHelperDelegate, WVRSmallPlayerTVDelegate, WVRSliderDelegate, WVRPlayerTopToolVDelegate, WVRPlayerLeftToolVDelegate, WVRPlayerRightToolVDelegate>

//@property (nonatomic,weak) UIViewController * controller;

@property (nonatomic, weak) WVRMediaModel * mCurMediaModel;

//@property (nonatomic) NSString * HDPlayUrl;

@property (nonatomic) NSString * videoId;

/// 此model为编排或推荐中传值过来的，包含url解析等数据
@property (nonatomic) WVRItemModel* itemModel;

/// 由WVRSmallPlayerPresenter传值，数据为网络请求，对应详情页数据
@property (nonatomic, weak) WVRItemModel *detailBaseModel;

/// 新增需求，是否为足球类型
@property (nonatomic, assign) BOOL isFootball;

@property (nonatomic) WVRSmallPlayerBottomToolView * mSmallPlayerToolV;
@property (nonatomic) WVRFullSPlayerBottomToolView * mFullSPlayToolV;
@property (nonatomic) WVRPlayerLoadingView * mLoadingV;
@property (nonatomic) WVRPlayerTopToolView * mTopToolV;
@property (nonatomic) WVRPlayerLeftToolView * mLeftToolV;
@property (nonatomic) WVRPlayerRightToolView * mRightToolV;
@property (nonatomic) id<WVRPlayerToolVProtocol>  mBottomToolV;

@property (nonatomic) WVRSmallPlayerViewType type;

@property (nonatomic) NSTimer * mToolUpdateTimer;
@property (nonatomic) NSTimer * mNetSpeedUpdateTimer;
@property (nonatomic) CGRect mOriginFrame;
@property (nonatomic, weak) UIView * mParentV;
@property (nonatomic) UITapGestureRecognizer * mTapG;
@property (nonatomic) BOOL isClockScreen;

- (void)restartForLaunch;

@end
