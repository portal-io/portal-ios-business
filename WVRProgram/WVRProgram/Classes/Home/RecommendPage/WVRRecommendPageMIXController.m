//
//  WVRRecommendPageMIXController.m
//  WhaleyVR
//
//  Created by qbshen on 2017/1/8.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRRecommendPageMIXController.h"
#import "WVRSectionModel.h"
#import "WVRRecommendPageMIXView.h"
#import "WVRSmallPlayerPresenter.h"

@interface WVRRecommendPageMIXController ()

@property (nonatomic) WVRSectionModel * sectionModel;

@end


@implementation WVRRecommendPageMIXController

+ (instancetype)createViewController:(id)createArgs
{
    //    UIStoryboard *board = [UIStoryboard storyboardWithName:@"WVRSQVRFindMoreRecommendController" bundle:nil];
    //    WVRSQVRFindMoreRecommendController* vc = [board instantiateViewControllerWithIdentifier:@"WVRSQVRFindMoreRecommendController"];
    WVRRecommendPageMIXController * vc = [WVRRecommendPageMIXController new];
    vc.sectionModel = createArgs;
    WVRRecommendPageMIXViewInfo * vInfo = [WVRRecommendPageMIXViewInfo new];
    vInfo.viewController = vc;
    vInfo.frame = vc.view.bounds;
    vInfo.sectionModel = vc.sectionModel;
    WVRRecommendPageMIXView* nodePV = [WVRRecommendPageMIXView createWithInfo:vInfo];
    [nodePV requestInfo];
    vc.gCollectionView = nodePV;
    [vc.view addSubview:vc.gCollectionView];
    return vc;
    
}

-(void)loadView
{
    [super loadView];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)initTitleBar
{
    [super initTitleBar];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if ([[WVRSmallPlayerPresenter shareInstance] isLaunch]) {
        
    }else{
        [[WVRSmallPlayerPresenter shareInstance] destroy];
        [[WVRSmallPlayerPresenter shareInstance] updateCanPlay:NO];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}
@end
