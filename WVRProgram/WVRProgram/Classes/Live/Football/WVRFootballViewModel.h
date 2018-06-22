//
//  WVRFootballViewModel.h
//  WhaleyVR
//
//  Created by qbshen on 2017/5/8.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRFootballModel.h"

typedef NS_ENUM(NSInteger, WVRFootballViewModelSectionType) {
    WVRFootballViewModelSectionTypeAD,
    WVRFootballViewModelSectionTypeLive,
    WVRFootballViewModelSectionTypeRecord,
    
};

@class WVRSectionModel;

@interface WVRFootballViewModel : NSObject

- (instancetype _Nullable )initWithSuccessBlock:(void(^_Nullable)(NSDictionary<NSNumber*, NSArray*>* _Nullable resultDic))successBlock failBlock:(void(^_Nullable)(NSString * _Nullable errMsg))failBlock;

- (void)http_footballListWithCode:(NSString*_Nullable)code;

- (nonnull instancetype)init UNAVAILABLE_ATTRIBUTE;

+ (nonnull instancetype)new UNAVAILABLE_ATTRIBUTE;

@property (nonatomic, strong, readonly) NSDictionary<NSNumber *, WVRSectionModel *> * _Nullable gSctionDic;

@end
