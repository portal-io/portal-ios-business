//
//  WVRHttpMyReserve.m
//  WhaleyVR
//
//  Created by qbshen on 2017/2/16.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRHttpMyReserve.h"


NSString * const kHttpParams_myReserveList_uid = @"uid";
NSString * const kHttpParams_myReserveList_token = @"token";
NSString * const kHttpParams_myReserveList_device_id = @"device_id";

static NSString *kActionUrl = @"newVR-service/appservice/liveorder/listOrderedByUser";

@interface WVRHttpMyReserve ()

@property (nonatomic) NSString* actionStr;

@end


@implementation WVRHttpMyReserve
/* protocol WVRRequestProtocol method */
- (void)onDataSuccess:(id)dataObject
{
    NSMutableDictionary *result = (NSMutableDictionary*)self.originResponse;
    WVRHttpMyReserveModel * model = [WVRHttpMyReserveModel yy_modelWithDictionary:result];
    self.successedBlock(model);
}

/* protocol WVRRequestProtocol method */
- (void)onDataFailed:(id)dataObject
{
    NSLog(@"%@ request failed", [self class]);
    self.failedBlock(dataObject);
}

/* WVRBaseRequest method*/
- (NSString *)getActionUrl
{
    return kActionUrl;
}

@end


@implementation WVRHttpMyReserveModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{ @"data": WVRHttpMyReserveItemModel.class };
}

@end


@implementation WVRHttpMyReserveItemModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{@"guests": WVRHttpGuestModel.class,
             @"liveMediaDtos" : WVRMediaDto.class,
             };
}

@end
