//
//  WVRVideoDetailModel.h
//  WhaleyVR
//
//  Created by qbshen on 2017/1/4.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRBaseModel.h"
#import "WVRTVItemModel.h"

@interface WVRTVVideoDetailModel : WVRBaseModel
-(void)http_detailWithCode:(NSString*)code successBlock:(void(^)(WVRTVItemModel*))successBlock failBlock:(void(^)(NSString*))failBlock;

-(void)http_SerieswithCode:(NSString*)code successBlock:(void(^)(WVRTVItemModel*))successBlock failBlock:(void(^)(NSString*))failBlock;
@end
