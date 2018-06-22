//
//  WVRTVDetailBaseController.h
//  WhaleyVR
//
//  Created by qbshen on 2017/1/11.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRDetailVC.h"
#import "WVRTVDetailView.h"
#import "WVRTVVideoDetailModel.h"
#import "WVRCollectionVCModel.h"
#import "WVRNetErrorView.h"
//#import "WVRLoginTool.h"

@interface WVRTVDetailBaseController : WVRDetailVC<WVRTVDetailViewDelegate>

@property (nonatomic) WVRTVItemModel* createArgs;

@property (nonatomic) WVRTVDetailView* mtvDetailV;
@property (nonatomic) WVRTVVideoDetailModel * mDetailModel;

@property (nonatomic) WVRTVItemModel * httpItemModel;

@property (nonatomic) WVRNetErrorView * mErrorView;

- (void)networkFaild:(NSString*)errMsg;
- (void)requestInfo;
- (void)requestCollectionStatus;
- (void)loadSubView:(WVRTVItemModel*)itemModel;

- (void)valuationForVideoEntityWithModel:(WVRTVItemModel *)model;

- (WVRTVItemModel *)shouldCollectionModel;

@end
