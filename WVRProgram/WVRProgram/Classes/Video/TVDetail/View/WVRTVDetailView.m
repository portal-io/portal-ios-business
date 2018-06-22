//
//  WVRTVDetailView.m
//  WhaleyVR
//
//  Created by qbshen on 2017/1/4.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRTVDetailView.h"
#import "WVRHalfScreenPlayView.h"
#import "WVRTVDetailCollectionView.h"
#import "WVRVideoDetailBottomView.h"

@interface WVRTVDetailView ()<WVRVideoDBottomViewDelegate,WVRTVDetailCVDelegate>

@property (nonatomic) WVRTVDetailCollectionView * mCollectionV;
@property (nonatomic) WVRVideoDetailBottomView * mBottomV;
@end


@implementation WVRTVDetailView

+ (instancetype)createWithInfo:(WVRTVDetailViewInfo *)vInfo
{
    WVRTVDetailView * pageV = [[WVRTVDetailView alloc] initWithFrame:vInfo.frame withVInfo:vInfo];
    return pageV;
}

- (instancetype)initWithFrame:(CGRect)frame withVInfo:(WVRTVDetailViewInfo *)vInfo
{
    self = [super initWithFrame:frame];
    if (self) {
        WVRHalfScreenPlayViewInfo * halfVInfo = [WVRHalfScreenPlayViewInfo new];
        halfVInfo.frame = CGRectMake(0, 0, self.width, self.width * 11 / 18.f);
        WVRHalfScreenPlayView * halfPlayV = [WVRHalfScreenPlayView createWithInfo:halfVInfo];
        halfPlayV.backgroundColor = [UIColor blackColor];
        [self addSubview:halfPlayV];
        _halfScreenPlayView = halfPlayV;
        
        WVRVideoDetailBottomView * bottomV = [[WVRVideoDetailBottomView alloc] init];
        bottomV.y = self.height - bottomV.height;
        bottomV.width = self.width;
        [bottomV updateDownBtnStatus:WVRVideoDBottomVDownStatusNeedCharge];
        [bottomV updateCollectionDone:vInfo.itemModel.haveCollection];
        bottomV.delegate = self;
        self.mBottomV = bottomV;
        [self addSubview:bottomV];
        
        WVRTVDetailCollectionViewInfo * collectionVInfo = [WVRTVDetailCollectionViewInfo new];
        collectionVInfo.frame = CGRectMake(0, halfPlayV.height, self.width, self.height-halfPlayV.height-bottomV.height);
        collectionVInfo.itemModel = vInfo.itemModel;
        WVRTVDetailCollectionView * collectionV = [WVRTVDetailCollectionView createWithInfo:collectionVInfo];
        collectionV.selectDelegate = self;
        collectionV.backgroundColor = [UIColor whiteColor];
        self.mCollectionV = collectionV;
        [self addSubview:collectionV];
        
        [self bringSubviewToFront:halfPlayV];
    }
    return self;
}

- (void)onClickItemType:(WVRVideoDBottomViewType)type bottomView:(WVRVideoDetailBottomView *)view
{
    if ([self.delegate respondsToSelector:@selector(onClickItemType:bottomView:)]) {
        [self.delegate onClickItemType:type bottomView:view];
    }
}

- (void)didSelectItem:(WVRTVItemModel *)itemModel
{
    NSString * str = [NSString stringWithFormat:@"play%@", itemModel.curEpisode];
    DDLogInfo(@"%@",str);
    if ([self.delegate respondsToSelector:@selector(didSelectItemModel:)]) {
        [self.delegate didSelectItemModel:itemModel];
    }
}

-(void)updateCollectionStatus:(BOOL)isCollection
{
    [self.mBottomV updateCollectionDone:isCollection];
}

-(void)selectNextItem
{
    [self.mCollectionV selectNextItem];
}

-(void)reloadData
{
    [self.mCollectionV reloadData];
}

@end


@implementation WVRTVDetailViewInfo

@end
