//
//  WVRProgramBIModel.h
//  WhaleyVR
//
//  Created by Bruce on 2017/8/11.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WVRBIManager.h"

@interface WVRProgramBIModel : NSObject

+ (void)trackEventForTopicWithAction:(BITopicActionType)action topicId:(NSString *)topicId topicName:(NSString *)topicName videoSid:(NSString *)videoSid videoName:(NSString *)videoName index:(NSInteger)index isPackage:(BOOL)isPackage;

+ (void)trackEventForDetailWithAction:(BIDetailActionType)action sid:(NSString *)sid name:(NSString *)name;

+ (void)recommendTabSelect:(kTabBarIndex)selectedIndex;

@end
