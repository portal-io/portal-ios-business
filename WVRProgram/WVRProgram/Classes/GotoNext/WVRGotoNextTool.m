//
//  WVRSQFindGotoVCTool.m
//  WhaleyVR
//
//  Created by qbshen on 16/11/17.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRGotoNextTool.h"

#import "WVRRewardController.h"

#import "WVRManualArrangeController.h"
#import "WVRManualArrangeController.h"

#import "WVRVideoDetailVC.h"
#import "WVRWasuDetailVC.h"
#import "WVRLiveDetailVC.h"
#import "WVRWebViewController.h"
#import "WVRLiveGotoTool.h"
#import "WVRAutoArrangeController.h"
#import "WVRRecommendPageTitleController.h"
#import "WVRTVDetailController.h"
#import "WVRLiveGotoTool.h"

#import "WVRItemModel.h"
#import "WVRPlayerTool.h"
#import "WVRSetController.h"
#import "WVRRecommendPageMIXController.h"
#import "WVRBrandZoneController.h"

#import "WVRTVMovieDetailController.h"

#import "WVRLiveShowModel.h"
#import "WVRHistoryModel.h"
#import "WVRLiveController.h"
#import "WVRProgramPackageController.h"

#import "WVRPlayerVC360.h"
#import "WVRPlayerVCLive.h"
#import "WVRPlayerVCLocal.h"

#import "WVRFootballModel.h"
#import "WVRVideoEntityTopic.h"
#import "WVRPlayerVCTopic.h"
#import "WVRNavigationController.h"

#import "WVRMediator+UnityActions.h"

@interface WVRGotoNextTool ()

@property (nonatomic, weak) UINavigationController *navController;
@property (nonatomic, copy) NSString *moduleName;   // 埋点

@end


@implementation WVRGotoNextTool

- (instancetype)initWithNavC:(UINavigationController *)navController {
    
    self = [super init];
    if (self) {
        self.navController = navController;
    }
    return self;
}

+ (void)gotoNextVC:(WVRBaseModel *)model nav:(UINavigationController *)nav {
    
    WVRGotoNextTool * tool = [[WVRGotoNextTool alloc] initWithNavC:nav];
    [tool gotoMoreVc:model];
}

// 埋点
+ (void)gotoNextVC:(WVRBaseModel *)model module:(NSString *)moduleName nav:(UINavigationController *)nav {
    
    WVRGotoNextTool * tool = [[WVRGotoNextTool alloc] initWithNavC:nav];
    tool.moduleName = moduleName;
    
    [tool gotoMoreVc:model];
}

// MARK: - 全屏播放器
- (void)gotoPlayVC:(WVRBaseModel *)model videoType:(WVRVideoDetailType)videoType {
    
    if (![model isKindOfClass:[WVRItemModel class]]) {
        DDLogError(@"![model isKindOfClass:[WVRItemModel class]");
    }
    WVRItemModel * itemModel = (WVRItemModel *)model;
    WVRPlayerToolModel * tModel = [[WVRPlayerToolModel alloc] init];
    tModel.title = itemModel.name;
    tModel.type = WVRVideoStreamTypeNormal;
    tModel.detailType = videoType;
    tModel.sid = itemModel.linkArrangeValue;
    tModel.playURL = itemModel.playUrl;
    tModel.iconURL = itemModel.thubImageUrl;
    tModel.playCount = (long)itemModel.playCount.longLongValue;
    tModel.needCharge = itemModel.isChargeable;
    tModel.price = itemModel.price;
    tModel.nav = self.navController;
    tModel.renderType = itemModel.renderType;
    
    [WVRPlayerTool showPlayerControllerWith:tModel];
}

// MARK: - Launcher_秀场
- (void)gotoShow:(WVRBaseModel *)model {
    
    if (![model isKindOfClass:[WVRLiveShowModel class]]) {
        NSLog(@"model 类型 不是WVRLiveShowModel");
        return;
    }
    WVRLiveShowModel * curModel = (WVRLiveShowModel *)model;
    
    if (curModel.liveStatus == WVRLiveStatusNotStart) {
        SQToastInKeyWindow(kToastShow);
    } else {
        DDLogInfo(@"roomId: %@", curModel.roomId);
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"access_token"] = [WVRUserModel sharedInstance].sessionId ?: @"";
        dict[@"device_id"] = [WVRUserModel sharedInstance].deviceId;
        dict[@"room_id"] = curModel.roomId;
        
        [[WVRMediator sharedInstance] WVRMediator_showU3DView:NO];
        
        WVRUnityActionMessageModel *msgModel = [[WVRUnityActionMessageModel alloc] init];
        msgModel.message = @"StartScene";
        msgModel.arguments = @[ @"startLiveVR", @"LiveVRInfo", [dict toJsonString], ];
        
        [[WVRMediator sharedInstance] WVRMediator_sendMsgToUnity:msgModel];
    }
}

// MARK: - 跳转到Launcher
- (void)gotoLauncher:(WVRLaunchModel *)model {
    
    if (![model isKindOfClass:[WVRLaunchModel class]]) {
        NSLog(@"model 类型 不是WVRLaunchModel");
        return;
    }
    WVRLaunchModel * curModel = (WVRLaunchModel *)model;
    
    if ([model isFootball]) {
        
        [self showfootballUnityRecommendPage:model];
        return;
    }
    
    [[WVRMediator sharedInstance] WVRMediator_showU3DView:NO];
    
    NSString *tag = nil;
    
    double progress = curModel.position / (double)curModel.videoDuration;
    
    WVRUnityActionPlayModel *playModel = [[WVRUnityActionPlayModel alloc] init];
    playModel.sid = curModel.sid;
    playModel.title = curModel.name;
    playModel.urlDic = curModel.playUrlDic;
    playModel.quality = curModel.defiKey;
    playModel.streamType = curModel.streamType;
    playModel.renderType = curModel._renderType;
    playModel.progress = (curModel.streamType == STREAM_VR_LIVE ? 0 : progress);
    playModel.tags = tag;
    playModel.renderTypeStr = curModel.renderTypeStr;
    
    [[WVRMediator sharedInstance] WVRMediator_sendUnityToPlay:playModel];
}

// MARK: - 秀场列表
- (void)gotoShowListVC {
    
    [self.navController.tabBarController setSelectedIndex:1];
    UINavigationController * nv = [self.navController.tabBarController viewControllers][1];
    WVRLiveController * vc = [[nv viewControllers] firstObject];
    
    [vc showShowList];
}

// MARK: - 跳转路由_总管
- (void)gotoMoreVc:(WVRBaseModel *)model {
    
    NSLog(@"linkArrangeType: %@", model.linkArrangeType);
    NSLog(@"recommendPageType: %@", model.recommendPageType);
    NSLog(@"programType: %@", model.programType);
    NSLog(@"videoType: %@", model.videoType);
    
    if ([model.linkArrangeType isEqualToString:LINKARRANGETYPE_ARRANGE]) {
        [self gotoAutoArrangeMoreVC:model];
    } else if ([model.linkArrangeType isEqualToString:LINKARRANGETYPE_MANUAL_ARRANGE]) {
        [self gotoManualArrangeMoreVc:model];
    }
    else if ([model.linkArrangeType isEqualToString:LINKARRANGETYPE_RECOMMENDPAGE]) {
        [self gotoRecommendMoreVC:model];
    } else if ([model.linkArrangeType isEqualToString:LINKARRANGETYPE_LIVE]) {
        [self gotoLiveVC:model];
    }
    else if ([model.linkArrangeType isEqualToString:LINKARRANGETYPE_MORETVPROGRAM]) {
        [self gotoMoreTV_TVDetailVC:model];
    }
    else if ([model.linkArrangeType isEqualToString:LINKARRANGETYPE_MOREMOVIEPROGRAM]) {
        [self gotoMoreTV_MovieDetailVC:model];
    }
    else if ([model.linkArrangeType isEqualToString:LINKARRANGETYPE_PROGRAM]) {        // 节目
        
        // 目前节目只分为全景和华数电影、通过videoType字段区分，没有此字段则默认为全景视频
        if ([model.videoType isEqualToString:VIDEO_TYPE_3D]) {
            
            [self gotoWasuMovieDetailVC:model];
        } else {
            [self gotoVRDetailVC:model];
        }
        
    } else if ([model.linkArrangeType isEqualToString:LINKARRANGETYPE_H5_OUTER]) {     // 外部链接
        [self gotoAppOutLink:model];
    }
    else if ([model.linkArrangeType isEqualToString:LINKARRANGETYPE_INFORMATION])      // 内部链接:普通H5，资讯H5，广告
    {
        [self gotoInfoVC:model];
    }
    else if ([model.linkArrangeType isEqualToString:LINKARRANGETYPE_H5_INNER] || [model.linkArrangeType isEqualToString:LINKARRANGETYPE_H5_LOCAL]) {
        [self gotoInnerVC:model];
    }
    else if ([model.linkArrangeType isEqualToString:LINKARRANGETYPE_PLAY]) {
        [self gotoMovieAndVRPlayVC:model];
    }
    else if ([model.linkArrangeType isEqualToString:LINKARRANGETYPE_PLAY_TOPIC]) {
        [self gotoTopicPlayer:model];
    }
    else if ([model.linkArrangeType isEqualToString:LINKARRANGETYPE_SHOW]) {
        [self gotoShow:model];
    }
    else if ([model.linkArrangeType isEqualToString:LINKARRANGETYPE_LAUNCH]) {
        [self gotoLauncher:(WVRLaunchModel *)model];
    }
    else if ([model.linkArrangeType isEqualToString:LINKARRANGETYPE_SHOWLIST]) {
        [self gotoShowListVC];
    }
    else if ([model.linkArrangeType isEqualToString:LINKARRANGETYPE_CONTENT_PACKAGE]) {
        [self gotoProgramPackageVc:model];
    }
    else if ([model.linkArrangeType isEqualToString:LINKARRANGETYPE_FOOTBALLHOMEPAGE]) {
        [self showfootballUnityHomePage:model];
    }
    else if ([model.linkArrangeType isEqualToString:LINKARRANGETYPE_FOOTBALLRECOMMENDPAGE]) {
        [self showfootballUnityRecommendPage:model];
    
    } else {
        // 专题item点击可能会走到这里
        DDLogError(@"未约定的分类: %@", model.linkArrangeType);
        [self gotoDetailForProgrameType:model];
    }
}

- (void)showfootballUnityHomePage:(WVRBaseModel *)model {
    
    if (![model isKindOfClass:[WVRItemModel class]]) {
        return;
    }
    
    [[WVRMediator sharedInstance] WVRMediator_showU3DView:NO];
    
    WVRUnityActionMessageModel *msgModel = [[WVRUnityActionMessageModel alloc] init];
    msgModel.message = @"StartScene";
    msgModel.arguments = @[ @"startSoccerVR", @"MatchInfo", @"", ];
    
    [[WVRMediator sharedInstance] WVRMediator_sendMsgToUnity:msgModel];
}

- (void)showfootballUnityRecommendPage:(WVRBaseModel *)model {
    
    if (![model isKindOfClass:[WVRItemModel class]]) {
        return;
    }
    
    WVRItemModel * liveModel = (WVRItemModel *)model;
    
    NSString *behavior = liveModel.behavior ?: liveModel.linkArrangeValue;
    
    [[WVRMediator sharedInstance] WVRMediator_showU3DView:NO];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
    
    dict[@"behaviour"] = behavior;
    dict[@"matchId"] = @([[[behavior componentsSeparatedByString:@"="] lastObject] intValue]);
    // 足球播放，用户当前选择的机位
    dict[@"defaultSlot"] = model.jumpParamsDic[@"defaultSlot"] ?: @"Public";
    
    NSLog(@"startSoccerVR_%@", dict);
    
    WVRUnityActionMessageModel *msgModel = [[WVRUnityActionMessageModel alloc] init];
    msgModel.message = @"StartScene";
    msgModel.arguments = @[ @"startSoccerVR", @"MatchInfo", [[dict toJsonString] stringByReplacingOccurrencesOfString:@"\\" withString:@""], ];
    
    [[WVRMediator sharedInstance] WVRMediator_sendMsgToUnity:msgModel];
}

// MARK: - 推荐页跳转路由
- (void)gotoRecommendMoreVC:(WVRBaseModel *)model {
    
    // 因为合集页后台没有类型，分页推荐页暂定为合集页
    if ([model.recommendPageType isEqualToString:RECOMMENDPAGETYPE_PAGE]) {
        WVRSectionModel * sectionModel = [WVRSectionModel new];
        sectionModel.linkArrangeType = model.linkArrangeType;
        sectionModel.linkArrangeValue = model.linkArrangeValue;
        sectionModel.recommendAreaCodes = model.recommendAreaCodes;
        DDLogInfo(@"recommendAreaCode:%@", sectionModel.recommendAreaCode);
        NSDictionary* params = @{@"code":model.linkArrangeValue,@"subCode":[model.recommendAreaCodes firstObject]};
        WVRSetController * vc = [[WVRSetController alloc] init];
        vc.createArgs = params;
        vc.title = model.name;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navController pushViewController:vc animated:YES];
        
    } else if ([model.recommendPageType isEqualToString:RECOMMENDPAGETYPE_TITLE]) {
        
        WVRSectionModel* sectionModel = [WVRSectionModel new];
        sectionModel.linkArrangeType = model.linkArrangeType;
        sectionModel.linkArrangeValue = model.linkArrangeValue;
        sectionModel.name = model.name;
        WVRRecommendPageTitleController * vc = [WVRRecommendPageTitleController new];
        vc.createArgs = sectionModel;
//        vc.title = model.name;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navController pushViewController:vc animated:YES];
        
    } else if ([model.recommendPageType isEqualToString:RECOMMENDPAGETYPE_MIX]) {
        
        WVRSectionModel* sectionModel = [WVRSectionModel new];
        sectionModel.linkArrangeType = model.linkArrangeType;
        sectionModel.linkArrangeValue = model.linkArrangeValue;
        sectionModel.name = model.name;
        WVRRecommendPageMIXController * vc = [WVRRecommendPageMIXController new];
        vc.createArgs = sectionModel;
//        vc.title = model.name;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navController pushViewController:vc animated:YES];
    }
    else {
        DDLogError(@"recommendPageType 不匹配");
    }
}

// MARK: - 详情跳转路由
- (void)gotoDetailForProgrameType:(WVRBaseModel *)model {
    
    // 根据programType进节目详情
    if ([model.programType isEqualToString:PROGRAMTYPE_LIVE]) {
        model.linkArrangeType = LINKARRANGETYPE_LIVE;
        [self gotoLiveVC:model];
    }
    else if ([model.programType isEqualToString:PROGRAMTYPE_RECORDED]) {
            
        model.linkArrangeType = LINKARRANGETYPE_PROGRAM;
        if ([model.videoType isEqualToString:VIDEO_TYPE_3D]) {
            
            [self gotoWasuMovieDetailVC:model];
        } else {
            [self gotoVRDetailVC:model];
        }
    }
    else if ([model.programType isEqualToString:PROGRAMTYPE_MORETV_TV]) {
        model.linkArrangeType = LINKARRANGETYPE_MORETVPROGRAM;
        [self gotoMoreTV_TVDetailVC:model];
    }
    else if ([model.programType isEqualToString:PROGRAMTYPE_MORETV_MOVIE]) {
        model.linkArrangeType = LINKARRANGETYPE_MOREMOVIEPROGRAM;
        [self gotoMoreTV_MovieDetailVC:model];
    }
    else if ([model.programType isEqualToString:PROGRAMTYPE_ARRANGE]) {
        model.linkArrangeType = LINKARRANGETYPE_MANUAL_ARRANGE;
        [self gotoManualArrangeMoreVc:model];
    }else{
        DDLogError(@"programType 不匹配");
    }
}

// MARK: - 手动编排_专题
- (void)gotoManualArrangeMoreVc:(WVRBaseModel *)model {
    
    if (self.moduleName) {
        [WVRTrackEventMapping trackEvent:self.moduleName flag:[NSString stringWithFormat:@"[%@]", model.name]];
    }
    WVRManualArrangeController * vc = [[WVRManualArrangeController alloc] init];
    vc.createArgs = [WVRSectionModel new];
    ((WVRSectionModel*)(vc.createArgs)).linkArrangeType = model.linkArrangeType;
    ((WVRSectionModel*)(vc.createArgs)).linkArrangeValue = model.linkArrangeValue;
//    vc.sectionModel.name = model.name;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navController pushViewController:vc animated:YES];
}

// MARK: - 节目包_付费专题_合集
- (void)gotoProgramPackageVc:(WVRBaseModel *)model {
    
    if (self.moduleName) {
        //[WVRTrackEventMapping trackEvent:self.moduleName flag:[NSString stringWithFormat:@"[%@]", model.name]];
    }
    WVRProgramPackageController * vc = [[WVRProgramPackageController alloc] init];
    vc.createArgs = [WVRSectionModel new];
    ((WVRSectionModel*)(vc.createArgs)).linkArrangeType = model.linkArrangeType;
    ((WVRSectionModel*)(vc.createArgs)).linkArrangeValue = model.linkArrangeValue;
//    vc.sectionModel.name = model.name;
    
    [self.navController pushViewController:vc animated:YES];
}

// MARK: - 自动编排列表页
- (void)gotoAutoArrangeMoreVC:(WVRBaseModel *)model {
    
    if (self.moduleName) {
        [WVRTrackEventMapping trackEvent:self.moduleName flag:[NSString stringWithFormat:@"[%@]", model.name]];
    }
    WVRAutoArrangeController * vc = [WVRAutoArrangeController new];
    vc.createArgs = model;
    vc.title = model.name;
//    vc.sectionCode = model.linkArrangeValue;
    
    vc.hidesBottomBarWhenPushed = YES;
    [self.navController pushViewController:vc animated:YES];
}

//// MARK: - 直播类节目跳转路由
//- (void)gotoFootballLiveVC:(WVRBaseModel *)model {
//    
//    if (![model isKindOfClass:[WVRFootballModel class]]) {
//        return;
//    }
//    WVRFootballModel * liveModel = (WVRFootballModel *)model;
//    if (liveModel.liveStatus == WVRLiveStatusPlaying) {
//        
//        [self gotoLivePlayVC:liveModel];
//    } else if (liveModel.liveStatus == WVRLiveStatusNotStart) {
//        
//        [self gotoLiveDetailVC:liveModel];
//    } else if (liveModel.liveStatus == WVRLiveStatusEnd) {
//        SQToastInKeyWindow(kToastLiveOver);
//        [self gotoVRDetailVC:model];
//    }
//}

// MARK: - 直播类节目跳转路由
- (void)gotoLiveVC:(WVRBaseModel *)model {
    
    if (![model isKindOfClass:[WVRItemModel class]]) {
        return;
    }
    WVRItemModel * liveModel = (WVRItemModel *)model;
    if (liveModel.liveStatus == WVRLiveStatusPlaying) {
        
        [self gotoLivePlayVC:liveModel];
    } else if (liveModel.liveStatus == WVRLiveStatusNotStart) {
        
        [self gotoLiveDetailVC:liveModel];
    } else if (liveModel.liveStatus == WVRLiveStatusEnd) {
        
        SQToastInKeyWindow(kToastLiveOver);
    }
}

// MARK: - VR详情页_半屏播放
- (void)gotoVRDetailVC:(WVRBaseModel *)model {
    
    WVRVideoDetailVC *vc = [[WVRVideoDetailVC alloc] initWithSid:model.linkArrangeValue];
    
    if ([model isKindOfClass:[WVRHistoryModel class]]) {
        vc.curPosition = [[(WVRHistoryModel *)model playTime] longLongValue];
    }
    vc.hidesBottomBarWhenPushed = YES;
    [self.navController pushViewController:vc animated:YES];
}

// MARK: - 华数电影详情页_半屏播放
- (void)gotoWasuMovieDetailVC:(WVRBaseModel *)model {
    
    WVRWasuDetailVC *vc = [[WVRWasuDetailVC alloc] init];
    
    vc.sid = model.linkArrangeValue;
    
    if ([model isKindOfClass:[WVRHistoryModel class]]) {
        vc.curPosition = [[(WVRHistoryModel *)model playTime] longLongValue];
    }
    vc.hidesBottomBarWhenPushed = YES;
    [self.navController pushViewController:vc animated:YES];
}

- (void)gotoTopicPlayer:(WVRBaseModel *)model {
    
    if ([model isKindOfClass:[WVRSectionModel class]]) {
        WVRSectionModel* sectionModel = (WVRSectionModel *)model;
        WVRPlayerVCTopic * vc = [WVRPlayerVCTopic new];
        WVRVideoEntityTopic *ve = [WVRVideoEntityTopic new];
        ve.detailItemModels = sectionModel.itemModels;
        WVRItemModel * itemModel = [sectionModel.itemModels firstObject];
        ve.code = itemModel.code;
        ve.sid  = itemModel.code;
        ve.videoTitle = itemModel.name;
        vc.videoEntity = ve;
        ve.streamType = [self parserVideoType:itemModel];
        
        WVRNavigationController *nav = [[WVRNavigationController alloc] initWithRootViewController:vc];
        [self.navController presentViewController:nav animated:YES completion:nil];

    }else{
        NSLog(@"参数非法");
    }
}

- (WVRStreamType)parserVideoType:(WVRItemModel *)itemModel
{
    WVRStreamType streamType = STREAM_VR_VOD;
    if ([itemModel.programType isEqualToString:PROGRAMTYPE_LIVE]) {
        streamType = STREAM_VR_LIVE;
    }else if ([itemModel.programType isEqualToString:PROGRAMTYPE_RECORDED]){
        streamType = STREAM_VR_VOD;
    }else if ([itemModel.programType isEqualToString:PROGRAMTYPE_MORETV_TV]){
        streamType = STREAM_2D_TV;
    }else if([itemModel.programType isEqualToString:PROGRAMTYPE_MORETV_MOVIE]){
        streamType = STREAM_2D_TV;
    }else{
    
    }
    return streamType;
}

// MARK: - VR或华数电影全屏播放页
- (void)gotoMovieAndVRPlayVC:(WVRBaseModel *)model {
    
    if ([model isKindOfClass:[WVRSectionModel class]]) {
        WVRSectionModel* sectionModel = (WVRSectionModel *)model;
        [WVRPlayerTool showPlayerVCWithModel:[sectionModel.itemModels firstObject] items:sectionModel.itemModels];
    } else {
        WVRItemModel * itemModel = (WVRItemModel *)model;
        WVRVideoDetailType videoType = WVRVideoDetailTypeVR;
        if (itemModel.videoType_ == WVRModelVideoType3D) {
            videoType = WVRVideoDetailType3DMovie;
        }
        [self gotoPlayVC:itemModel videoType:videoType];
    }
}

// MARK: - 直播播放器页
- (void)gotoLivePlayVC:(WVRItemModel *)liveModel {
    
    [WVRTrackEventMapping trackEvent:@"liveDetail" flag:@"play"];
    
//    if (liveModel.isChargeable == YES) {
//        if (![WVRLoginTool checkAndAlertLogin]) {   // 付费 统一检测登录
//            return;
//        }
//    }
    
    WVRPlayerVCLive *viewController = [[WVRPlayerVCLive alloc] init];
    
    viewController.isFootball = [liveModel isFootball];
    
    WVRVideoEntityLive *ve = [[WVRVideoEntityLive alloc] init];
    ve.sid = liveModel.linkArrangeValue;
    ve.videoTitle = liveModel.name;
    ve.icon = liveModel.thubImageUrl;
    ve.streamType = STREAM_VR_LIVE;
    ve.displayMode = [liveModel displayMode];
    
    viewController.videoEntity = ve;
    
    [self.navController pushViewController:viewController animated:YES];
}

// MARK: - 直播预告详情页
- (void)gotoLiveDetailVC:(WVRItemModel *)liveModel {
    
    WVRLiveDetailVC *vc = [[WVRLiveDetailVC alloc] initWithSid:liveModel.linkArrangeValue];
    
    // 兼容开机启动页
    if ([liveModel isKindOfClass:[WVRSQLiveItemModel class]]) {
        vc.hasOrder = ((WVRSQLiveItemModel *)liveModel).hasOrder;
        vc.reserveLiveBlock = ((WVRSQLiveItemModel *)liveModel).reserveBlock;
        vc.backDelegate = (id<BaseBackForResultDelegate>)self.navController.visibleViewController;
    }
    
    [self.navController pushViewController:vc animated:YES];
}

// MARK: - 电视猫_电视剧详情
- (void)gotoMoreTV_TVDetailVC:(WVRBaseModel *)model {
    
    model.programType = PROGRAMTYPE_MORETV_TV;
    model.linkArrangeType = LINKARRANGETYPE_MORETVPROGRAM;
    WVRTVDetailController * vc = [WVRTVDetailController createViewController:model];
    if ([model isKindOfClass:[WVRHistoryModel class]]) {
        vc.curPosition = [[(WVRHistoryModel*)model playTime] longLongValue];
    }
    vc.hidesBottomBarWhenPushed = YES;
    [self.navController pushViewController:vc animated:YES];
}

// MARK: - 电视猫_电影详情
- (void)gotoMoreTV_MovieDetailVC:(WVRBaseModel *)model {
    
    model.programType = PROGRAMTYPE_MORETV_MOVIE;
    model.linkArrangeType = LINKARRANGETYPE_MOREMOVIEPROGRAM;
    WVRTVMovieDetailController * vc = [WVRTVMovieDetailController createViewController:model];
    if ([model isKindOfClass:[WVRHistoryModel class]]) {
        vc.curPosition = [[(WVRHistoryModel*)model playTime] longLongValue];
    }
    vc.hidesBottomBarWhenPushed = YES;
    [self.navController pushViewController:vc animated:YES];
}

// MARK: - H5外页
- (void)gotoAppOutLink:(WVRBaseModel *)model {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithUTF8String:model.linkArrangeValue]];
}

// MARK: - 资讯
- (void)gotoInfoVC:(WVRBaseModel *)model {
    
    if (![model isKindOfClass:[WVRItemModel class]]) {
        return;
    }
    WVRItemModel * itemModel = (WVRItemModel *)model;
    WVRWebViewController *vc = [[WVRWebViewController alloc] init];
    vc.URLStr = itemModel.infUrl;
    vc.title = itemModel.infTitle;
    vc.isNews = ([itemModel.linkArrangeType isEqualToString:LINKARRANGETYPE_INFORMATION]);     // 资讯
    vc.hidesBottomBarWhenPushed = YES;
    [self.navController pushViewController:vc animated:YES];
}

// MARK: - H5内页
- (void)gotoInnerVC:(WVRBaseModel *)model {
    
    WVRWebViewController *vc = [[WVRWebViewController alloc] init];
    if (![model isKindOfClass:[WVRItemModel class]]) {
        return;
    }
    WVRItemModel * itemModel = (WVRItemModel *)model;
    vc.URLStr = itemModel.linkArrangeValue;
    vc.title = itemModel.name;
    vc.isNews = NO;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navController pushViewController:vc animated:YES];
}

// MARK: - 我的礼品
+ (void)jumpToGiftPage {
    
    UITabBarController *tab = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    UINavigationController *nav = tab.selectedViewController;
    
    UIViewController *tmpVC = [tab presentedViewController];        // 跳转前记得把模态界面消除 —— 推送
    if (tmpVC) {
        [tmpVC dismissViewControllerAnimated:NO completion:nil];
    }
    
    if (nav.viewControllers.count > 1) {
        [nav popToRootViewControllerAnimated:NO];
    }

    tab.selectedIndex = kAccountTabBarIndex;
    
    UINavigationController *accountNav = tab.viewControllers[kAccountTabBarIndex];
    UIViewController *accountVC = [accountNav.viewControllers firstObject];
    
    WVRRewardController *rewardVC = [[WVRRewardController alloc] init];
    rewardVC.isFormUnity = YES;
    [nav pushViewController:rewardVC animated:YES];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    
    if ([accountVC respondsToSelector:@selector(updateRewardDot:)]) {
        [accountVC performSelector:@selector(updateRewardDot:) withObject:@NO];
    }
#pragma clang diagnostic pop
}

@end
