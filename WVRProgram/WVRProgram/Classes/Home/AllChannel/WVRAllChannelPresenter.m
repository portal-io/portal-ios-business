//
//  WVRAllChannelPresenter.m
//  WhaleyVR
//
//  Created by qbshen on 2017/7/25.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRAllChannelPresenter.h"
#import "WVRAllChannelViewModel.h"
#import "WVRItemModel.h"
#import "WVRViewModelDispatcher.h"
#import "WVRBaseViewSection.h"
#import "WVRSectionModel.h"

#import "WVRAllChannelCProtocol.h"

@interface WVRAllChannelPresenter ()

@property (nonatomic, strong) id<WVRAllChannelCProtocol> gView;

@property (nonatomic, strong) SQCollectionViewDelegate * gDelegate;

@property (nonatomic, strong) NSMutableDictionary * gOriginDic;

@property (nonatomic, strong) WVRAllChannelViewModel* gViewModel ;

@end

@implementation WVRAllChannelPresenter

-(NSMutableDictionary *)gOriginDic
{
    if (!_gOriginDic) {
        _gOriginDic = [[NSMutableDictionary alloc] init];
    }
    return _gOriginDic;
}

-(WVRAllChannelViewModel *)gViewModel
{
    if (!_gViewModel) {
        _gViewModel = [WVRAllChannelViewModel new];
    }
    return _gViewModel;
}

-(SQCollectionViewDelegate *)gDelegate
{
    if (!_gDelegate) {
        _gDelegate = [[SQCollectionViewDelegate alloc] init];
    }
    return _gDelegate;
}

- (void)fetchData {
    
    //    if (!self.mViewModel) {
    
    //    }
    if (self.gOriginDic.count == 0) {
        [self.gView showLoadingWithText:nil];
    }
    kWeakSelf(self);
    [self.gViewModel http_allChannel:^(NSArray<WVRItemModel *> *originData) {
        [weakself successBlock:originData];
    } andFailBlock:^(NSString * msg) {
        [weakself failBlock:msg];
    }];
}

-(void)fetchRefreshData
{
    [self fetchData];
}

- (void)headerRequestInfo {
    
    WVRAllChannelViewModel* mViewModel = [WVRAllChannelViewModel new];
    kWeakSelf(self);
    [mViewModel http_allChannel:^(NSArray<WVRItemModel *> *originData) {
        [weakself successBlock:originData];
    } andFailBlock:^(NSString * msg) {
        [weakself failBlock:msg];
    }];
}

- (void)successBlock:(NSArray<WVRItemModel *> *)originData {
    [self.gView hidenLoading];
    [self.gView stopHeaderRefresh];
    if (originData.count == 0) {
        [self.gView showNullViewWithTitle:nil icon:nil];
        return;
    }
    
    WVRSectionModel * sectionModel = [WVRSectionModel new];
    sectionModel.sectionType = WVRSectionModelTypeAllChannel;
    sectionModel.itemModels = [NSMutableArray arrayWithArray:originData];
    
    WVRCollectionViewSectionInfo* sectionInfo = [self sectionInfo:sectionModel];
    self.gOriginDic[@(0)] = sectionInfo;
    [self.gView setDelegate:self.gDelegate andDataSource:self.gDelegate];
    [self.gDelegate loadData:self.gOriginDic];
    [self.gView reloadData];
}

- (WVRBaseViewSection *)sectionInfo:(WVRSectionModel *)sectionModel {
    
    //    NSLog(@"recommendAreaType:%ld", (long)sectionModel.sectionType);
    WVRBaseViewSection * sectionInfo = nil;
    NSInteger type = sectionModel.sectionType;
    sectionInfo = [WVRViewModelDispatcher dispatchSection:[NSString stringWithFormat:@"%d", (int)type] args:sectionModel];//[self getADSectionInfo:sectionModel type:type];
    [sectionInfo registerNibForCollectionView:[self.gView getCollectionView]];
    //    sectionInfo.viewController = self;
    return sectionInfo;
}

- (void)failBlock:(NSString *)msg {
    [self.gView hidenLoading];
    [self.gView stopHeaderRefresh];
    kWeakSelf(self);
    if (self.gOriginDic.count==0) {
        [self.gView showNetErrorVWithreloadBlock:^{
            [weakself fetchData];
        }];
    }
    
}


@end
