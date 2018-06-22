//
//  WVRPlayerStatus.h
//  WhaleyVR
//
//  Created by qbshen on 2017/2/27.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WVRPlayerConfigQuality) {
    WVRPlayerConfigQualityDefault,
    WVRPlayerConfigQualityHD,
    
};


@interface WVRPlayerConfig : NSObject

@property (nonatomic) BOOL isDefinitionHD;

@property (nonatomic) UIDeviceOrientation mCurDeviceOrientation;

@end
