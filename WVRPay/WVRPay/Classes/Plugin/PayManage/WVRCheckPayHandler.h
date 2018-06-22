//
//  WVRCheckPayHandler.h
//  WhaleyVR
//
//  Created by qbshen on 2017/9/1.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WVRPayModel.h"

@interface WVRCheckPayHandler : NSObject

@property (nonatomic, strong) WVRPayModel * gPayModel;

@property (nonatomic, strong, readonly) RACSignal * successSignal;
@property (nonatomic, strong, readonly) RACSignal * failSignal;

-(RACCommand*)checkPayCmd;

@end
