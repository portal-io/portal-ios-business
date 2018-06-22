//
//  WVRWebViewController.m
//  VRManager
//
//  Created by Snailvr on 16/7/14.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRWebViewController.h"
#import <WebKit/WebKit.h>
#import "WVRUMShareView.h"
#import "YYModel.h"
#import <SDWebImage/HUPhotoBrowser.h>
#import "WVRUserModel.h"
//#import "WVRItemModel.h"
//#import "WVRGotoNextTool.h"
#import "NSDictionary+Extension.h"
#import "WVRWebView.h"
//#import "WVRRewardController.h"
//#import "WVRLoginTool.h"

#import "WVRMediator+ProgramActions.h"
#import "UIViewController+HUD.h"
#import "WVRAppContextHeader.h"

#import "WVRNetErrorView.h"

@interface WVRWebViewController ()<WVRWebViewDelegate>

@property (nonatomic, weak) WVRWebView *webView;

@property (nonatomic, assign, getter = isLoadOver) BOOL loadOver;

@property (nonatomic, copy) NSString *shareCallBackId;
@property (nonatomic, copy) NSString *userInfoCallBackId;

@property (nonatomic, assign) BOOL isHybridPage;

@end


@implementation WVRWebViewController

#pragma mark - lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    [self uploadViewCount];
    [self drawUI];
    [self registerObserverEvent];
    
    if (_isNews) {
        UIImage *image = [[UIImage imageNamed:@"icon_MA_share"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(rightBarShareItemClick)];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:self.needHideNav animated:YES];
    
//    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.webView execSend:kExecPageResume withPayload:@{ @"status" : @1 }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (!self.navigationController) {
        [self hideProgress];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    [self.webView execSend:kExecPagePause withPayload:@{ @"status" : @1 }];
}

- (void)drawUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGRect rect = (self.needHideNav) ? self.view.bounds : CGRectMake(0, kNavBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - kNavBarHeight);
    
    WVRWebViewUseType type = WVRWebViewUseTypeHybrid;
    if (self.isNews) { type = WVRWebViewUseTypeNews; }
    
    WVRWebView *webView = [[WVRWebView alloc] initWithFrame:rect URL:[self realURLStr] params:nil liveParam:nil useType:type];
    webView.realDelegate = self;
    webView.allowsInlineMediaPlayback = YES;
    [self.view addSubview:webView];
    _webView = webView;
    
    [self showProgress];
}

- (void)startLoadRequest {
    
    if (self.netErrorView) { [self.netErrorView removeFromSuperview]; }
    
    [_webView reloadWithURL:[self realURLStr]];
}

//设置样式
- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void)dealloc {
    
    DebugLog(@"dealloc");
    
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
}

#pragma mark - Notification

- (void)registerObserverEvent {      // 界面"暂停／激活"事件注册
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveWebShareDoneNotification:) name:kWebShareDoneNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)appWillEnterForeground:(NSNotification *)notification {
    
    [self.webView execSend:kExecPageResume withPayload:@{ @"status" : @1 }];
}

- (void)appDidEnterBackground:(NSNotification *)notification {
    
    [self.webView execSend:kExecPagePause withPayload:@{ @"status" : @1 }];
}

#pragma mark - getter

- (NSString *)realURLStr {
    
    if (_isNews) {
        return self.URLStr;
    }
    
    NSString *realURL = [self.URLStr stringByRemovingPercentEncoding];
    realURL = [realURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    return realURL;
}

#pragma mark - request

// 上传播放记录 request

- (void)uploadViewCount {
    
    if (_isNews) {
        
        // beta
//        [WVRAppModel uploadViewInfoWithCode:self.code programType:@"webpage" videoType:@"vr" type:@"view" sec:nil title:self.title];
    }
}

#pragma mark - setter

- (void)setLoadOver:(BOOL)loadOver {
    
    _loadOver = loadOver;
    
    if (loadOver) { [self hideProgress]; }
}

#pragma mark - WVRWebViewDelegate

- (void)webViewDidLoad {
    
    if (self.netErrorView) {
        [self.netErrorView removeFromSuperview];
    }
    [self hideProgress];
}

- (void)webViewLoadFail {
    
    [self networkFaild];
}

- (void)actionOnExit {
    
    [self exitPage];
}

- (void)actionSetIsHybridPage:(BOOL)isHybrid {
    
    self.isHybridPage = isHybrid;
    self.webView.scrollView.bounces = NO;
}

- (NSString *)actionGetLoginInfo {
    
    NSString *info = @"";
    WVRUserModel *model = [WVRUserModel sharedInstance];
    if (model.isisLogined) {
        
        NSDictionary *dict = [self convertUserInfo:model];
        info = [dict toJsonString];
    }
    return info;
}

- (void)actionToLoginWithCallbackId:(NSString *)callbackId {
    
    // beta
    
//    kWeakSelf(self);
//    [WVRLoginTool toGoLogin:^{
//        
//        WVRUserModel *model = [WVRUserModel sharedInstance];
//        NSDictionary *dict = [weakself convertUserInfo:model];
//        [weakself.webView execSend:callbackId withPayload:dict];
//        
//    } loginCanceledBlock:^{
//        
//        [weakself.webView execSend:callbackId withPayload:@{}];
//    }];
}

- (void)actionSetIsLoadOver {
    
    [self setLoadOver:YES];
}

- (void)actionShowImages:(NSDictionary *)imagesDict {
    
    [self showImages:imagesDict];
}

- (void)actionShareWithInfo:(NSDictionary *)shareInfo callbackId:(NSString *)callbackId {
    
    self.shareCallBackId = callbackId;
    [self action_share:shareInfo];
}

- (void)actionJumpPageWithInfo:(NSDictionary *)infoDict {
    
    [[WVRMediator sharedInstance] WVRMediator_gotoNextVC:infoDict];
}

- (void)actionJumpToInsideWebPage:(NSDictionary *)infoDict {
    
    [self jumpToInsideWebPage:infoDict];
}

- (void)actionDoHttpRequest:(WVRWebRequest *)webRequest {
    
    [self executeRequest:webRequest];
}

- (void)actionGoGiftPage {
    
    UIViewController *vc = [[WVRMediator sharedInstance] WVRMediator_RewardViewController];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionJump:(NSDictionary *)itemModelDic {
    
    [[WVRMediator sharedInstance] WVRMediator_gotoNextVC:itemModelDic];
}

#pragma mark - exec

- (void)sendHttpResonse:(WVRWebRequest *)request withData:(NSString *)data code:(int)code isFromCache:(BOOL)fromCache {
    
    NSMutableDictionary *response = [NSMutableDictionary dictionary];
    
    [response setValue:@(code) forKey:@"code"];
    [response setValue:@(fromCache) forKey:@"fromCache"];
    [response setValue:(code == 0) ? @"null" : data forKey:@"msg"];
    [response setValue:(code == 0) ? data : @"null" forKey:@"data"];
    
    [_webView execSend:request.callbackId withPayload:[response copy]];
}

- (void)executeRequest:(WVRWebRequest *)webReq {
    
    NSString *url = webReq.requestModel.url;
    NSString *func = webReq.requestModel.method;
    
    kWeakSelf(self);
    
    [WVRWebRequest executeRequest:func URL:url withParams:[self getBodyParam:webReq] completionBlock:^(id responseObj, NSError *error) {
        
        if (!error) {
            
            [weakself sendHttpResonse:webReq withData:responseObj code:0 isFromCache:NO];
            
        } else {
            
            [weakself sendHttpResonse:webReq withData:error.description code:1 isFromCache:NO];
        }
    }];
}

- (NSDictionary *)getBodyParam:(WVRWebRequest *)request {
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSArray *paramArray = request.requestModel.params;
    
    for (int i = 0; i < [paramArray count]; i ++) {
        NSString *param = [paramArray objectAtIndex:i];
        NSArray *parray = [param componentsSeparatedByString:@"="];
        if ([parray count] < 2) {
            continue;
        }
        [paramDic setValue:parray[1] forKey:parray[0]];
    }
    
    return [paramDic copy];
}

- (void)action_share:(NSDictionary *)params {
    
    NSDictionary *dict = params;
    
//        1表示QQ
//        2表示Weibo
//        3表示微信
//        4表示微信朋友圈
//        5表示QQ空间
    int platform = [dict[@"platform"] intValue];
    NSString *title = dict[@"title"];
    NSString *url = dict[@"url"];
    NSString *imgUrl = dict[@"imgUrl"];
    NSString *desc = dict[@"desc"];
//    int mediaType = [dict[@"mediaType"] intValue];
    
    WVRUMShareView *shareView = [WVRUMShareView shareWithContainerView:nil
                                                                   sID:nil
                                                               iconUrl:imgUrl
                                                                 title:title
                                                                 intro:desc
                                                              shareURL:url
                                                             shareType:WVRShareTypeH5];
    shareView.isH5CallShare = YES;
    
    [UIView animateWithDuration:0.2 animations:^{
        
        self.view.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        int idx = [self platformExchage:platform];
        [shareView shareToIndex:idx];
    }];
}

- (void)networkFaild {
    
    [self hideProgress];
    
    // 未有界面
    if (!self.netErrorView) {
        
        WVRNetErrorView *view = [[WVRNetErrorView alloc] init];
        [view.button addTarget:self action:@selector(startLoadRequest) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:view];
        
        self.netErrorView = view;
        
    } else {
        
        [self.view addSubview:self.netErrorView];
    }
}

#pragma mark - action

- (void)rightBarShareItemClick {
    
    WVRShareType type = _isNews ? WVRShareTypeNews : WVRShareTypeH5;
    
    [WVRUMShareView shareWithContainerView:kRootViewController.view
                                              sID:@""
                                          iconUrl:nil
                                            title:self.title
                                            intro:@""
                                         shareURL:self.URLStr
                                        shareType:type];
}

- (void)jumpToInsideWebPage:(NSDictionary *)params {
    
    WVRWebViewController *vc = [[WVRWebViewController alloc] init];
    
    NSDictionary *titleBarModel = params[@"titleBarModel"];
    vc.title = titleBarModel[@"title"] ?: @"";
    vc.needHideNav = ([titleBarModel[@"type"] intValue] != 1);
    vc.URLStr = params[@"url"];
    vc.isNews = params[@"isNews"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showImages:(NSDictionary *)params {
    
    NSInteger idx = [params[@"index"] integerValue];
    
    NSArray *urls = params[@"imgs"];
    
    [HUPhotoBrowser showFromImageView:nil withURLStrings:urls placeholderImage:[UIImage imageNamed:@"placeholder"] atIndex:idx dismiss:nil];
}

#pragma mark - Notification

- (void)keyboardWillHide:(NSNotification *)noti {
    
    if (![self isCurrentViewControllerVisible]) {   // 保护
        return;
    }
    
    [_webView execKeyboardHide:YES keyboardHeight:0];
}

- (void)receiveWebShareDoneNotification:(NSNotification *)noti {
    
    if (![self isCurrentViewControllerVisible]) {   // 保护
        return;
    }
    
    NSDictionary *dict = noti.userInfo;
    
    [_webView execSend:_shareCallBackId withPayload:dict];
    
    _shareCallBackId = @"";
}

#pragma mark - 私有方法

- (int)platformExchage:(int)webPlatform {
    
    if (webPlatform == 1) {
        return kSharePlatformQQ;
    } else if (webPlatform == 2) {
        
        return kSharePlatformSina;
    } else if (webPlatform == 3) {
        
        return kSharePlatformWechat;
    } else if (webPlatform == 4) {
        
        return kSharePlatformFriends;
    } else if (webPlatform == 5) {
        
        return kSharePlatformQzone;
    } else if (webPlatform == 6) {
        
        return kSharePlatformLink;
    }
    
    return 0;
    NSLog(@"未约定的分享平台");
}


- (void)leftBarButtonClick {
    
    if (self.isLoadOver) {
        [_webView execCaptureExit];
    } else {
        [self exitPage];
    }
}

// 退出当前界面 返回
- (void)exitPage {
    
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSDictionary *)convertUserInfo:(WVRUserModel *)model {
    
    NSMutableDictionary *tokenDic = [NSMutableDictionary dictionary];
    tokenDic[@"accesstoken"] = model.sessionId;
    tokenDic[@"refreshtoken"] = model.refreshtoken;
    tokenDic[@"expiretime"] = model.expiration_time;
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    infoDic[@"deviceId"] = model.deviceId;
    infoDic[@"account_id"] = model.accountId;
    infoDic[@"nickname"] = model.username;
    infoDic[@"mobile"] = model.mobileNumber;
    infoDic[@"avatar"] = model.loginAvatar;
    infoDic[@"accessTokenBean"] = tokenDic;
    infoDic[@"isLoginUser"] = @(model.isisLogined);
    
    NSDictionary *dict = @{ @"user": infoDic,
                            @"status":@(1),
                            };
    
    return dict;
}

@end
