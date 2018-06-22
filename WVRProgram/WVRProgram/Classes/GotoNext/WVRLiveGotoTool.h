//
//  WVRLiveGotoTool.h
//  WhaleyVR
//
//  Created by qbshen on 2016/12/7.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WVRSectionModel.h"
#import "WVRPlayerTool.h"

@interface WVRLiveGotoTool : NSObject

+ (void)gotoMoreVC:(WVRSectionModel*)sectionModel nav:(UINavigationController*)nav;

@end
