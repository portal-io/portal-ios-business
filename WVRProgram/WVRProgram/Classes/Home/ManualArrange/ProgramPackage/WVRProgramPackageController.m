//
//  WVRProgramPackageController.m
//  WhaleyVR
//
//  Created by qbshen on 17/4/13.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRProgramPackageController.h"

#import "WVRProgramPackageViewModel.h"
#import "WVRProgramPackageModel.h"
#import "WVRUMShareView.h"

#import "WVRWidgetHeader.h"
#import "WVRComputeTool.h"

#import "WVRMediator+PayActions.h"

@interface WVRProgramPackageController ()

@property (nonatomic, strong) WVRProgramPackageModel * gPackModel;

@property (nonatomic, assign) BOOL isFirst;

@end


@implementation WVRProgramPackageController

//- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
//    self = [super initWithCollectionViewLayout:layout];
//    if (self) {
//        
//        self.hidesBottomBarWhenPushed = YES;
//    }
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[WVRMediator sharedInstance] WVRMediator_ReportLostInAppPurchaseOrders];
//
//    self.isFirst = YES;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNotResponse) name:NAME_NOTF_MANUAL_ARRANGE_PROGRAMPACKAGE object:nil];
}

- (void)refreshNotResponse {
    
//    [self.originDic removeAllObjects];
//    [self updateCollectionView];
//    if (self.gPayBtn.superview) {
//        [self removeShopBtn];
//    }
//    [self requestInfo];
}

#pragma mark - request

- (void)httpRequest {
    
//    [self removeNetErrorV];
    
    SQShowProgress;
    [self requestListDetail];
}

- (void)requestListDetail {
    
//    kWeakSelf(self);
//    [WVRProgramPackageViewModel http_programPackageWithCode:self.sectionModel.linkArrangeValue successBlock:^(WVRSectionModel *args) {
//        [weakself httpSuccessBlock:args];
//    } failBlock:^(NSString *args) {
//        [weakself httpFailBlock:args];
//    }];
}

- (void)httpSuccessBlock:(WVRSectionModel *)args {
    // 普通专题（手动编排）
//    if (!args.isChargeable) {
//        [super httpSuccessBlock:args];
//        return;
//    }
//    
//    self.sectionModel.haveCharged = [self.sectionModel programPackageHaveCharged];
//    self.sectionModel.intrDesc = args.subTitle;
//    if ([[WVRUserModel sharedInstance] isisLogined] && !self.sectionModel.haveCharged) {
//        kWeakSelf(self);
//        if ([[WVRUserModel sharedInstance] isisLogined]) {
//            [WVRMyOrderItemModel requestForQueryProgramCharged:self.sectionModel.linkArrangeValue goodsType:PurchaseProgramTypeCollection block:^(BOOL isCharged, NSError *error) {
//                
//                weakself.sectionModel.haveCharged = isCharged;
//                // 只能购买合集，单个节目没有对应券，不需要判断其是否已购买
//                if (isCharged || [weakself.sectionModel.type isEqualToString:@"0"]) {
//                    
//                    [weakself updatePayStatus:args];
//                } else {
//                    [weakself requestForListItemCharged:args];
//                }
//            }];
//        }
//    } else {
//        self.sectionModel.haveCharged = NO;
//        [self updatePayStatus:args];
//    }
}

- (void)requestForListItemCharged:(WVRSectionModel *)args {
    
//    kWeakSelf(self)
//    NSMutableArray *arr = [NSMutableArray array];
//    for (WVRItemModel *item in args.itemModels) {
//        
//        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
//        dict[@"sid"] = item.code;
//        dict[@"type"] = item.contentType;
//        
//        [arr addObject:dict];
//    }
//    [WVRInAppPurchaseManager requestCheckGoodsPayedList:arr block:^(NSArray *list, NSError *error) {
//        
//        int count = 0;
//        for (NSDictionary *resDic in list) {
//            
//            if (args.itemModels.count > count) {
//                int isCharged = [resDic[@"result"] intValue];
//                NSString *goodsNo = resDic[@"goodsNo"];
//                WVRItemModel *itemModel = [args.itemModels objectAtIndex:count];
//                
//                if ([goodsNo isEqualToString:itemModel.linkArrangeValue]) {
//                    
//                    itemModel.packageItemCharged = @(isCharged);
//                }
//            }
//            
//            count += 1;
//        }
//        
//        [weakself updatePayStatus:args];
//    }];
}

- (void)updatePayStatus:(WVRSectionModel *)args {
    
//    args.haveCharged = self.sectionModel.haveCharged;
//    [super httpSuccessBlock:args];
//    
//    self.gPackModel = args.packModel;
//    
//    [self checkGoodsType];
}

- (void)createPayBtn {
    
//    NSString *price = [WVRComputeTool numToPriceNumber:self.gPackModel.price];
//    
//    NSString *title = [NSString stringWithFormat:@"购买节目包观看券 ¥%@", price];
//    if ([self.gPackModel packageType] == WVRPackageTypeProgramSet) {
//        title = [NSString stringWithFormat:@"购买合集观看券 ¥%@", price];
//    }
//    [self.gPayBtn setTitle:title forState:UIControlStateNormal];
//    self.collectionView.height = SCREEN_HEIGHT - self.gPayBtn.height;
//    
//    [self.view addSubview:self.gPayBtn];
}

//- (void)checkGoodsType {
//    
//    WVRPayGoodsType goodsType = [[self createPayModel] payGoodsType];
//    switch (goodsType) {
//        case WVRPayGoodsTypeFree:
//            
//            break;
//        case WVRPayGoodsTypeProgram:
//            
//            break;
//        case WVRPayGoodsTypeProgramPackage:
////            if (!self.sectionModel.haveCharged) {
////                [self createPayBtn];
////            }
//            break;
//            
//        default:
//            break;
//    }
//}

//- (WVRPayModel *)createPayModel {
//    
//    WVRPayModel *payModel = [[WVRPayModel alloc] init];
//    
//    payModel.fromType = PayFromTypeApp;
//    payModel.payComeFromType = WVRPayComeFromTypeProgramPackage;
//    
//    payModel.goodsCode = self.gPackModel.couponDto.code;
//    payModel.goodsPrice = self.gPackModel.couponDto.price;
//    payModel.goodsName = self.gPackModel.couponDto.displayName;
//    payModel.relatedType = GOODS_TYPE_CONTENT_PACKGE;
//    payModel.relatedCode = self.gPackModel.couponDto.relatedCode;
//    payModel.disableTime = self.gPackModel.disableTimeDate;
//    payModel.packageType = self.gPackModel.packageType;
//    
//    return payModel;
//}

- (void)goShopping {
    
//    kWeakSelf(self);
//    [[WVRPayManager shareInstance] showPayAlertViewWithPayModel:[self createPayModel] viewController:self resultCallback:^(WVRPayManageResultStatus resultStatus) {
//        switch (resultStatus) {
//            case WVRPayManageResultStatusSuccess:
//                [weakself removeShopBtn];
//                [weakself requestInfo];
//                if (self.prePayResultBlock) {
//                    self.prePayResultBlock();
//                    self.prePayResultBlock = nil;
//                }
//                break;
//                
//            default:
//                break;
//        }
//    }];
}

- (void)removeShopBtn {
    
//    self.collectionView.height = SCREEN_HEIGHT;
//    [self.gPayBtn removeFromSuperview];
}

#pragma mark - share

- (void)createShareTool {
    // 分享功能模块
//    WVRShareType type = WVRShareTypeSpecialProgramPackage;
//    
//    WVRUMShareView *shareView = [[WVRUMShareView alloc] initWithFrame:self.view.bounds
//                                                                  sID:self.sectionModel.linkArrangeValue
//                                                              iconUrl:self.sectionModel.thubImageUrl
//                                                                title:self.sectionModel.name
//                                                                intro:self.sectionModel.intrDesc
//                                                                mobId:nil
//                                                            shareType:type ];
//    self.mShareView = shareView;
}

@end
