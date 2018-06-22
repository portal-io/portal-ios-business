//
//  WVROrderSheetHeaderView.h
//  WhaleyVR
//
//  Created by Bruce on 2017/6/11.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WVRPayGoodsType.h"
#import "WVRPayModel.h"
@class WVROrderGoodsSelectLabel;

typedef NS_ENUM(NSInteger, GoodsSelectType) {
    
    GoodsSelectTypeNone,
    GoodsSelectTypeSelected,
    GoodsSelectTypeAlternative,
};

@interface WVROrderSheetHeaderView : UIView

- (instancetype)initWithFrame:(CGRect)frame payModel:(WVRPayModel *)payModel type:(OrderAlertType)type;

@property (nonatomic, assign, readonly) WVRPayGoodsType selectedType;

#pragma mark - private

- (void)selectLabelTapAction:(WVROrderGoodsSelectLabel *)label;
- (void)goPackgeDetailVC;

@end


@interface WVROrderGoodsSelectLabel: UIView

@property (nonatomic, readonly) WVRPayGoodsType type;

- (instancetype)initWithFrame:(CGRect)frame price:(long)price title:(NSString *)title selectStatus:(GoodsSelectType)selectStatus type:(WVRPayGoodsType)type packageType:(WVRPackageType)packageType needHideDetail:(BOOL)needHideDetail;

- (void)resetSelectStatus;

//- (void)setIsFormUnity:(BOOL)isUnity;

@end


@interface WVROrderGoodsNameLabel : UIView

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIColor *textColor;

@end
