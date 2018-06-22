//
//  WVRPlayerUILiveManager.h
//  WhaleyVR
//
//  Created by Bruce on 2017/8/22.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRPlayerUIManager.h"
#import "WVRPlayerViewLive.h"
#import "WVRDanmuListView.h"
#import "WVRLotteryBoxView.h"
#import "WVRLiveTitleView.h"
#import "WVRLiveTextField.h"

@protocol WVRPlayerUILiveManagerDelegate <NSObject>

@required
- (void)actionEasterEggLottery;
- (void)actionGoGiftPage;
- (BOOL)actionCheckLogin;
- (void)actionGoRedeemPage;

- (void)shareBtnClick:(UIButton *)sender;

- (void)vrModeBtnClick:(UIButton *)sender;
- (void)actionSendDanmu:(NSString *)text;

@end


@interface WVRPlayerUILiveManager : WVRPlayerUIManager

@property (nonatomic, weak) id<WVRPlayerUILiveManagerDelegate> uiLiveDelegate;

/// 当前播放器的主要交互控件
- (WVRPlayerViewLive *)playerView;

/// 播放器交互控件附加组件
@property (nonatomic, weak) WVRDanmuListView *danmu;

/// 播放器交互控件附加组件
@property (nonatomic, weak) WVRLiveTextField *textField;

/// 播放器交互控件附加组件
@property (nonatomic, weak) WVRLotteryBoxView *box;

- (void)execKeyboardOn:(BOOL)isOn keyboardHeight:(float)height animateTime:(float)time;

#pragma mark - exec function - playerView

- (void)execDanmuReceived:(NSArray *)array;
- (void)execPlayCountUpdate:(long)playCount;

- (void)execNetworkStatusChanged;

- (void)execEasterEggCountdown:(long)time;
- (void)execLotterySwitch:(BOOL)isOn;
- (void)execDanmuSwitch:(BOOL)isOn;
- (void)execLotteryResult:(NSDictionary *)dict;

#pragma mark - textField


- (void)setResignFirstResponder;
- (void)setVisibel:(BOOL)isVasibel;

- (void)changeToKeyboardOnStatu:(BOOL)isKeyboardOn;
- (void)keyboardAnimatoinDoneWithStatu:(BOOL)isKeyboardOn;

- (void)changeDanmuSwitchStatus:(BOOL)isOn;

- (void)updateDefiTitle:(NSString *)kDefi;

@end
