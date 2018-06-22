//
//  WVRDanmuListView.h
//  WhaleyVR
//
//  Created by Bruce on 2016/12/27.
//  Copyright © 2016年 Snailvr. All rights reserved.

// 直播相关控件类

#import <UIKit/UIKit.h>
#import "YYText.h"
#import "WVRPlayerViewProtocol.h"
#import "WVRPlayerUIFrameMacro.h"

//@protocol WVRPlayerViewDelegate;
@class WVRDanmuListCellInfo, WVRLiveInfoAlertView;;


@interface WVRDanmuListView : UIView

@property (nonatomic, weak) id<WVRPlayerViewDelegate> realDelegate;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithFrame:(CGRect)frame delegate:(id)delegate;
- (void)addDanmuWithArray:(NSArray *)list;

- (void)setSwitchOn:(BOOL)isOn;

- (BOOL)isSwitchOn;

@end


@interface WVRDanmuListCell : UITableViewCell

/**
 set only
 */
@property (nonatomic, strong) WVRDanmuListCellInfo *cellInfo;

@property (nonatomic, weak) YYLabel *contentLabel;

@end


@interface WVRDanmuListCellInfo : NSObject

@property (nonatomic, strong) NSAttributedString *message;

@property (nonatomic, assign) CGFloat cellHeight;

@end

