//
//  WVRHttpSearch.m
//  WhaleyVR
//
//  Created by Xie Xiaojian on 2016/11/1.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRHttpSearch.h"

NSString * const kHttpParams_search_keyWord = @"keyWord";
NSString * const kHttpParams_search_type = @"type";
static NSString *kActionUrl = @"newVR-service/appservice/search/bytitle";

@implementation WVRHttpSearch

/* protocol WVRRequestProtocol method */
- (void)onDataSuccess:(id)dataObject
{
    NSMutableDictionary *result = (NSMutableDictionary*)self.originResponse;
    WVRHttpSearchMainModel *resSuccess = [WVRHttpSearchMainModel yy_modelWithDictionary:result];
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


@implementation WVRHttpSearchMainModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{ @"data" : [WVRHttpSearchModel class], };
}

@end
