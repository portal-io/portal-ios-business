//
//  WVRHttpAppEnter.m
//  WhaleyVR
//
//  Created by Xie Xiaojian on 2016/11/22.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRHttpAppEnter2.h"

NSString * const kHttpParams_enter2_content = @"content";

NSString * const cKey2 = @"e0dfa6491c3e4976b96feb3ad93112dc06e219b08f7f49148c2cf78ea451a3e1468dcd62bdcd435d9ce290290c8bdba68ce17124c6f94ff0a53bbf46110d26ca";
static NSString *kActionUrl = @"newVR-report-service/ad/app/checklog";

@implementation WVRHttpAppEnter2

/* protocol WVRRequestProtocol method */
- (void)onDataSuccess:(id)dataObject
{
    NSMutableDictionary *result = (NSMutableDictionary*)self.originResponse;
    
    WVRHttpAppEnter2Model *resSuccess = [WVRHttpAppEnter2Model yy_modelWithDictionary:result];
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


@implementation WVRHttpAppEnter2Model

@end
