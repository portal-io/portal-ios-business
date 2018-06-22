//
//  WVRDetailVC+BottomView.m
//  WhaleyVR
//
//  Created by qbshen on 2017/1/16.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRDetailBottomVTool.h"
#import "WVRTVVideoDetailModel.h"
#import "WVRCollectionVCModel.h"

#import "WVRUMShareView.h"
#import "WVRBIModel.h"

#import "WVRMediator+AccountActions.h"

@interface WVRDetailBottomVTool ()<WVRVideoDBottomViewDelegate>

@property (nonatomic, weak) UIView * mParentV;
@property (nonatomic) BOOL isCollection;
@property (nonatomic) WVRTVItemModel * mItemModel;
@property (nonatomic) WVRVideoDBottomVDownStatus downStatus;

@end


@implementation WVRDetailBottomVTool

+ (WVRDetailBottomVTool *)loadBottomView:(WVRTVItemModel *)model parentV:(UIView *)parentV {
    
   return [[WVRDetailBottomVTool alloc] initWithModel:model parentV:parentV];
}

- (instancetype)initWithModel:(WVRTVItemModel *)model parentV:(UIView *)parentV {
    self = [super init];
    if (self) {
        self.mItemModel = model;
        self.mParentV = parentV;
        if (!self.mBottomView) {
            
            float width = parentV.width;
            self.mBottomView = [[WVRVideoDetailBottomView alloc] initWithFrame:CGRectMake(0, parentV.height - HEIGHT_BOTTOMV, width, HEIGHT_BOTTOMV)];
            self.mBottomView.delegate = self;
            
            [self addLineViewForBottomView];
            
            // 嵌套到倒数第二层
            NSInteger index = parentV.subviews.count - 2;
            [parentV insertSubview:self.mBottomView atIndex:index];
            
            if (self.mItemModel.detailType == WVRVideoDetailTypeVR) {
                
                [self.mBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                    
                    make.left.equalTo(self.mBottomView.superview);
                    make.width.mas_equalTo(width);
                    make.height.mas_equalTo(HEIGHT_BOTTOMV);
                }];
            }
        }
        [self requestCollectionStatus];
    }
    
    return self;
}

- (void)updateDownStatus:(WVRVideoDownloadStatus)videoStatus {
    
    BOOL needCharge = self.mItemModel.isChargeable;
    if (needCharge || self.mItemModel.downloadUrl.length == 0 || self.mItemModel.videoType_ != WVRModelVideoTypeVR) {
        self.downStatus = WVRVideoDBottomVDownStatusNeedCharge;
        [self.mBottomView updateDownBtnStatus:self.downStatus];
    } else {
        if (videoStatus == WVRVideoDownloadStatusDefault) {
            self.downStatus = WVRVideoDBottomVDownStatusEnable;
            [self.mBottomView updateDownBtnStatus:self.downStatus];
        } else {
            self.downStatus = WVRVideoDBottomVDownStatusDown;
            [self.mBottomView updateDownBtnStatus:self.downStatus];
        }
    }
}

- (void)requestCollectionStatus {
    
    kWeakSelf(self);
//    SQShowProgressIn(self.mParentV.window);
    [WVRCollectionVCModel http_CollectionOneWithModel:self.mItemModel successBlock:^(WVRCollectionModel *collectionModel) {
        [weakself httpCollectionStatusBlock:collectionModel];
    } failBlock:^(NSString *errMsg) {
        [weakself httpCollectionFailBlock:errMsg];
    }];
}

- (void)httpCollectionStatusBlock:(WVRCollectionModel *)collectionModel {
    
//    SQHideProgressIn(self.mParentV.window);
    self.isCollection = collectionModel? YES:NO;
    [self.mBottomView updateCollectionDone:self.isCollection];
}

- (void)httpCollectionFailBlock:(NSString *)errMsg {
    
//    SQHideProgressIn(self.mParentV.window);
//    SQToastInKeyWindow(errMsg);
}

- (void)addLineViewForBottomView {
    
    float width = MIN(SCREEN_HEIGHT, SCREEN_WIDTH);
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, adaptToWidth(6))];
    line.backgroundColor = k_Color10;
    
    if (_mItemModel.detailType == WVRVideoDetailTypeVR) {
        line.y = _mBottomView.height;
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, -1, width, 1)];
        line2.backgroundColor = line.backgroundColor;
        
        [_mBottomView addSubview:line2];
    } else {
        line.y = 0 - line.height;
    }
    
    [_mBottomView addSubview:line];
}

#pragma detailView - delegate

- (void)onClickItemType:(WVRVideoDBottomViewType)type bottomView:(WVRVideoDetailBottomView *)view {
    
    switch (type) {
        case WVRVideoDBottomViewTypeDown:
            [self downBtnOnClick];
            break;
        case WVRVideoDBottomViewTypeCollection:
            [self httpCollection:view];
            break;
        case WVRVideoDBottomViewTypeShare:
            [self shareOnClick];
            break;
        default:
            break;
    }
}

- (void)downBtnOnClick {
    
    if (self.downStatus == WVRVideoDBottomVDownStatusNeedCharge) {
        SQToastInKeyWindow(@"版权原因，暂不提供缓存");
    } else {
        if (self.startDown) {
            self.startDown();
        }
    }
}

- (void)didSelectItemModel:(WVRTVItemModel *)itemModel {
    
}

- (void)httpCollection:(WVRVideoDetailBottomView *)view {
    
    if ([[WVRMediator sharedInstance] WVRMediator_CheckAndAlertLogin:nil]) {
        
        if (self.isCollection) {
            [self httpCollectionDel:view];
        } else {
            
            [self httpCollectionSave:view];
        }
    }
}

- (void)httpCollectionSave:(WVRVideoDetailBottomView *)view {
    
    kWeakSelf(self);
//    SQShowProgressIn(self.mParentV.window);
    [WVRCollectionVCModel http_CollectionSaveWithModel:self.mItemModel successBlock:^{
        SQToastInKeyWindow(kToastCollectionSuccess);
        [weakself httpCollectionSaveSuccessBlock];
    } failBlock:^(NSString *errMsg) {
        SQToastInKeyWindow(kToastCollectionFail);
//        [weakself httpCollectionFailBlock:errMsg];
    }];
}

- (void)httpCollectionSaveSuccessBlock {
    
//    SQHideProgressIn(self.mParentV.window);
    [self.mBottomView updateCollectionDone:YES];
    self.isCollection = YES;
    
    if (self.didCollection) {
        self.didCollection();
    }
}

- (void)httpCollectionDel:(WVRVideoDetailBottomView *)view {
    
    kWeakSelf(self);
//    SQShowProgressIn(self.mParentV.window);
    [WVRCollectionVCModel http_CollectionDelWithModel:self.mItemModel successBlock:^{
        SQToastInKeyWindow(kToastCancelCollectionSuccess);
        [weakself httpCollectionDelSuccessBlock];
    } failBlock:^(NSString *errMsg) {
        SQToastInKeyWindow(kToastCancelCollectionFail);
    }];
}

- (void)httpCollectionDelSuccessBlock {
    
//    SQHideProgressIn(self.mParentV.window);
    [self.mBottomView updateCollectionDone:NO];
    self.isCollection = NO;
}

#pragma mark - share

- (void)shareOnClick {
    // 分享功能模块
    WVRShareType type = WVRShareTypeVideoDetails;
    
    switch (self.mItemModel.linkType_) {
        case WVRLinkTypeVR:
            type = WVRShareTypeVideoDetails;
            break;
        case WVRLinkType3DMovie:
            type = WVRShareType3DMovie;
            break;
        case WVRLinkTypeMoreTV:
            type = WVRShareTypeMoreTV;
            break;
        case WVRLinkTypeMoreMovie:
            type = WVRShareTypeMoreMovie;
            break;
            
        default:
            break;
    }
    [WVRUMShareView shareWithContainerView:self.mParentV
                                                                  sID:self.mItemModel.parentCode
                                                              iconUrl:self.mItemModel.thubImageUrl
                                                                title:self.mItemModel.name
                                                                intro:self.mItemModel.intrDesc
                                                                mobId:nil
                                                            shareType:type ];
    
}

@end
