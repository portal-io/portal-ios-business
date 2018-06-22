//
//  WVRFullSPlayerToolView.m
//  WhaleyVR
//
//  Created by qbshen on 2017/2/17.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRFullSPlayerBottomToolView.h"
#import "WVRSlider.h"
#import "WVRCameraChangeButton.h"

@interface WVRFullSPlayerBottomToolView () {
    
    BOOL _isFootball;
}

@property (weak, nonatomic) IBOutlet UIButton *defiButton;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

@property (nonatomic, weak) UIButton *cameraBtn;
@property (nonatomic, strong) NSArray *cameraStandBtns;

@end


@implementation WVRFullSPlayerBottomToolView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    CGSize size = [WVRComputeTool sizeOfString:self.fullBtn.titleLabel.text Size:CGSizeMake(800, 800) Font:self.fullBtn.titleLabel.font];
    [self addLayerToButton:self.fullBtn size:size];
}

- (void)setClickDelegate:(id<WVRSmallPlayerTVDelegate>)clickDelegate {
    
    [super setClickDelegate:clickDelegate];
}

- (void)addLayerToButton:(UIButton *)btn size:(CGSize)size {
    
    if (size.width == 0) {
        size = [WVRComputeTool sizeOfString:btn.titleLabel.text Size:CGSizeMake(800, 800) Font:btn.titleLabel.font];
    }
    
    CALayer *layer = [[CALayer alloc] init];
    float height = size.height + 6;
    float y = (btn.height - height) / 2.0;
    layer.frame = CGRectMake(0, y, btn.width, height);
    
    layer.cornerRadius = layer.frame.size.height / 2.0;
    layer.masksToBounds = YES;
    layer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6].CGColor;
    [btn.layer insertSublayer:layer atIndex:0];
}

- (void)fullBtnOnClick:(UIButton *)sender {
    
    // 新增需求，足球不支持切换清晰度
    if (_isFootball) {
        SQToastInKeyWindow(kToastNoChangeDefinition);
        return;
    }
    
    if ([self.clickDelegate respondsToSelector:@selector(chooseQuality)]) {
        [self.clickDelegate chooseQuality];
    }
}

- (void)updateQuality:(WVRPlayerToolVQuality)quality {
    [super updateQuality:quality];
    
    switch (quality) {
        case WVRPlayerToolVQualityDefault:
        case WVRPlayerToolVQualityST:
            [self.fullBtn setTitle:@"高清" forState:UIControlStateNormal];
            break;
        case WVRPlayerToolVQualitySD:
            [self.fullBtn setTitle:@"超清" forState:UIControlStateNormal];
            break;
        case WVRPlayerToolVQualityHD:
            [self.fullBtn setTitle:@"原画" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (void)updateQualityWithTitle:(NSString *)qualityTitle {
    
    [self.fullBtn setTitle:qualityTitle forState:UIControlStateNormal];
    if ([qualityTitle isEqualToString:@"高清"]) {
        [self updateQuality:WVRPlayerToolVQualityST];
    }else if ([qualityTitle isEqualToString:@"超清"]) {
        [self updateQuality:WVRPlayerToolVQualitySD];
    }else if ([qualityTitle isEqualToString:@"原画"]) {
        [self updateQuality:WVRPlayerToolVQualityHD];
    }
}


- (void)setIsFootball:(BOOL)isFootball {
    _isFootball = isFootball;
    
    if (_isFootball) {
        self.cameraBtn.hidden = NO;
    } else {
        _cameraBtn.hidden = YES;
        
        kWeakSelf(self);
        [self.totalTimeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.right.equalTo(weakself.defiButton.mas_left).offset(0 - 15);
        }];
    }
}

- (UIButton *)cameraBtn {
    
    if (!_isFootball) { return nil; }
    
    if (!_cameraBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"record_camera_stand_normal"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"record_camera_stand_press"] forState:UIControlStateHighlighted];
        btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [btn addTarget:self action:@selector(cameraBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:btn];
        _cameraBtn = btn;
        
        NSNumber *width = [NSNumber numberWithFloat:adaptToWidth(24)];
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_defiButton);
            make.height.equalTo(width);
            make.width.equalTo(width);
            make.right.equalTo(_defiButton.mas_left).offset(0 - 15);
        }];
        
        [self.totalTimeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.right.equalTo(btn.mas_left).offset(0 - 15);
        }];
    }
    return _cameraBtn;
}

- (void)cameraBtnClick:(UIButton *)sender {
    
    if (self.cameraStandBtns) {
        
        [self removeCameraStandBtns];
        
    } else {
        
        NSArray *arr = nil;
        if ([self.clickDelegate respondsToSelector:@selector(actionGetCameraStandList)]) {
            arr = [self.clickDelegate actionGetCameraStandList];
        }
        
        NSMutableArray *btnArr = [NSMutableArray array];
        
        int j = (int)arr.count;
        for (NSDictionary *dict in arr) {
            
            WVRCameraChangeButton *btn = [[WVRCameraChangeButton alloc] init];
            
            btn.x = sender.x;
            btn.y = sender.y - (adaptToWidth(10) + btn.height) * j;
            btn.standType = [[dict allKeys] firstObject];
            [btn setTitle:btn.standType forState:UIControlStateNormal];
            btn.isSelect = [[[dict allValues] firstObject] boolValue];
            
            [btn addTarget:self action:@selector(changeCameraBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:btn];
            [btnArr addObject:btn];
            
            j -= 1;
        }
        _cameraStandBtns = btnArr;
    }
}

- (void)changeCameraBtnClick:(WVRCameraChangeButton *)sender {
    
//    [self removeCameraStandBtns];
    
    for (WVRCameraChangeButton *btn in _cameraStandBtns) {
        btn.isSelect = (btn == sender);
    }
    
    if ([self.clickDelegate respondsToSelector:@selector(actionChangeCameraStand:)]) {
        [self.clickDelegate actionChangeCameraStand:sender.standType];
    }
}

- (void)removeCameraStandBtns {
    for (UIButton *btn in _cameraStandBtns) {
        [btn removeFromSuperview];
    }
    _cameraStandBtns = nil;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    for (UIButton *btn in _cameraStandBtns) {
        CGPoint buttonPoint = [btn convertPoint:point fromView:self];
        if ([btn pointInside:buttonPoint withEvent:event]) {
            return btn;
        }
    }
    
    UIView * view = [super hitTest:point withEvent:event];
    return view;
}

- (CGPoint)cameraPoint {
    
    return CGPointMake(_cameraBtn.centerX, self.height - (_cameraBtn.bottomY + 7));
}

@end
