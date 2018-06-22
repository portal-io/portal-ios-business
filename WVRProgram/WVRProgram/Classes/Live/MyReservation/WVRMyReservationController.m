//
//  WVRMyReservationController.m
//  WhaleyVR
//
//  Created by qbshen on 2017/2/10.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRMyReservationController.h"
#import "WVRMyReservationPresenter.h"

@interface WVRMyReservationController ()

@property (nonatomic) WVRMyReservationPresenter * myReserveP;

@end


@implementation WVRMyReservationController

+ (instancetype)createViewController:(id)createArgs {
    
    WVRMyReservationController * vc = [[WVRMyReservationController alloc] init];
    vc.view.backgroundColor = k_Color11;
    vc.myReserveP = [WVRMyReservationPresenter createPresenter:vc];
    UIView* subV = [vc.myReserveP getView];
    subV.frame = vc.view.bounds;
    [vc.view addSubview:subV];
    
    return vc;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.myReserveP fetchData];
}

- (void)initTitleBar {
    [super initTitleBar];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
}

- (void)back {
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
