
//
//  WVRLivePlayerTopToolView.m
//  WhaleyVR
//
//  Created by qbshen on 2017/2/20.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRLivePlayerTopToolView.h"

@interface WVRLivePlayerTopToolView ()



@property (nonatomic) CGFloat mSelfHeight;

@end


@implementation WVRLivePlayerTopToolView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
}

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    
//}

- (void)resetWithTitle:(NSString *)title curWatcherCount:(NSString *)watchCount {
    
    [_liveTitleView removeFromSuperview];
    WVRLiveTitleView *titleV = [[WVRLiveTitleView alloc] initWithFrame:self.bounds title:title watchCount:[watchCount integerValue] iconUrl:nil];
    titleV.height = fitToWidth(HEIGHT_DEFAULT);
    [self insertSubview:titleV atIndex:0];
    
    _liveTitleView = titleV;
    WVRLotteryBoxView *box = [[WVRLotteryBoxView alloc] initWithFrame:CGRectMake(self.liveTitleView.x, self.liveTitleView.bottomY + fitToWidth(20.f), fitToWidth(160.f), fitToWidth(60.f))];
    
    [self addSubview:box];
    _box = box;
}

-(CGSize)getViewSize
{
    return CGSizeMake(SCREEN_WIDTH, fitToWidth(140.f));
}

-(void)updateStatus:(WVRPlayerToolVStatus)status
{
    switch (status) {
        case WVRPlayerToolVStatusDefault:
            
            break;
        case WVRPlayerToolVStatusPrepare:
            
            break;
        case WVRPlayerToolVStatusPlaying:
            
            break;
        case WVRPlayerToolVStatusPause:
            
            break;
        case WVRPlayerToolVStatusStop:
            
            break;
        case WVRPlayerToolVStatusError:
            
            break;
       
        default:
            break;
    }
}


@end
