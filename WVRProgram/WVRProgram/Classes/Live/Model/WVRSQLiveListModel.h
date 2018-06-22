//
//  WVRSQLiveListModel.h
//  WhaleyVR
//
//  Created by qbshen on 2016/11/21.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRBaseModel.h"
#import "WVRSectionModel.h"

@class WVRHttpLiveDetailModel;

@interface WVRSQLiveListModel : WVRBaseModel

- (void)http_recommendPageDetail:(void(^)(NSArray *))successBlock failBlock:(void(^)(NSString *))failBlock;
- (WVRSQLiveItemModel *)parseLiveDetail:(WVRHttpLiveDetailModel *)item;

@end
