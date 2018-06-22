//
//  WVR	AutoAarrangeController.m
//  WhaleyVR
//
//  Created by qbshen on 2017/1/3.
//  Copyright © 2017年 Snailvr. All rights reserved.
//
// 自动编排

#import "WVRAutoArrangeController.h"
#import "WVRAutoArrangeView.h"
#import "WVRAutoArrangePresenter.h"
#import "SQRefreshHeader.h"
#import "SQRefreshFooter.h"
#import "WVRAutoArrangeControllerProtocol.h"

@interface WVRAutoArrangeController ()<WVRAutoArrangeControllerProtocol>

@property (nonatomic, strong) WVRAutoArrangePresenter * gAutoArrangeP;

@property (nonatomic, strong) WVRBaseCollectionView* gCollectionView;

@end


@implementation WVRAutoArrangeController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initCollectionView];
    [self.gAutoArrangeP fetchData];
    [self.view addSubview:self.gCollectionView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(WVRBaseCollectionView *)gCollectionView
{
    if (!_gCollectionView) {
        _gCollectionView = [[WVRBaseCollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:[UICollectionViewFlowLayout new]];
    }
    return _gCollectionView;
}

-(UICollectionView*)getCollectionView
{
    return self.gCollectionView;
}

-(WVRAutoArrangePresenter *)gAutoArrangeP
{
    if (!_gAutoArrangeP) {
        _gAutoArrangeP = [[WVRAutoArrangePresenter alloc] initWithParams:self.createArgs attchView:self];
    }
    return _gAutoArrangeP;
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.gCollectionView.frame = CGRectMake(0, kNavBarHeight, self.view.width, self.view.height-kNavBarHeight);
}

- (void)initCollectionView {
    
    self.gCollectionView.backgroundColor = UIColorFromRGB(0xeeeeee);
    kWeakSelf(self);
    [self.gCollectionView addHeaderRefresh:^{
        [weakself.gAutoArrangeP fetchRefreshData];
    }];
    [self.gCollectionView addFooterMore:^{
        [weakself.gAutoArrangeP fetchMoreData];
    }];
}

#pragma WVRCollectionViewCProtocol

-(void)setDelegate:(id<UICollectionViewDelegate>)delegate andDataSource:(id<UICollectionViewDataSource>)dataSource
{
    self.gCollectionView.delegate = delegate;
    self.gCollectionView.dataSource = dataSource;
}

-(void)reloadData
{
    [self.gCollectionView reloadData];
    
}

- (void)initTitleBar
{
    [super initTitleBar];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)stopHeaderRefresh
{
    [self.gCollectionView stopHeaderRefresh];
}

-(void)stopFooterMore:(BOOL)noMore
{
    [self.gCollectionView stopFooterMore:noMore];
}


@end
