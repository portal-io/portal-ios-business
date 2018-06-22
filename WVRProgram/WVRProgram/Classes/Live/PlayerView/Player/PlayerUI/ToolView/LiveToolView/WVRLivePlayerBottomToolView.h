//
//  WVRLivePlayerBottomToolView.h
//  WhaleyVR
//
//  Created by qbshen on 2017/2/20.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRPlayerToolVProtocol.h"
#import "WVRLiveTextField.h"
#import "WVRLiveBarrageView.h"

typedef NS_ENUM(NSInteger,WVRPlayerToolVSubStatus) {
    WVRPlayerToolVSubStatusDefault,
    WVRPlayerToolVSubStatusBanner,
    WVRPlayerToolVSubStatusFull,
};


@protocol WVRLivePlayerBTVDelegate <NSObject,WVRLiveTextFieldDelegate>

-(void)fullBtnOnClick:(UIButton*)fullBtn;

-(void)launchBtnOnClick:(UIButton*)launchBtn;



@end
@interface WVRLivePlayerBottomToolView : UIView<WVRPlayerToolVProtocol>

@property (nonatomic,weak) id<WVRLivePlayerBTVDelegate> clickDelegate;

@property (weak, nonatomic) IBOutlet UIButton *fullBtn;

@property (weak, nonatomic) IBOutlet UIButton *launchBtn;

@property (weak, nonatomic) IBOutlet WVRLiveTextField *textFieldV;


@property (weak, nonatomic) WVRLiveBarrageView *mBarrageV;

-(void)updateStatus:(WVRPlayerToolVStatus)status;
-(void)setVisble;

-(void)updateSubStatus:(WVRPlayerToolVSubStatus)subStatus;

@end
