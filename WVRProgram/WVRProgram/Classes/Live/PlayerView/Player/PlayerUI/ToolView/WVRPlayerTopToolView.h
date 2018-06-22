//
//  WVRPlayerTopToolView.h
//  WhaleyVR
//
//  Created by qbshen on 2017/2/17.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRPlayerToolVProtocol.h"

#define HEIGHT_DEFAULT (50.f)


@protocol WVRPlayerTopToolVDelegate <NSObject>

- (void)backOnClick:(UIButton*)sender;

@end
@interface WVRPlayerTopToolView : UIView<WVRPlayerToolVProtocol>

@property (nonatomic) id<WVRPlayerTopToolVDelegate> clickDelegate;
@property (weak, nonatomic) IBOutlet UILabel *titleL;
- (IBAction)backOnClick:(id)sender;
@end
