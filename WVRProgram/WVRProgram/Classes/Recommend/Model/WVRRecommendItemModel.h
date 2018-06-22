//
//  WVRRecommendItemModel.h
//  WhaleyVR
//
//  Created by Snailvr on 16/9/2.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRItemModel.h"
#import "WVRWhaleyHTTPManager.h"
@class WVRStatQueryDto;

@interface WVRRecommendItemModel : WVRItemModel

@property (nonatomic, assign) NSInteger             programPlayTime;
@property (nonatomic, copy) NSString              * videoUrl;
@property (nonatomic, copy) NSString              * picUrl_;            // 映射字段
@property (nonatomic, strong) WVRStatQueryDto     * statQueryDto;

@end


@interface WVRStatQueryDto :NSObject

@property (nonatomic, assign) NSInteger playCount;
@property (nonatomic, assign) NSInteger viewCount;
@property (nonatomic, assign) NSInteger playSeconds;
@property (nonatomic, copy) NSString *programType;
@property (nonatomic, copy) NSString *videoType;
@property (nonatomic, copy) NSString *srcCode;
@property (nonatomic, copy) NSString *srcDisplayName;

+ (void)requestWithCode:(NSString *)code block:(void(^)(WVRStatQueryDto * responseObj, NSError *error))block;

@end

