//
//  WVRProgramPackageViewModel.h
//  WhaleyVR
//
//  Created by qbshen on 17/4/13.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import <Foundation/Foundation.h>


@class WVRSectionModel;

@interface WVRProgramPackageViewModel : NSObject

+ (void)http_programPackageWithCode:(NSString *)code successBlock:(void(^)(WVRSectionModel *))successBlock failBlock:(void(^)(NSString *))failBlock;

@end
