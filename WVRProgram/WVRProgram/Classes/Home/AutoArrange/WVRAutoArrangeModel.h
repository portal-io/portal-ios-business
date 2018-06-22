//
//  WVRSQDefaultFindMoreModel.h
//  WhaleyVR
//
//  Created by qbshen on 16/11/15.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRBaseModel.h"
#import "WVRSectionModel.h"

@interface WVRAutoArrangeModel : WVRBaseModel
@property (nonatomic) WVRSectionModel * sectionModel;
@property (nonatomic) NSMutableDictionary * modelDic;
-(void)http_recommendPage:(NSString*)code successBlock:(void(^)(NSDictionary*))successBlock failBlock:(void(^)(NSString*))failBlock;
-(void)http_recommendPageMore:(NSString*)code successBlock:(void(^)(NSDictionary*))successBlock failBlock:(void(^)(NSString*))failBlock;

//TV
-(void)http_recommendTVPage:(NSString*)code successBlock:(void(^)(NSDictionary*))successBlock failBlock:(void(^)(NSString*))failBlock;
-(void)http_recommendTVPageMore:(NSString*)code successBlock:(void(^)(NSDictionary*))successBlock failBlock:(void(^)(NSString*))failBlock;
@end
