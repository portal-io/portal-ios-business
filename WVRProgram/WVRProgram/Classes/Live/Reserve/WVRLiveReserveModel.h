//
//  WVRLiveReserveModel.h
//  WhaleyVR
//
//  Created by qbshen on 2016/12/7.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRSQLiveListModel.h"

@interface WVRLiveReserveDayInfo : NSObject

@property (nonatomic) NSString * week;
@property (nonatomic) NSString * day;

@end


@interface WVRLReSectionModel : WVRSectionModel

@property (nonatomic) int intervalDay;
@property (nonatomic) NSString * startDateFormat;

@end


@interface WVRLiveReserveModel : WVRSQLiveListModel

- (void)http_liveOrder_listSuccessBlock:(void(^)(NSArray *))successBlock failBlock:(void(^)(NSString *err))failBlock;
+ (void)http_liveOrder:(BOOL)isAdd itemId:(NSString *)itemId successBlock:(void(^)())successBlock failBlock:(void(^)(NSString *err))failBlock;

//临时在直播未开始的直播详情界面获取已预约列表，以筛选此直播是否已预约
- (void)http_liveOrderForLiveDetailCheckReserve_listSuccessBlock:(void(^)(NSArray*))successBlock failBlock:(void(^)(NSString *err))failBlock;

@end
