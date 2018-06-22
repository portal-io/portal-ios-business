//
//  WVRBusinessCoopController.m
//  WhaleyVR
//
//  Created by qbshen on 2017/5/24.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRBusinessCoopController.h"
#import "WVRUMShareView.h"

@interface WVRBusinessCoopController ()<UIWebViewDelegate>

@property (nonatomic, weak) UIWebView *webView;

@end


@implementation WVRBusinessCoopController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"商务合作";
    
    [self createWebView];
    [self createRightBarItem];
}

- (void)createWebView {
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:webView];
    _webView = webView;
    
    [self startLoadRequest];
}

- (void)createRightBarItem {
    
    UIImage *image = [[UIImage imageNamed:@"icon_MA_share"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(rightBarShareItemClick)];
}

- (void)startLoadRequest {
    
    if (self.netErrorView.superview) {
        [self.netErrorView removeFromSuperview];
    }
    NSString *urlStr = [WVRUserModel aboutUsShareLink];
    
//    if ([[WVRUserModel sharedInstance] isTest]) {
//        urlStr = @"http://minisite.test.snailvr.com/app-inner-aboutus-h5/";
//    } else {
//        urlStr = @"http://minisite-c.snailvr.com/app-inner-aboutus-h5/";
//    }
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
    
    [self showProgress];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    if (self.netErrorView) {
        [self.netErrorView removeFromSuperview];
    }
    [self hideProgress];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    [self networkFaild];
}

#pragma mark - private func

- (void)networkFaild {
    
    [self hideProgress];
    
    // 未有界面
    if (!self.netErrorView) {
        
//        WVRNetErrorView *view = [[WVRNetErrorView alloc] init];
//        [view.button addTarget:self action:@selector(startLoadRequest) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:view];
//        
//        self.netErrorView = view;
        
    } else {
        
        [self.view addSubview:self.netErrorView];
    }
}

#pragma mark - action

// 分享
- (void)rightBarShareItemClick {
    
    [WVRUMShareView shareForAbout];
}

@end
