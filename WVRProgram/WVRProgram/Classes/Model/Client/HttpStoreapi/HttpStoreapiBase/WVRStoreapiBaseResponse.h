//
//  WVRWAccountBaseResponse.h
//  WhaleyVR
//
//  Created by qbshen on 16/10/20.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRBaseResponse.h"

@interface WVRStoreapiBaseResponse : WVRBaseResponse

@property (nonatomic, copy) NSString * code;
@property (nonatomic, strong) NSDictionary * data;

@end
