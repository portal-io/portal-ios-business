//
//  WVRSmallPlayerToolView.h
//  WhaleyVR
//
//  Created by qbshen on 2017/2/15.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRPlayerToolVProtocol.h"

#define HEIGHT_DEFAULT (50.f)

@class WVRSlider;

@protocol WVRSmallPlayerTVDelegate <NSObject>

- (void)playBtnOnClick:(UIButton*)playBtn;

- (void)fullBtnOnClick:(UIButton*)fullBtn;

- (void)launchBtnOnClick:(UIButton*)launchBtn;

- (void)sliderDragEnd:(UISlider*)slider;

- (void)chooseQuality;

// 足球多机位
- (void)actionChangeCameraStand:(NSString *)standType;

- (NSArray<NSDictionary *> *)actionGetCameraStandList;

@end


@interface WVRSmallPlayerBottomToolView : UIView<WVRPlayerToolVProtocol>

@property (nonatomic,weak) id<WVRSmallPlayerTVDelegate> clickDelegate;

@property (weak, nonatomic) IBOutlet UIButton *startBtn;

@property (weak, nonatomic) IBOutlet UIButton *fullBtn;

@property (weak, nonatomic) IBOutlet UIButton *launchBtn;

@property (weak, nonatomic) IBOutlet WVRSlider *processSlider;

@property (weak, nonatomic) IBOutlet UILabel *curTimeL;

@property (weak, nonatomic) IBOutlet UILabel *totalTimeL;

- (void)fullBtnOnClick:(UIButton *)sender;

@end
