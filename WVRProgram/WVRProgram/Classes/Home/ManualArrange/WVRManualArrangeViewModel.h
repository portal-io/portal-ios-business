//
//  WVRSQArrangeMAMoreModel.h
//  WhaleyVR
//
//  Created by qbshen on 16/11/17.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRBaseModel.h"
#import "WVRSectionModel.h"
#import "WVRErrorProtocol.h"
#import "WVRModelProtocol.h"

@interface WVRManualArrangeViewModel : WVRBaseModel

-(void)requestData:(id)params successBlock:(void(^)(id<WVRModelProtocol>))successBlock failBlock:(void(^)(id<WVRErrorProtocol>))failBlock;


@end
