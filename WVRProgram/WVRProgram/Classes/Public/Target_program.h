//
//  Target_program.h
//  WhaleyVR
//
//  Created by qbshen on 2017/8/15.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Target_program : NSObject

- (UIViewController *)Action_nativeFetchHistoryViewController:(NSDictionary *)params;


- (UIViewController *)Action_nativeFetchRewardViewController:(NSDictionary *)params;

- (UIViewController *)Action_nativeFetchCollectionViewController:(NSDictionary *)params;

- (void)Action_nativeGotoNextVC:(NSDictionary *)params;

@end
