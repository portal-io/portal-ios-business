//
//  WVRLiveRecSubBannerCell.m
//  WhaleyVR
//
//  Created by qbshen on 2017/2/15.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRLiveRecReBannerCell.h"
#import "WVRLiveRecReBannerPresenter.h"

@interface WVRLiveRecReBannerCell ()

@property (nonatomic) WVRLiveRecReBannerPresenter * mRBP;

@end
@implementation WVRLiveRecReBannerCell


-(void)awakeFromNib
{
    [super awakeFromNib];
    if (!self.mRBP) {
        self.mRBP = [WVRLiveRecReBannerPresenter createPresenter:nil];
    }
    UIView * view = [self.mRBP getView];
    [self addSubview:view];
}

-(void)fillData:(SQBaseCollectionViewInfo *)info
{
    WVRLiveRecReBannerCellInfo* cellInfo = (WVRLiveRecReBannerCellInfo*)info;
    [self.mRBP setFrameForView:CGRectMake(fitToWidth(10.f), 0, self.width-fitToWidth(10.f)*2, self.height)];
    self.mRBP.itemModel = cellInfo.itemModel;
    self.mRBP.controller = cellInfo.controller;
    [self.mRBP reloadData];
}


@end

@implementation WVRLiveRecReBannerCellInfo

@end
