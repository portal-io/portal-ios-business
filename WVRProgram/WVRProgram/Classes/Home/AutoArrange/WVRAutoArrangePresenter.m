//
//  WVRCollectionViewPresenter.m
//  WhaleyVR
//
//  Created by qbshen on 2017/7/18.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRAutoArrangePresenter.h"
#import "SQCollectionViewDelegate.h"
#import "WVRAutoArrangeControllerProtocol.h"
#import "WVRAutoArrangeModel.h"

#import "WVRBaseViewSection.h"
#import "WVRViewModelDispatcher.h"

@interface WVRAutoArrangePresenter ()

@property (nonatomic) id<WVRAutoArrangeControllerProtocol> gView;
@property (nonatomic) WVRAutoArrangeModel *mAutoArrangeModel;

@property (nonatomic, strong) SQCollectionViewDelegate * gDelegate;

@property (nonatomic) NSMutableDictionary * mOriginDic;

@property (nonatomic) WVRSectionModel * mSectionModel;
@property (nonatomic, strong) WVRSectionModel * gParams;

@property (nonatomic, copy) void(^endRefreshBlock)();
@property (nonatomic, copy) void(^endBlock)(BOOL isNoMore);

@end
@implementation WVRAutoArrangePresenter

-(instancetype)initWithParams:(id)params attchView:(id<WVRViewProtocol>)view
{
    self = [super init];
    if (self) {
        if ([view conformsToProtocol:@protocol(WVRAutoArrangeControllerProtocol)]) {
            self.gView = (id<WVRAutoArrangeControllerProtocol>)view;
        }else{
            NSException *exception = [[NSException alloc] initWithName:@"" reason:@"view not conformsTo WVRAutoArrangeViewCProtocol" userInfo:nil];
            @throw exception;
        }
        self.gParams = params;
        self.mAutoArrangeModel = [WVRAutoArrangeModel new];
        self.mOriginDic = [NSMutableDictionary new];
    }
    return self;
}


-(SQCollectionViewDelegate *)gDelegate
{
    if (!_gDelegate) {
        _gDelegate = [[SQCollectionViewDelegate alloc] init];
    }
    return _gDelegate;
}


#pragma WVRPresenterProtocol

-(void)fetchData
{
    [self requestInfo];
}

#pragma WVRListPresenterProtocol

-(void)fetchRefreshData
{
    [self headerRefresh];
}

-(void)fetchMoreData
{
    [self footerMore];
}


- (void)requestInfo {
    
    if (self.mSectionModel.itemModels.count==0) {
        [self headerRefresh];
    }
}

- (void)headerRefresh{
    
    if (self.mSectionModel.itemModels.count==0) {
        [self.gView showLoadingWithText:@""];
    }
    [self httpRequest];
}

- (void)httpRequest {
    
    kWeakSelf(self);
    [self.mAutoArrangeModel http_recommendPage:self.gParams.linkArrangeValue successBlock:^(NSDictionary *args) {
        [weakself headerRefreshSuccessBlock:args];
    } failBlock:^(NSString *args) {
        [weakself.gView hidenLoading];
        [weakself networkFaild];
    }];
}

- (void)httpTVRequest {
    
    kWeakSelf(self);
    [self.mAutoArrangeModel http_recommendTVPage:self.gParams.linkArrangeValue successBlock:^(NSDictionary *args) {
        [weakself headerRefreshSuccessBlock:args];
    } failBlock:^(NSString *args) {
        [weakself.gView hidenLoading];
        [weakself networkFaild];
    }];
}

- (void)headerRefreshSuccessBlock:(NSDictionary*)args {
    
    [self.gView hidenLoading];
    self.mSectionModel = args[@(0)];
    if (self.mSectionModel.itemModels.count==0) {
        [self.gView showNullViewWithTitle:nil icon:nil];
        return ;
    }
    self.mSectionModel.sectionType = WVRSectionModelTypeArrange;
    self.mOriginDic[@(0)] = [self sectionInfo:self.mSectionModel];

    if (!self.gView.getCollectionView.delegate) {
        [self.gView setDelegate:self.gDelegate andDataSource:self.gDelegate];
    }
    [self.gView reloadData];
    [self endRefresh];
}

- (void)footerMore {
    
    
    if (self.mSectionModel.pageNum == self.mSectionModel.totalPages-1) {
        [self endRefreshNoMore];
        return;
    }
    if (self.mSectionModel.itemModels.count==0) {
        [self.gView showLoadingWithText:@""];
    }
    [self httpMoreRequest];
}

- (void)httpMoreRequest {
    
    kWeakSelf(self);
    [self.mAutoArrangeModel http_recommendPageMore:self.gParams.linkArrangeValue successBlock:^(NSDictionary *args) {
        [weakself footerMoreSuccessBlock:args];
    } failBlock:^(NSString *args) {
        [weakself.gView hidenLoading];
        [weakself networkFaild];
    }];
}

- (void)footerMoreSuccessBlock:(NSDictionary*)args {
    
    [self.gView hidenLoading];
    self.mSectionModel = args[@(0)];
    self.mSectionModel.sectionType = WVRSectionModelTypeArrange;
    self.mOriginDic[@(0)] = [self sectionInfo:self.mSectionModel];
    if (!self.gView.getCollectionView.delegate) {
        [self.gView setDelegate:self.gDelegate andDataSource:self.gDelegate];
    }
    [self.gView reloadData];
    if (self.mSectionModel.pageNum == self.mSectionModel.totalPages) {
        [self endRefreshNoMore];
    }else{
        [self endRefresh];
    }
}

- (WVRBaseViewSection *)sectionInfo:(WVRSectionModel *)sectionModel {
    
    //    NSLog(@"recommendAreaType:%ld",(long)sectionModel.sectionType);
    WVRBaseViewSection * sectionInfo = nil;
    NSInteger type = sectionModel.sectionType;
    sectionInfo = [WVRViewModelDispatcher dispatchSection:[NSString stringWithFormat:@"%d",(int)type] args:sectionModel];//[self getADSectionInfo:sectionModel type:type];
    [sectionInfo registerNibForCollectionView:[self.gView getCollectionView]];
//    sectionInfo.viewController = (UIViewController*)self.gView;
    return sectionInfo;
}

- (void)endRefresh {
    [self.gView stopHeaderRefresh];
    [self.gView stopFooterMore:NO];
}

- (void)endRefreshNoMore {
    [self.gView stopFooterMore:YES];
    
}

- (void)networkFaild {
    [self endRefresh];
    kWeakSelf(self);
    if (self.mSectionModel.itemModels.count==0) {
        [self.gView showNetErrorVWithreloadBlock:^{
            [weakself requestInfo];
        }];
    }
}

@end
