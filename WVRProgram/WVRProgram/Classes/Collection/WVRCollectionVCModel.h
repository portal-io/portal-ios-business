//
//  WVRCollectionModel.h
//  WhaleyVR
//
//  Created by qbshen on 2017/1/6.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRBaseModel.h"
#import "WVRTVItemModel.h"
#import "WVRCollectionModel.h"

@interface WVRCollectionVCModel : WVRBaseModel

@property (nonatomic) NSMutableArray<WVRCollectionModel *> * collections;

+ (void)http_CollectionSaveWithModel:(WVRTVItemModel *)tvModel successBlock:(void(^)())successBlock failBlock:(void(^)(NSString *))failBlock;

+ (void)http_CollectionOneWithModel:(WVRTVItemModel *)tvModel successBlock:(void(^)(WVRCollectionModel *))successBlock failBlock:(void(^)(NSString *))failBlock;

+ (void)http_CollectionGetWithSuccessBlock:(void(^)(WVRCollectionVCModel *))successBlock failBlock:(void(^)(NSString *))failBlock;

+ (void)http_CollectionDelWithModel:(WVRTVItemModel *)tvModel successBlock:(void(^)())successBlock failBlock:(void(^)(NSString *))failBlock;

@end
