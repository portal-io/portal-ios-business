//
//  WVRHttpStatUpdate.m
//  WhaleyVR
//
//  Created by Xie Xiaojian on 2016/10/31.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRHttpStatUpdate.h"

NSString * const kHttpParams_programDetail_srcCode = @"srcCode";
NSString * const kHttpParams_programDetail_contentType = @"contentType";
NSString * const kHttpParams_programDetail_type = @"type";
NSString * const kHttpParams_programDetail_sec = @"sec";
static NSString *kActionUrl = @"newVR-service/appservice/stat/updateBySrcCode";

@implementation WVRHttpStatUpdate

/* protocol WVRRequestProtocol method */
- (void)onDataSuccess:(id)dataObject
{
    NSMutableDictionary *result = (NSMutableDictionary*)self.originResponse;
    WVRHttpStatUpdateParentModel *resSuccess = [WVRHttpStatUpdateParentModel yy_modelWithDictionary:result];
    self.successedBlock(resSuccess);
}

/* protocol WVRRequestProtocol method */
- (void)onDataFailed:(id)dataObject
{
    NSLog(@"%@ request failed",[self class]);
    self.failedBlock(dataObject);
}

/* WVRBaseRequest method*/
- (NSString*)getActionUrl
{
    return kActionUrl;
}


@end


@implementation WVRHttpStatUpdateParentModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{ @"data" : [WVRHttpStatUpdateModel class], };
}

@end
