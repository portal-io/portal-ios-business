//
//  WVRSQLocalVideoInfo.h
//  WhaleyVR
//
//  Created by qbshen on 16/11/8.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WVRVideoModel.h"
#import "WVRSQBaseViewInfo.h"

@interface WVRSQLocalVideoInfo : WVRSQBaseViewInfo

@property (copy) void(^gotoPlayBlock)(WVRVideoModel*);
@property (copy) void(^completeBlock)();

-(void)setDelegateForTableView:(UITableView*)tableView;
- (void)loadVideosInfo;
@end
