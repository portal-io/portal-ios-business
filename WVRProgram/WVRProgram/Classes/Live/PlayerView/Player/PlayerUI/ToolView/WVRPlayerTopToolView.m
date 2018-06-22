//
//  WVRPlayerTopToolView.m
//  WhaleyVR
//
//  Created by qbshen on 2017/2/17.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRPlayerTopToolView.h"

@interface WVRPlayerTopToolView ()

@property (nonatomic, weak) UIView *topShadow;

@end
@implementation WVRPlayerTopToolView


-(void)awakeFromNib
{
    [super awakeFromNib];
    [self topShadow];
}

-(void)layoutSubviews
{
    self.topShadow.frame = self.bounds;
}

-(BOOL)isHiddenV
{
    return self.hidden;
}

-(WVRPlayerToolVQuality)getQuality
{
    return 0;
}

-(void)updateFrame:(CGRect)frame
{

}

-(void)updateWillToQuality:(WVRPlayerToolVQuality)willQuality
{

}

-(void)updateStatus:(WVRPlayerToolVStatus)status
{

}

-(void)updateQuality:(WVRPlayerToolVQuality)quality
{

}

-(WVRPlayerToolVQuality)getWillToQuality
{
    return 0;
}

-(WVRPlayerToolVStatus)getStatus
{
    return 0;
}

- (UIView *)topShadow {
    if (!_topShadow) {
        
        UIView *topShadow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAX(SCREEN_WIDTH, SCREEN_HEIGHT), HEIGHT_DEFAULT)];
        // 设置渐变效果
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = topShadow.bounds;
        gradientLayer.colors = [NSArray arrayWithObjects:
                                (id)[[UIColor colorWithWhite:0 alpha:0.5] CGColor],
                                (id)[[UIColor colorWithWhite:0 alpha:0] CGColor], nil];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1);
        [topShadow.layer insertSublayer:gradientLayer atIndex:0];
        
        topShadow.backgroundColor = [UIColor clearColor];
        
        [self insertSubview:topShadow atIndex:0];
        _topShadow = topShadow;
    }
    return _topShadow;
}

-(void)hiddenV:(BOOL)hidden
{
    self.hidden = hidden;
}

- (IBAction)backOnClick:(id)sender {
    if ([self.clickDelegate respondsToSelector:@selector(backOnClick:)]) {
        [self.clickDelegate backOnClick:sender];
    }
}

-(CGSize)getViewSize
{
    return CGSizeMake(SCREEN_WIDTH, HEIGHT_DEFAULT);
}

@end
