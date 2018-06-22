//
//  WVRSQLiveDetailModel.h
//  WhaleyVR
//
//  Created by qbshen on 2016/11/21.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRSQLiveListModel.h"

@interface WVRSQLiveDetailModel : WVRSQLiveListModel

- (void)http_recommendLiveDetailWithCode:(NSString *)code successBlock:(void(^)(WVRSQLiveItemModel *))successBlock failBlock:(void(^)(NSString*))failBlock;

@end
