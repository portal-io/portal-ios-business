//
//  WVRHistoryViewModel.h
//  WhaleyVR
//
//  Created by qbshen on 2017/3/30.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WVRHistoryModel,WVRSectionModel;

@interface WVRHistoryViewModel : NSObject
-(void)http_historyList:(void(^)(NSArray<WVRSectionModel*>*))successBlock andFailBlock:(void(^)(NSString*))failBlock;

-(void)http_history_dels:(NSString * )delIds successBlock:(void(^)(NSArray<WVRHistoryModel*>*))successBlock andFailBlock:(void(^)(NSString*))failBlock;

-(void)http_history_delAll:(void(^)(NSArray<WVRHistoryModel*>*))successBlock andFailBlock:(void(^)(NSString*))failBlock;
@end
