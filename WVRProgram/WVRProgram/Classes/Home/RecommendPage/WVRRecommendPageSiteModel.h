//
//  WVRRecommendPageSiteModel.h
//  WhaleyVR
//
//  Created by qbshen on 2017/1/3.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRBaseModel.h"
#import "WVRSectionModel.h"


@interface WVRRecommendPageSiteModel : WVRBaseModel

-(void)http_recommendPageWithCode:(NSString*)code successBlock:(void(^)(NSDictionary*, NSString* ))successBlock failBlock:(void(^)(NSString*))failBlock;

-(void)http_recommendPageDetail:(WVRSectionModel*)sectionModel successBlock:(void(^)(NSDictionary*))successBlock failBlock:(void(^)(NSString*))failBlock;
-(void)http_recommendPageDetailMore:(WVRSectionModel*)sectionModel successBlock:(void(^)(NSDictionary*))successBlock failBlock:(void(^)(NSString*))failBlock;
@end
