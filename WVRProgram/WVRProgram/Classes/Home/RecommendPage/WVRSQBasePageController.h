//
//  WVRSQBasePageController.h
//  WhaleyVR
//
//  Created by qbshen on 2016/11/20.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRBaseViewController.h"
#import "WVRSectionModel.h"
#import "WVRGotoNextTool.h"
#import "WVRSQFindUIStyleHeader.h"
#import "SQCollectionView.h"
#import "SQSegmentView.h"
#import "SQPageView.h"
#import "WVRRecommendPageSiteModel.h"
#import "WVRNetErrorView.h"

#define HEIGHT_PAGEVIEW (self.view.frame.size.height-self.mSegmentV.y-self.mSegmentV.height)
#define FRAME_SUB_PAGEVIEW (CGRectMake(0, 0, SCREEN_WIDTH, HEIGHT_PAGEVIEW))


@interface WVRSQBasePageController : WVRBaseViewController<UIScrollViewDelegate>

@property (nonatomic) NSMutableDictionary * sitesDic;
@property (nonatomic) SQSegmentView *mSegmentV;
@property (nonatomic) SQPageView *mPageView;
@property (nonatomic) NSMutableArray * subPageViews;
@property (nonatomic) NSMutableArray * subPageViewDelegates;
@property (nonatomic) NSDictionary * mModelDic;
@property (nonatomic) NSMutableArray * subPageErrorViews;
@property (nonatomic) WVRNetErrorView * mErrorView;

@property (nonatomic) WVRRecommendPageSiteModel * findMoreModel;

@property BOOL isTest;

@property (nonatomic) WVRSectionModel * sectionModel;
@end
