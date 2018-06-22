//
//  WVRSQFindModel.h
//  WhaleyVR
//
//  Created by qbshen on 16/11/14.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRBaseModel.h"
#import "WVRBannerModel.h"
#import "WVRSectionModel.h"
#import "WVRHtttpRecommendPage.h"
#import "WVRTagModel.h"


typedef NS_ENUM(NSInteger, WVRSQFindModelType){
    
    WVRSQFindModelTypeBanner,
    WVRSQFindModelTypeTag,
    WVRSQFindModelTypeHot,
    WVRSQFindModelTypeOnlyShow,
    WVRSQFindModelTypeNewSound,
    WVRSQFindModelTypeBrands,
    WVRSQFindModelTypeArts,
};

@interface WVRSQFindModel : WVRBaseModel

@property (nonatomic) BOOL haveTV;

- (void)http_recommendPageWithCode:(NSString*)code successBlock:(void(^)(NSDictionary*, NSString* ,NSString* ))successBlock failBlock:(void(^)(NSString*))failBlock;

- (NSMutableArray*)parseDefaultHttpRecommendArea:(WVRHttpRecommendArea*)recommendArea sectionModel:(WVRSectionModel*)sectionModel;

@end

