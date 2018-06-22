//
//  WVRDetailVC+BottomView.h
//  WhaleyVR
//
//  Created by qbshen on 2017/1/16.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRTVItemModel.h"
#import "WVRVideoModel.h"
#import "WVRVideoDetailBottomView.h"

#define HEIGHT_BOTTOMV (105)

@interface WVRDetailBottomVTool : NSObject

@property (nonatomic, copy) void(^startDown)();
/// BI埋点 加入播单成功后执行
@property (nonatomic, copy) void(^didCollection)();

+ (WVRDetailBottomVTool *)loadBottomView:(WVRTVItemModel *)model parentV:(UIView *)parentV;
- (void)updateDownStatus:(WVRVideoDownloadStatus)videoStatus;

// 供外接更新约束
@property (nonatomic) WVRVideoDetailBottomView * mBottomView;

@end
