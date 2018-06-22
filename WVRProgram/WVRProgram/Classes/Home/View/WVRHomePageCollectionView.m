//
//  WVRHomePageCollectionView.m
//  WhaleyVR
//
//  Created by qbshen on 2017/7/20.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRHomePageCollectionView.h"
#import "WVRBaseEmptyView.h"

@interface WVRHomePageCollectionView ()

@property (nonatomic, strong) WVRBaseEmptyView * gEmptyView;

@end


@implementation WVRHomePageCollectionView

//- (instancetype)init {
//    self = [super init];
//    if (self) {
//        
//    }
//    return self;
//}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.gEmptyView.frame = self.bounds;
}

- (void)setDelegate:(id<UICollectionViewDelegate>)delegate andDataSource:(id<UICollectionViewDataSource>)dataSource {
    
    self.delegate = delegate;
    self.dataSource = dataSource;
}

- (void)reloadData {
    
    [super reloadData];
    
}

- (WVRBaseEmptyView *)gEmptyView {
    
    if (!_gEmptyView) {
        _gEmptyView = [[WVRBaseEmptyView alloc] initWithFrame:CGRectZero];
        [self addSubview:_gEmptyView];
    }
    return _gEmptyView;
}

- (UIView<WVREmptyViewProtocol> *)getEmptyView {
    
    return self.getEmptyView;
}

#pragma mark - WVREmptyView

- (void)showLoadingWithText:(NSString *)text {
    
    kWeakSelf(self);
    SQShowProgressIn(weakself);
}

- (void)hidenLoading {
    
    kWeakSelf(self);
    SQHideProgressIn(weakself);
}

- (void)showNetErrorVWithreloadBlock:(void (^)())reloadBlock {
    
    [self bringSubviewToFront:self.gEmptyView];
    [self.gEmptyView showNetErrorVWithreloadBlock:reloadBlock];
}

- (void)showNullViewWithTitle:(NSString *)title icon:(NSString *)icon {
    
    [self bringSubviewToFront:self.gEmptyView];
    [self.gEmptyView showNullViewWithTitle:title icon:icon];
}

- (void)clear {
    
    self.gEmptyView.hidden = YES;
}


@end
