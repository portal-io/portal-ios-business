//
//  WVRAllChannelViewModel.h
//  WhaleyVR
//
//  Created by qbshen on 2017/3/28.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WVRItemModel;

@interface WVRAllChannelViewModel : NSObject

-(void)http_allChannel:(void(^)(NSArray<WVRItemModel*>*))successBlock andFailBlock:(void(^)(NSString*))failBlock;

@end
