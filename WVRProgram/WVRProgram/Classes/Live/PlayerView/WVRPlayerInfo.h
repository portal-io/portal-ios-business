//
//  WVRPlayerInfo.h
//  WhaleyVR
//
//  Created by qbshen on 2017/2/21.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WVRPlayerURL : NSObject

@property (nonatomic) NSString * type;

@property (nonatomic) NSString * url;

@end


@interface WVRPlayerInfo : NSObject

@property (nonatomic, weak) UIViewController * controller;
@property (nonatomic) NSString * defUrl;
@property (nonatomic) NSString * HDUrl;

@end
