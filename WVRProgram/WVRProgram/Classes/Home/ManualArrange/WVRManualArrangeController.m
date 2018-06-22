//
//  WVRSQArrangeMoreController.m
//  WhaleyVR
//
//  Created by qbshen on 16/11/17.
//  Copyright © 2016年 Snailvr. All rights reserved.

// 专题列表

#import "WVRManualArrangeController.h"
#import "WVRSQArrangeMaCell.h"
#import "WVRSQArrangeMAHeader.h"
#import "WVRUMShareView.h"

#import "WVRBIModel.h"
#import "WVRSQTagHorCell.h"
#import "WVRManualArrangeShareHeader.h"
#import "WVRManualAShareCell.h"

#import "WVRNavigationBar.h"

//#import <MobLink/MobLink.h>
//#import <MobLink/MLSDKScene.h>

@interface WVRManualArrangeController () {
    
    BOOL _isFirstIn;
}

@property (nonatomic, strong) WVRNavigationBar *bar;
//@property (nonatomic) WVRNetErrorView * mErrorView;

@property (nonatomic) UIBarButtonItem *mBackItem;
@property (nonatomic) UIBarButtonItem *mShareItem;

@property (nonatomic, copy) NSString *mobLinkId;

@end


@implementation WVRManualArrangeController
//@synthesize bar;

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
//    self.collectionView.backgroundColor = [UIColor whiteColor];
//    self.automaticallyAdjustsScrollViewInsets = NO;
//    kWeakSelf(self);
//    self.collectionDelegate.scrollDidScrolling = ^(CGFloat y) {
//        [weakself scrollDidScrollingBlock:y];
//    };
    [self requestInfo];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareNotfResponse:) name:NAME_NOTF_MANUAL_ARRANGE_SHARE object:nil];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [WVRAppModel forceToOrientation:UIInterfaceOrientationPortrait];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.bar setNeedsLayout];
}


- (void)dealloc {
    
    DebugLog(@"");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UI

- (void)createNavBar {
    
    if (self.bar) { return; }
    
    self.bar = [[WVRNavigationBar alloc] init];
    [self.view addSubview:self.bar];
    [self.view bringSubviewToFront:self.bar];
    
    [self navBackSetting];
}

- (void)navBackSetting {
    
    UINavigationItem *item = [[UINavigationItem alloc] init];
    
    UIImage *backimage = [[UIImage imageNamed:@"icon_manual_back"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:backimage style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonClick)];
    self.mBackItem = backItem;
    item.leftBarButtonItems = @[ backItem ];
    
    UIImage *shareimage = [[UIImage imageNamed:@"icon_video_detail_share"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithImage:shareimage style:UIBarButtonItemStylePlain target:self action:@selector(shareBarButtonClick)];
    self.mShareItem = shareItem;
    item.rightBarButtonItems = @[ shareItem ];
//    item.title = self.sectionModel.name;
    
    [self.bar pushNavigationItem:item animated:NO];
}

- (void)updateBarStatus:(CGFloat)alpha
{
    [self.bar setOverlayDiaphaneity:alpha];
    
    self.mBackItem.tintColor = [UIColor colorWithWhite:1-alpha alpha:1];
    self.mShareItem.tintColor = [UIColor colorWithWhite:1-alpha alpha:1];
}

#pragma mark - Action

// 返回
- (void)leftBarButtonClick {
    
    [WVRTrackEventMapping trackEvent:@"subject" flag:@"back"];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareBarButtonClick {
    
//    self.mShareView.alpha = 1;
    [self createShareTool];
    [self.view addSubview:self.mShareView];
}

- (void)scrollDidScrollingBlock:(CGFloat)y {
    
//    if (y > 0) {
//        [self updateBarStatus:fabs(y)/kNavBarHeight];
//        SQCollectionViewSectionInfo* sectionInfo = self.originDic[@(0)];
//        WVRSQArrangeMAHeaderInfo * headerInfo = (WVRSQArrangeMAHeaderInfo *)sectionInfo.headerInfo;
//        if (headerInfo.playStatusBlock) {
//            headerInfo.playStatusBlock(1 - fabs(y) / (fitToWidth(211) - kNavBarHeight));
//        }
//    }
//    else {
//        [self updateBarStatus:0];
//        SQCollectionViewSectionInfo* sectionInfo = self.originDic[@(0)];
//        WVRSQArrangeMAHeaderInfo * headerInfo = (WVRSQArrangeMAHeaderInfo *)sectionInfo.headerInfo;
//        if (headerInfo.playStatusBlock) {
//            headerInfo.playStatusBlock(1);
//        }
//    }
}

#pragma mark - request

- (void)requestInfo {
    [super requestInfo];
    
    [self httpRequest];
}

- (void)httpRequest {
    
//    [self removeNetErrorV];
//    kWeakSelf(self);
//    SQShowProgress;
//    [WVRManualArrangeModel http_recommendPageWithCode:self.sectionModel.linkArrangeValue successBlock:^(WVRSectionModel *args) {
//        [weakself httpSuccessBlock:args];
//    } failBlock:^(NSString *args) {
//        [weakself httpFailBlock:args];
//    }];
}

- (void)httpSuccessBlock:(WVRSectionModel *)args {
    
//    SQHideProgress;
//    [self removeNetErrorV];
//    self.mBackItem.tintColor = [UIColor colorWithWhite:1 alpha:1];
//    
//    self.sectionModel.thubImageUrl = args.thubImageUrl;
//    self.sectionModel.name = args.name;
//    self.sectionModel.intrDesc = args.subTitle;
//    [self createNavBar];
//    
//    args.sectionType = WVRSectionModelTypeManualArrange;
//    self.originDic[@(0)] = [self sectionInfo:args];
//    NSMutableArray * array = [NSMutableArray new];
//    for (NSString * cur in [self iconStrs]) {
//        WVRItemModel * model = [WVRItemModel new];
//        model.name = cur;
//        model.thubImageUrl = cur;
//        [array addObject:model];
//    }
//    WVRSectionModel * sectionModel = [WVRSectionModel new];
//    sectionModel.itemModels = array;
//    sectionModel.linkArrangeValue = self.sectionModel.linkArrangeValue;
//    sectionModel.sectionType = WVRSectionModelTypeManualArrangeShare;
//    self.originDic[@(1)] = [self sectionInfo:sectionModel];
//    
//    if (!_isFirstIn) {
//        
//        [WVRBIModel trackEventForTopicWithAction:BITopicActionTypeBrowse topicId:_sectionModel.linkArrangeValue topicName:_sectionModel.name videoSid:nil videoName:nil index:0 isPackage:args.isChargeable];
//        
//        _isFirstIn = YES;
//    }
//    
//    [self updateCollectionView];
//    [self createShareTool];
//    
//    [self requestForMobLinkId];
}

- (void)httpFailBlock:(NSString *)args {
    
//    [self createNavBar];
//    self.mBackItem.tintColor = [UIColor colorWithWhite:0 alpha:1];
//    kWeakSelf(self);
//    [self showNetErrorV:self.view reloadBlock:^{
//        [weakself requestInfo];
//    }];
//    SQHideProgress;
}

- (void)requestForMobLinkId {
    
//#warning waiting done
//    MLSDKScene *scene = [[MLSDKScene alloc] initWithMLSDKPath:@"" source:@"" params:@{}];
//    
//    kWeakSelf(self);
//    [MobLink getMobId:scene result:^(NSString *mobid) {
//        weakself.mobLinkId = mobid;
//    }];
}

#pragma mark - data

- (NSArray *)iconStrs {
    
    return [NSArray arrayWithObjects:@"share_icon_sina", @"share_icon_wechat", @"share_icon_friends", @"share_icon_qq", @"share_icon_qzone", nil];
}

- (void)shareNotfResponse:(NSNotification *)notf {
    
    void(^block)() = [self shareBlockDic][notf.object];
    block();
}

- (NSDictionary *)shareBlockDic {
    
    NSString * sinaK = [[self iconStrs] firstObject];
    
    NSString * wechatK = [self iconStrs][1];
    NSString * wechatLineK = [self iconStrs][2];
    NSString * qqK = [self iconStrs][3];
    
    NSString * qzoneK = [[self iconStrs] lastObject];
    
    kWeakSelf(self);
    return @{sinaK:^{
                [weakself.mShareView shareToIndex:0];
            },
             wechatK:^{
                 [weakself.mShareView shareToIndex:2];
             },
             wechatLineK:^{
                 [weakself.mShareView shareToIndex:4];
             },
             qqK:^{
                [weakself.mShareView shareToIndex:1];
            },
             qzoneK:^{
                [weakself.mShareView shareToIndex:3];
            }
             };
}

#pragma mark - share

- (void)createShareTool {
    // 分享功能模块
//    WVRShareType type = WVRShareTypeSpecialTopic;
////    if (!self.mShareView) {
//        WVRUMShareView *shareView = [WVRUMShareView shareWithContainerView:self.view
//                                                                      sID:self.sectionModel.linkArrangeValue
//                                                                  iconUrl:self.sectionModel.thubImageUrl
//                                                                    title:self.sectionModel.name
//                                                                    intro:self.sectionModel.intrDesc
//                                                                    mobId:nil
//                                                                shareType:type ];
//        self.mShareView = shareView;
////    }
}

@end
