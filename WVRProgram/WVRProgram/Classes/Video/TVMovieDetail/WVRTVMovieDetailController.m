//
//  WVRTVMovieDetailController.m
//  WhaleyVR
//
//  Created by qbshen on 2017/1/9.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRTVMovieDetailController.h"
#import "WVRTVVideoDetailModel.h"
#import "WVRTVDetailView.h"
#import "WVRCollectionVCModel.h"
//#import "WVRLoginTool.h"

@interface WVRTVMovieDetailController ()<WVRTVDetailViewDelegate>

@end


@implementation WVRTVMovieDetailController

#pragma mark - life cycle

+ (instancetype)createViewController:(id)createArgs
{
    WVRTVMovieDetailController * vc = [[WVRTVMovieDetailController alloc] init];
    vc.view.backgroundColor = [UIColor whiteColor];
    vc.createArgs = createArgs;
    [vc requestInfo];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self navBackSetting];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - request

- (void)requestInfo
{
    [super requestInfo];
    self.sid = self.createArgs.linkArrangeValue;
    if (!self.mDetailModel) {
        self.mDetailModel = [WVRTVVideoDetailModel new];
    }
    SQShowProgress;
    kWeakSelf(self);
    [self.mDetailModel http_detailWithCode:self.createArgs.linkArrangeValue successBlock:^(WVRTVItemModel *itemModel) {
        [weakself moviehttpSuccessBlock:itemModel];
    } failBlock:^(NSString *errMsg) {
        [weakself networkFaild:errMsg];
    }];
}

- (void)moviehttpSuccessBlock:(WVRTVItemModel*)itemModel
{
    self.httpItemModel = itemModel;
    // 是电影的时候，没有parentCode，把code赋值给parentCode以便收藏电影使用
    self.httpItemModel.parentCode = self.httpItemModel.code;
    self.httpItemModel.programType = self.createArgs.programType;
    self.httpItemModel.linkArrangeType = self.createArgs.linkArrangeType;
    [self requestCollectionStatus];
    [self loadSubView:self.httpItemModel];
}


@end
