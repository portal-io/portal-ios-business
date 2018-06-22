//
//  WVRCollectionPresenter.m
//  WhaleyVR
//
//  Created by qbshen on 2017/7/24.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRCollectionPresenter.h"
#import "WVRCollectionVCModel.h"
#import "WVRCollectionViewCProtocol.h"

@interface WVRCollectionPresenter ()

@property (nonatomic, weak) id<WVRCollectionViewCProtocol> gView;

@end
@implementation WVRCollectionPresenter

- (void)requestInfo {
    
    [self.gView showLoadingWithText:@""];
    [self headerRequestInfo];
}

- (void)headerRequestInfo {
    
    kWeakSelf(self);
    [WVRCollectionVCModel http_CollectionGetWithSuccessBlock:^(WVRCollectionVCModel *vcModel) {
        [weakself httpCollectionGetSuccessBlock:vcModel];
    } failBlock:^(NSString *errMsg) {
        [weakself httpFailBlock:errMsg];
    }];
    
}

- (void)httpCollectionGetSuccessBlock:(WVRCollectionVCModel*)vcModel {
    
    [self.gView hidenLoading];
    [self.gView reloadData];
}

- (void)httpFailBlock:(NSString*)errMsg {
    
    [self.gView hidenLoading];
    kWeakSelf(self);
    [self.gView showNetErrorVWithreloadBlock:^{
        [weakself requestInfo];
    }];
}

@end
