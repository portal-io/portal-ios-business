//
//  WVRSQArrangeMoreController.h
//  WhaleyVR
//
//  Created by qbshen on 16/11/17.
//  Copyright © 2016年 Snailvr. All rights reserved.

// 专题列表

//#import "SQBaseCollectionViewController.h"
#import "WVRCollectionViewController.h"
#import "WVRManualArrangeViewCProtocol.h"

@class WVRUMShareView;

@interface WVRManualArrangeController : WVRCollectionViewController<WVRManualArrangeViewCProtocol>

//@property (nonatomic) WVRSectionModel * sectionModel;

@property (nonatomic, strong) WVRUMShareView *mShareView;

//- (void)httpRequest;
//
//- (void)httpSuccessBlock:(WVRSectionModel *)args;
//
//- (void)httpFailBlock:(NSString *)args;

@end
