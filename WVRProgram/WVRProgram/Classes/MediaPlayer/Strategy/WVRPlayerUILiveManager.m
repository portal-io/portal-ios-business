//
//  WVRPlayerUILiveManager.m
//  WhaleyVR
//
//  Created by Bruce on 2017/8/22.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRPlayerUILiveManager.h"
#import "WVRPlayerViewLive.h"
#import "WVRBlurImageView.h"
#import "WVRDanmuListView.h"

@interface WVRPlayerUILiveManager ()<WVRPlayerViewLiveDelegate, WVRLiveTextFieldDelegate>

@property (nonatomic, assign) BOOL keyboardOn;

@property (nonatomic, weak) UIImageView      *blurImageView;
@property (nonatomic, weak) WVRDanmuListView *danmuListView;

@end


@implementation WVRPlayerUILiveManager

- (UIView *)createPlayerViewWithContainerView:(UIView *)containerView {
    
    // live
    WVRPlayerViewStyle style = WVRPlayerViewStyleLive;
    float height = containerView.height;
    float width = containerView.width;
    CGRect rect = CGRectMake(0, 0, MAX(width, height), MIN(width, height));
    
    NSDictionary *veDict = [[self videoEntity] yy_modelToJSONObject];
    WVRPlayerViewLive *view = [[WVRPlayerViewLive alloc] initWithFrame:rect style:style videoEntity:veDict delegate:self];
    
    [containerView addSubview:view];
    self.playerView = view;
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.top.equalTo(@0);
        make.size.equalTo(view.superview);
    }];
    
    [self createTextFieldWithContainerView:[self playerView]];
    [self createBlurBackgroundWithContainerView:containerView];
    [self danmuListView];
    
    return view;
}

- (void)createTextFieldWithContainerView:(UIView *)containerView {
    
    WVRLiveTextField *textField = [[WVRLiveTextField alloc] initWithContentView:containerView isFootball:[self.videoEntity isFootball] delegate:self];
    
    [self playerView].textField = textField;
    
    self.textField = textField;
}

- (void)createBlurBackgroundWithContainerView:(UIView *)containerView {
    
    if (![self.videoEntity respondsToSelector:@selector(icon)]) {
        return;
    }
    
    NSString *imgUrl = [self.videoEntity performSelector:@selector(icon)];
    
    // 模糊背景图
    UIImageView *imageView = [[WVRBlurImageView alloc] initWithContainerView:containerView imgUrl:imgUrl];
    
    _blurImageView = imageView;
}

- (WVRDanmuListView *)danmuListView {
    
    if ([self playerView].viewStyle != WVRPlayerViewStyleLive) { return nil; }
    
    if (!_danmuListView) {
        WVRDanmuListView *danm = [[WVRDanmuListView alloc] initWithFrame:CGRectMake(0, Y_DANMU, WIDTH_DANMU_VIEW, HEIGHT_DANMU_VIEW) delegate:self];
        
        [[self playerView] addSubview:danm];
        _danmuListView = danm;
        [self playerView].danmuListView = danm;
        
        [danm mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(danm.superview);
            make.height.equalTo(@(HEIGHT_DANMU_VIEW));
            make.width.equalTo(danm.superview);
            make.bottom.equalTo(danm.superview).offset(HEIGHT_TEXTFILED_VIEW + MARGIN_BETWEEN_DANMU_TEXTFILED);
        }];
        
        UITapGestureRecognizer *tapDanM = [[UITapGestureRecognizer alloc] initWithTarget:[self playerView] action:@selector(toggleControls)];
        tapDanM.delegate = [self playerView];
        
        [self.danmuListView addGestureRecognizer:tapDanM];
    }
    return _danmuListView;
}

- (void)setPlayerView:(WVRPlayerViewLive *)playerView {
    [super setPlayerView:playerView];

    playerView.liveDelegate = self;
}

- (WVRPlayerViewLive *)playerView {
    
    return (WVRPlayerViewLive *)[super playerView];
}

- (void)setIsFootball:(BOOL)isFootball {
    [super setIsFootball:isFootball];
    
    [self.textField setIsFootball:isFootball];
    self.textField.hidden = NO;
}

- (void)shouldShowCameraTipView {
    
    [self playerView].cameraPoint = self.textField.cameraPoint;
    
    [super shouldShowCameraTipView];
}

#pragma mark - other

- (void)execKeyboardOn:(BOOL)isOn keyboardHeight:(float)height animateTime:(float)time {
    
    if (!self.textField.onFirstResponder) { return; }
    
    _keyboardOn = isOn;
    
    // show
    if (isOn) {
        
        [UIView animateWithDuration:time animations:^{
//            self.mOffsetY = -height;
//            [self playerView].mOffsetY = self.mOffsetY;
//            [self playerView].y = 0 - height;
//            self.textField.height = HEIGHT_INPUT_VIEW;
//            self.textField.bottomY = self.view.height - height;
            
            [[self playerView] mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0-height);
            }];
            [self.textField mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(HEIGHT_INPUT_VIEW);
            }];
            
            [self.textField changeToKeyboardOnStatu:YES];
            
        } completion:^(BOOL finished) {
            [self.textField keyboardAnimatoinDoneWithStatu:YES];
            [[self playerView] controlsShowHideAnimation:NO];
            [self execDanmuReceived:@[]];
        }];
    } else {
        
//        hide
        [UIView animateWithDuration:time animations:^{
            
            [[self playerView] mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
            }];
            [self.textField mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(HEIGHT_TEXTFILED_VIEW);
            }];
            
            [self.textField changeToKeyboardOnStatu:NO];
            
        } completion:^(BOOL finished) {
            self.keyboardOn = NO;
            [self.textField keyboardAnimatoinDoneWithStatu:NO];
            [self execDanmuReceived:@[]];
        }];
    }
}

#pragma mark - OverWrite WVRPlayerViewDelegate

- (void)execPreparedWithDuration:(long)duration {
    [super execPreparedWithDuration:duration];
    
    [self.blurImageView removeFromSuperview];
}

- (void)actionSetControlsVisible:(BOOL)isControlsVisible {
    
    [self.textField setVisibel:isControlsVisible];
}

- (void)actionTouchesBegan {
    [super actionTouchesBegan];
    
    [self.textField setResignFirstResponder];
}

- (void)execChangeDefiBtnTitle:(NSString *)defi {
    [super execChangeDefiBtnTitle:defi];
    
    [self.textField updateDefiTitle:defi];
}

#pragma mark - WVRPlayerViewLiveDelegate


- (void)actionEasterEggLottery {
    
    [self.uiLiveDelegate actionEasterEggLottery];
}

- (void)actionGoGiftPage {
    
    [self.uiLiveDelegate actionGoGiftPage];
}

- (BOOL)actionCheckLogin {
    
    return [self.uiLiveDelegate actionCheckLogin];
}

- (void)actionGoRedeemPage {
    
    [self.uiLiveDelegate actionGoRedeemPage];
}

- (BOOL)isKeyboardOn {
    
    return _keyboardOn;
}

- (void)shareBtnClick:(UIButton *)sender {
    
    [self.uiLiveDelegate shareBtnClick:sender];
}

#pragma mark - Live

- (void)vrModeBtnClick:(UIButton *)sender {
    
    [self.uiLiveDelegate vrModeBtnClick:sender];
}

- (void)textFieldWillReturn:(NSString *)text {
    
    if (text.length > 0) {
        [self.uiLiveDelegate actionSendDanmu:text];
    }
}

// 基类已实现
//- (NSString *)actionChangeDefinition {
//
//}
//
//- (void)actionChangeCameraStand:(NSString *)standType {
//    
//}
//
//- (NSArray<NSDictionary *> *)actionGetCameraStandList {
//    
//}
//
//
//- (BOOL)isCharged {
//    
//    return [self.uiDelegate isCharged];
//}

- (BOOL)checkLogin {
    
    return [self.uiLiveDelegate actionCheckLogin];
}

//MARK: - 播放器状态信息

//- (BOOL)isOnError;
- (BOOL)isPrepared {
    
    return [self.vPlayer isPrepared];
}

#pragma mark - exec function


- (void)execDanmuReceived:(NSArray *)array {
    
    [self.danmuListView addDanmuWithArray:array];
}

- (void)execPlayCountUpdate:(long)playCount {
    
    [[self playerView] execPlayCountUpdate:playCount];
}


- (void)execNetworkStatusChanged {
    
    [[self playerView] execNetworkStatusChanged];
}


- (void)execEasterEggCountdown:(long)time {
    
    [[self playerView] execEasterEggCountdown:time];
}

- (void)execLotterySwitch:(BOOL)isOn {
    
    [[self playerView] execLotterySwitch:isOn];
}

- (void)execDanmuSwitch:(BOOL)isOn {
    
    [self.danmuListView setSwitchOn:isOn];
}

- (void)execLotteryResult:(NSDictionary *)dict {
    
    [[self playerView] execLotteryResult:dict];
}

#pragma mark - textField


- (void)setResignFirstResponder {
    
    [self.textField setResignFirstResponder];
}

- (void)setVisibel:(BOOL)isVasibel {
    
    [self.textField setVisibel:isVasibel];
}


- (void)changeToKeyboardOnStatu:(BOOL)isKeyboardOn {
    
    [self.textField changeToKeyboardOnStatu:isKeyboardOn];
}

- (void)keyboardAnimatoinDoneWithStatu:(BOOL)isKeyboardOn {
    
    [self.textField keyboardAnimatoinDoneWithStatu:isKeyboardOn];
}


- (void)changeDanmuSwitchStatus:(BOOL)isOn {
    
    [self.textField changeDanmuSwitchStatus:isOn];
}

- (void)updateDefiTitle:(NSString *)kDefi {
    
    [self.textField updateDefiTitle:kDefi];
}


@end
