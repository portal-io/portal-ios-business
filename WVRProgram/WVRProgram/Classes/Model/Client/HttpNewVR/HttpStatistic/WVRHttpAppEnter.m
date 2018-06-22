//
//  WVRHttpAppEnter.m
//  WhaleyVR
//
//  Created by Xie Xiaojian on 2016/11/22.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRHttpAppEnter.h"

NSString * const kHttpParams_enter_content = @"content";

NSString * const cKey = @"5d40190e25c04495bb920abe34d16a98caeb903a56e14b1d8c578f6ae8834c77750d76d4c21545e99abb952fb13603e7c8620099e2e74d3aa6863a4fe091d03f";
static NSString *kActionUrl = @"newVR-report-service/ad/app/firstClick";

@implementation WVRHttpAppEnter

/* protocol WVRRequestProtocol method */
- (void)onDataSuccess:(id)dataObject
{
    NSMutableDictionary *result = (NSMutableDictionary*)self.originResponse;
    
    WVRHttpAppEnterModel *resSuccess = [WVRHttpAppEnterModel yy_modelWithDictionary:result];
    self.successedBlock(resSuccess.msg);
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
@implementation WVRHttpAppEnterModel

@end
