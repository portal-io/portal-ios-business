//
//  WVRSmallPlayerPresenter.m
//  WhaleyVR
//
//  Created by qbshen on 2017/2/15.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRSmallPlayerPresenter.h"
#import "WVRSmallPlayerViewPresenter.h"
#import "WVRLivePlayerViewPresenter.h"
#import "WVRLiveRecBannerItemView.h"
#import "WVRVideoDetailVCModel.h"
#import "WVRSQLiveDetailModel.h"
#import "WVRMediaModel.h"
#import "WVRParseUrl.h"
#import "WVRVideoEntity.h"
#import "WVRVideoDetailViewModel.h"

@interface WVRSmallPlayerPresenter ()

@property (nonatomic, strong) WVRSmallPlayerViewPresenter * mCurPlayerP;
@property (nonatomic, strong) NSMutableSet * gShouldPauseSet;
@property (nonatomic, assign) BOOL mCanPlay;

@property (nonatomic, assign) NSInteger curIndex;

@property (nonatomic, strong) WVRSQLiveDetailModel * mLiveDetailModel;

@property (nonatomic, assign) BOOL curIsFootball;

@property (nonatomic, strong) WVRItemModel *detailBaseModel;

@property (nonatomic, strong, readonly) WVRVideoDetailViewModel *gVideoDetailViewModel;

@property (nonatomic, copy) void(^detailSuccessBlock)();
@property (nonatomic, copy) void(^detailFailBlock)();

@property (nonatomic, weak  ) WVRItemModel *tmpItemModel;
@property (nonatomic, assign) NSInteger tmpIndex;

@end


@implementation WVRSmallPlayerPresenter
@synthesize controller = _controller;
@synthesize gVideoDetailViewModel = _tmpVideoDetailViewModel;

+ (instancetype)shareInstance {
    
    static WVRSmallPlayerPresenter * presenter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        presenter = [WVRSmallPlayerPresenter new];
        [presenter initData];
        [presenter loadSubViewsP];
    });
    return presenter;
}

+ (instancetype)createPresenter:(id)createArgs {
    
    WVRSmallPlayerPresenter * p = [WVRSmallPlayerPresenter new];
    [p loadSubViewsP];
    return p;
}

- (void)initData {
    
    if (!self.gShouldPauseSet) {
        self.gShouldPauseSet = [NSMutableSet new];
    }
}

- (void)loadSubViewsP {
    
//    if (!self.mSmallPlayerP) {
//        self.mSmallPlayerP = [WVRSmallPlayerViewPresenter new];
//    }
//    if(!self.mLivePlayerP){
//        self.mLivePlayerP = [WVRLivePlayerViewPresenter new];
//    }
}

- (WVRVideoDetailViewModel *)gVideoDetailViewModel {
    
    if (!_tmpVideoDetailViewModel) {
        _tmpVideoDetailViewModel = [[WVRVideoDetailViewModel alloc] init];
    }
    return _tmpVideoDetailViewModel;
}

- (void)setupRequestRAC {
    
    @weakify(self);
    [[self.gVideoDetailViewModel gSuccessSignal] subscribeNext:^(WVRVideoDetailViewModel *_Nullable x) {
        @strongify(self);
        [self dealWithDetailData:x.dataModel];
    }];
    
    [[self.gVideoDetailViewModel gFailSignal] subscribeNext:^(WVRErrorViewModel *_Nullable x) {
        
        NSLog(@"error: %@", x.errorMsg);     // net error
    }];
}

- (void)reloadData {
    
    if (!self.curPlayUrl) {
        NSLog(@"playUrl is nil");
        return;
    }
    if (![WVRReachabilityModel sharedInstance].isWifi){
        NSLog(@"非wifi下不播放");
        return;
    }
    if (![self canPlay]) {
        NSLog(@"player not canPlay");
        
        return;
    }
    if (self.isLive) {
        self.mCurPlayerP = [WVRLivePlayerViewPresenter new];
    } else {
        self.mCurPlayerP = [WVRSmallPlayerViewPresenter new];
    }
    
    self.mCurPlayerP.isFootball = self.curIsFootball;
    self.mCurPlayerP.itemModel = self.itemModel;
    self.mCurPlayerP.detailBaseModel = self.detailBaseModel;
    
//    self.mCurPlayerP.controller = self.controller;
    
    self.mCurPlayerP.videoId = self.videoId;
    self.mCurPlayerP.mCurMediaModel = self.mCurMediaModel;
    self.mCurPlayerP.alpha = 0;
    [self.mCurPlayerP prepare];
    [self.mCurPlayerP restart];
    self.mCurPlayerP.frame = self.contentView.bounds;
    [self.contentView addSubview:self.mCurPlayerP];
    [self.contentView bringSubviewToFront:self.mCurPlayerP];
    if (self.contentView) {
        self.mCurPlayerP.translatesAutoresizingMaskIntoConstraints = NO;
        [self addPlayerViewCont:self.mCurPlayerP inSec:self.contentView];
    }
}

- (void)restartForLaunch {
    
    [self.mCurPlayerP restartForLaunch];
}

- (void)addPlayerViewCont:(UIView *)firstsView inSec:(UIView *)secondView {
    
    //view_1(红色)top 距离self.view的top
    NSLayoutConstraint *view_1TopToSuperViewTop = [NSLayoutConstraint constraintWithItem:firstsView
                                                                               attribute:NSLayoutAttributeTop
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:secondView
                                                                               attribute:NSLayoutAttributeTop
                                                                              multiplier:1
                                                                                constant:0];
    //view_3(蓝色)left 距离 self.view left
    NSLayoutConstraint *view_3LeftToSuperViewLeft = [NSLayoutConstraint constraintWithItem:firstsView
                                                                                 attribute:NSLayoutAttributeLeft
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:secondView
                                                                                 attribute:NSLayoutAttributeLeft
                                                                                multiplier:1
                                                                                  constant:0];
    
    //view_3(蓝色)right 距离 self.view right
    NSLayoutConstraint *view_3RightToSuperViewRight = [NSLayoutConstraint constraintWithItem:firstsView
                                                                                   attribute:NSLayoutAttributeRight
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:secondView
                                                                                   attribute:NSLayoutAttributeRight
                                                                                  multiplier:1
                                                                                    constant:0];
    
//    NSLayoutConstraint * heightCons = [NSLayoutConstraint constraintWithItem:firstsView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:50];
//    [firstsView addConstraints:@[heightCons]];
//    [firstsView layoutIfNeeded];
    //    //view_3(蓝色)Bottom 距离 self.view bottom
        NSLayoutConstraint *view_3BottomToSuperViewBottom = [NSLayoutConstraint constraintWithItem:firstsView
                                                                                         attribute:NSLayoutAttributeBottom
                                                                                         relatedBy:NSLayoutRelationEqual
                                                                                            toItem:secondView
                                                                                         attribute:NSLayoutAttributeBottom
                                                                                        multiplier:1
                                                                                          constant:0];
    //添加约束，因为view_1、2、3是同层次关系，且他们公有的父视图都是self.view，所以这里把约束都添加到self.view上即可
    [secondView addConstraints:@[view_1TopToSuperViewTop,view_3LeftToSuperViewLeft,view_3RightToSuperViewRight,view_3BottomToSuperViewBottom]];
    
    [secondView layoutIfNeeded];
}


- (UIView *)getView{
    return self.mCurPlayerP;
}

- (void)updateFrame:(CGRect)frame {
    
    self.mCurPlayerP.frame = frame;
}

- (void)stop {
    
    [self.mCurPlayerP stop];
}


- (void)start {
    
    if (self.canPlay) {
        [self.mCurPlayerP start];   
    }
}

- (void)destroy {
    
    self.itemModel = nil;
    self.mCurMediaModel = nil;
    self.curPlayUrl = nil;
    [self.mCurPlayerP destroy];
}

- (void)destroyForLauncher {
    
    [self.mCurPlayerP destroyForLauncher];
}

- (void)restart {
    
    [self.mCurPlayerP restart];
}

- (BOOL)isPlaying {
    
    return [self.mCurPlayerP isPlaying];
}

- (BOOL)isPaused {
    
    return !self.mCurPlayerP.isPaused;
}

- (BOOL)canPlay {
    
    return self.mCanPlay;
}

- (void)updateCanPlay:(BOOL)canPlay {
    
    self.mCanPlay = canPlay;
}

- (void)responseCurPage:(NSInteger)pageNumber itemModel:(WVRItemModel *)itemModel contentView:(UIView*)contentView {
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self];    // 可以成功取消全部。
    [self destroy];
    self.curIndex ++;
    self.contentView = contentView;
    self.isLive = (itemModel.linkType_ == WVRLinkTypeLive);
    self.videoId = itemModel.code;
    self.curPlayUrl = nil;
    
    if (itemModel.isChargeable) {
        NSLog(@"需要付费");
        return;
    }
    
    kWeakSelf(self);
    [self http_itemDetail:itemModel successBlock:^{
        weakself.itemModel = itemModel;
        if (itemModel.linkType_ == WVRLinkTypeLive) {
            if (itemModel.liveStatus == WVRLiveStatusPlaying) {
                [weakself performSelector:@selector(curpagePerform) withObject:nil afterDelay:2];
            }
        } else {
            [weakself performSelector:@selector(curpagePerform) withObject:nil afterDelay:2];
        }
    } failBlock:^{
        
    } curHttpIndex:self.curIndex];
}

- (void)http_itemDetail:(WVRItemModel *)itemModel successBlock:(void(^)(void))successBlock failBlock:(void(^)(void))failBlock curHttpIndex:(NSInteger)curHttpIndex {
    
    self.tmpItemModel = itemModel;
    self.detailSuccessBlock = [successBlock copy];
    self.detailFailBlock = [failBlock copy];
    self.tmpIndex = curHttpIndex;
    
    switch (itemModel.linkType_) {
        case WVRLinkTypeVR: {
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[@"code"] = itemModel.linkArrangeValue;
            self.gVideoDetailViewModel.requestParams = dict;
            [self.gVideoDetailViewModel.gDetailCmd execute:nil];
        }
            break;
            
        case WVRLinkTypeLive:
            [self requestLiveData:itemModel successBlock:successBlock failBlock:failBlock curHttpIndex:curHttpIndex];
            break;
        default:
            break;
    }
}

- (void)dealWithDetailData:(WVRVideoDetailVCModel *)responseObj {
    
    if (self.tmpIndex == self.curIndex) {
        
        self.curIsFootball = [responseObj isFootball];
        self.detailBaseModel = responseObj;
        
        //找到""目前录播只有一个元素
        WVRMediaModel * mediaModel = [WVRMediaModel new];
        WVRMediaDto * mediaDto = nil;
        self.tmpItemModel.contentType = responseObj.type;
        for (WVRMediaDto * cur in [responseObj mediaDtos]) {
            if ([cur.source isEqualToString:@"vr_share"]) {
                continue;
            }
            if ([cur.source isEqualToString:@"vr"] || [cur.source isEqualToString:@"Public"]) {
                
                mediaDto = cur;
                break;
            }
        }
        if (!mediaDto) {
            mediaDto = [[responseObj mediaDtos] firstObject];
        }
        
        if ([self checkNeedParserURL:mediaDto.playUrl]) {
            
            [self parserUrl:mediaDto.playUrl curParseIndex:self.tmpIndex successBlock:self.detailSuccessBlock withItemModel:self.tmpItemModel];
            
        } else {
            
            mediaModel.resolution = [WVRVideoEntity definitionToTitle:mediaDto.curDefinition];
            mediaModel.defiKey = mediaDto.curDefinition;
            mediaModel.playUrl = [self parseLivePlayUrl:mediaDto.playUrl];
            mediaModel.renderTyper = [self parseRenderType:mediaDto.renderType];
            mediaModel.cameraStand = mediaDto.source;
            
            self.tmpItemModel.palyMediaModels = @[ mediaModel ];
            self.mCurMediaModel = mediaModel;
            
            if (self.detailSuccessBlock) {
                self.detailSuccessBlock();
            }
        }
    } else {
        NSLog(@"请求成功不是当前的点播详情");
    }
}

- (void)requestLiveData:(WVRItemModel *)itemModel successBlock:(void(^)(void))successBlock failBlock:(void(^)(void))failBlock curHttpIndex:(NSInteger)curHttpIndex {
    
    if (!self.mLiveDetailModel) {
        self.mLiveDetailModel = [[WVRSQLiveDetailModel alloc] init];
    }
    __weak typeof(self) weakSelf = self;
    [self.mLiveDetailModel http_recommendLiveDetailWithCode:itemModel.linkArrangeValue successBlock:^(WVRSQLiveItemModel *args) {
        if (curHttpIndex == weakSelf.curIndex) {
            
            weakSelf.curIsFootball = [args isFootball];
            weakSelf.detailBaseModel = args;
            
            [weakSelf liveRequestDetailSuccessBlock:args itemModel:itemModel successBlock:successBlock];
        } else {
            NSLog(@"请求成功不是当前的直播详情");
        }
    } failBlock:^(NSString *args) {
        
    }];
}

- (void)liveRequestDetailSuccessBlock:(WVRSQLiveItemModel *)args itemModel:(WVRItemModel *)itemModel successBlock:(void(^)(void))successBlock {
    
    __weak typeof(self) weakSelf = self;
    NSMutableArray * mediaModels = [NSMutableArray new];
    
    //找到2k
    WVRMediaModel * mediaModel_2K = [WVRMediaModel new];
    for (WVRSQLiveMediaModel * cur in args.liveMediaDtos) {
        if ([[cur resolution] isEqualToString:@"2K"]) {
            mediaModel_2K.resolution = @"高清";
            mediaModel_2K.defiKey = kDefinition_ST;
            mediaModel_2K.playUrl = [weakSelf parseLivePlayUrl:cur.playUrl];
            mediaModel_2K.renderTyper = [weakSelf parseRenderType:cur.renderType];
            mediaModel_2K.cameraStand = cur.cameraStand;
            
            [mediaModels addObject:mediaModel_2K];
            break;
        }
    }
    
    //找到8p
    WVRMediaModel * mediaModel_8P = [WVRMediaModel new];
    for (WVRSQLiveMediaModel * cur in args.liveMediaDtos) {
        if ([[cur resolution] isEqualToString:@"8P"]) {
            mediaModel_8P.resolution = @"超清";
            mediaModel_8P.defiKey = kDefinition_SD;
            mediaModel_8P.playUrl = [weakSelf parseLivePlayUrl:cur.playUrl];
            mediaModel_8P.renderTyper = [weakSelf parseRenderType:cur.renderType];
            mediaModel_8P.cameraStand = cur.cameraStand;
            
            [mediaModels addObject:mediaModel_8P];
            break;
        }
    }
    
    //找到4K
    WVRMediaModel * mediaModel_4K = [WVRMediaModel new];
    for (WVRSQLiveMediaModel * cur in args.liveMediaDtos) {
        if ([[cur resolution] isEqualToString:@"4K"]) {
            mediaModel_4K.resolution = @"原画";
            mediaModel_4K.defiKey = kDefinition_HD;
            mediaModel_4K.playUrl = [weakSelf parseLivePlayUrl:cur.playUrl];
            mediaModel_4K.renderTyper = [weakSelf parseRenderType:cur.renderType];
            mediaModel_4K.cameraStand = cur.cameraStand;
            
            [mediaModels addObject:mediaModel_4K];
            break;
        }
    }
    
    // 兼容足球，如果是足球的话，就先只取Public机位
    if (self.curIsFootball) {
        
        WVRMediaModel * mediaModel_Public = [WVRMediaModel new];
        for (WVRSQLiveMediaModel * cur in args.liveMediaDtos) {
            if ([[cur cameraStand] isEqualToString:@"Public"]) {
                mediaModel_Public.resolution = [WVRVideoEntity definitionToTitle:cur.definition];
                mediaModel_Public.defiKey = cur.definition;
                mediaModel_Public.playUrl = [weakSelf parseLivePlayUrl:cur.playUrl];
                mediaModel_Public.renderTyper = [weakSelf parseRenderType:cur.renderType];
                mediaModel_Public.cameraStand = cur.cameraStand;
                
                [mediaModels removeAllObjects];
                [mediaModels addObject:mediaModel_Public];
                break;
            }
        }
    }
    
    itemModel.palyMediaModels = mediaModels;
    itemModel.bgPic = args.bgPic;
    itemModel.contentType = args.type;
    weakSelf.mCurMediaModel = [mediaModels firstObject];
    
    successBlock();
}

- (NSString *)parseLivePlayUrl:(NSString *)originUrl {
    
    NSArray * arry = [originUrl componentsSeparatedByString:@"&flag"];
    
    return [arry firstObject];
}

- (WVRRenderType)parseRenderType:(NSString *)originRenderType {
    
    WVRRenderType renderType = [WVRVideoEntity renderTypeForRenderTypeStr:originRenderType];
    return renderType;
}

- (void)curpagePerform {
    
    [self parserComplateAndPlay];
}

- (void)parserComplateAndPlay {
    
    WVRItemModel * itemModel = self.itemModel;
    NSLog(@"解析后palyUrl: %@", itemModel.playUrl);
    
    [self startPlayWithUrl:itemModel.playUrl];
}

- (BOOL)checkNeedParserURL:(NSString *)playUrl {
    
    if ([playUrl hasPrefix:@"http"] && [playUrl containsString:@"&flag"]) {
        
        return YES;
    }
    
    return NO;
}

- (void)parserUrl:(NSString *)url curParseIndex:(NSInteger)curParseIndex successBlock:(void(^)(void))successBlock withItemModel:(WVRItemModel *)itemModel {
    
    kWeakSelf(self);
    [WVRParseUrl parserUrl:url callback:^(WVRParserUrlResult *result) {
        
        if (result.isSuccessed) {
            
            if (curParseIndex == weakself.curIndex) {
                
                [weakself parserSuccessBlock:result successBlock:successBlock withItemModel:itemModel];
                
            } else {
                NSLog(@"解析完非当前播放url");
            }
            
        } else {
            NSLog(@"解析失败");
        }
        
    }];
}

- (void)parserSuccessBlock:(WVRParserUrlResult *)parseResult successBlock:(void(^)(void))successBlock withItemModel:(WVRItemModel *)itemModel {
    
    kWeakSelf(self);
    
    NSMutableArray *tmpArray = [NSMutableArray array];
    for (WVRParserUrlElement *element in parseResult.urlElementList) {
        
        NSString *key = element.definition;
        NSString *resultUrl = element.url.absoluteString;
        
        NSDictionary *dict = @{ key : resultUrl };
        [tmpArray addObject:dict];
    }
    NSMutableArray * mediaModels = [NSMutableArray new];
    
    BOOL isCommonVideo = [WVRVideoEntity isCommonVideoForRenderType:itemModel.renderType];
    if (isCommonVideo && parseResult.haveTDA_TDB) {
        //找到TDA
        WVRMediaModel * mediaModel_TDA = [WVRMediaModel new];
        for (NSDictionary * cur in tmpArray) {
            if ([[cur.allKeys firstObject] isEqualToString:kDefinition_TDA]) {
                mediaModel_TDA.resolution = @"超清";
                mediaModel_TDA.defiKey = kDefinition_TDA;
                mediaModel_TDA.playUrl = cur[kDefinition_TDA];
                mediaModel_TDA.renderTyper = [weakself parseRenderType:itemModel.renderType];;
                [mediaModels addObject:mediaModel_TDA];
                break;
            }
        }
        
        //找到TDB
        WVRMediaModel * mediaModel_TDB = [WVRMediaModel new];
        for (NSDictionary * cur in tmpArray) {
            if ([[cur.allKeys firstObject] isEqualToString:kDefinition_TDB]) {
                mediaModel_TDB.resolution = @"超清";
                mediaModel_TDB.defiKey = kDefinition_TDB;
                mediaModel_TDB.playUrl = cur[kDefinition_TDB];
                mediaModel_TDB.renderTyper = [weakself parseRenderType:itemModel.renderType];;
                [mediaModels addObject:mediaModel_TDB];
                break;
            }
        }
        
    } else if (isCommonVideo && parseResult.haveSDA_SDB) {
        //找到SDA
        WVRMediaModel * mediaModel_SDA = [WVRMediaModel new];
        for (NSDictionary * cur in tmpArray) {
            if ([[cur.allKeys firstObject] isEqualToString:kDefinition_SDA]) {
                mediaModel_SDA.resolution = @"高清";
                mediaModel_SDA.defiKey = kDefinition_SDA;
                mediaModel_SDA.playUrl = cur[kDefinition_SDA];
                mediaModel_SDA.renderTyper = MODE_OCTAHEDRON;
                [mediaModels addObject:mediaModel_SDA];
                break;
            }
        }
        
        //找到SDB
        WVRMediaModel * mediaModel_SDB = [WVRMediaModel new];
        for (NSDictionary * cur in tmpArray) {
            if ([[cur.allKeys firstObject] isEqualToString:kDefinition_SDB]) {
                mediaModel_SDB.resolution = @"超清";
                mediaModel_SDB.defiKey = kDefinition_SDB;
                mediaModel_SDB.playUrl = cur[kDefinition_SDB];
                mediaModel_SDB.renderTyper = MODE_OCTAHEDRON;
                [mediaModels addObject:mediaModel_SDB];
                break;
            }
        }
        
    } else {
        //找到2k ST
        WVRMediaModel * mediaModel_2K = [WVRMediaModel new];
        for (NSDictionary * cur in tmpArray) {
            if ([[cur.allKeys firstObject] isEqualToString:kDefinition_ST]) {
                mediaModel_2K.resolution = @"高清";
                mediaModel_2K.defiKey = kDefinition_ST;
                mediaModel_2K.playUrl = cur[kDefinition_ST];
                mediaModel_2K.renderTyper = [weakself parseRenderType:itemModel.renderType];
                [mediaModels addObject:mediaModel_2K];
                break;
            }
        }
        
        if (isCommonVideo) {
            
            //找到8p SD
            WVRMediaModel * mediaModel_8P = [WVRMediaModel new];
            for (NSDictionary * cur in tmpArray) {
                if ([[cur.allKeys firstObject] isEqualToString:kDefinition_SD]) {
                    mediaModel_8P.resolution = @"超清";
                    mediaModel_8P.defiKey = kDefinition_SD;
                    mediaModel_8P.playUrl = cur[kDefinition_SD];
                    mediaModel_8P.renderTyper = MODE_OCTAHEDRON;//[weakself parseRenderType:itemModel.renderType];
                    
                    [mediaModels addObject:mediaModel_8P];
                    break;
                }
            }
        }
        
        //找到4K HD
        WVRMediaModel * mediaModel_4K = [WVRMediaModel new];
        for (NSDictionary * cur in tmpArray) {
            if ([[[cur allKeys] firstObject] isEqualToString:kDefinition_HD]) {
                mediaModel_4K.resolution = @"原画";
                mediaModel_4K.defiKey = kDefinition_HD;
                mediaModel_4K.playUrl = cur[kDefinition_HD];
                mediaModel_4K.renderTyper = [weakself parseRenderType:itemModel.renderType];
                [mediaModels addObject:mediaModel_4K];
                break;
            }
        }
    }
    
    itemModel.palyMediaModels = mediaModels;
    weakself.mCurMediaModel = [mediaModels firstObject];
    
    successBlock();
}

- (void)startPlayWithUrl:(NSString *)url {
    
    self.curPlayUrl = url;
    [self reloadData];
}

- (BOOL)shouldPause {
    
//    NSLog(@"shouldpause get code:%@", self.itemModel.code);
    BOOL contain = [self.gShouldPauseSet containsObject:self.itemModel.code];
    return contain;
}

- (void)setShouldPause:(BOOL)shouldPause {
    
//    NSLog(@"shouldpause set code:%@", self.itemModel.code);
    if (self.itemModel.code.length == 0) {
        return;
    }
    if (shouldPause) {
        [self.gShouldPauseSet addObject:self.itemModel.code];
    } else {
        [self.gShouldPauseSet removeObject:self.itemModel.code];
    }
}

- (void)dealloc {
    
    DebugLog(@"");
    self.curIndex = -1;
}

@end
