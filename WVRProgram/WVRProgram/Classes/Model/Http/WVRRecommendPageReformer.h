//
//  WVRRecommendPageReformer.h
//  WVRProgram
//
//  Created by qbshen on 2017/9/16.
//  Copyright © 2017年 snailvr. All rights reserved.
//

#import <WVRNet/WVRNetDataReformerCMS.h>

@interface WVRRecommendPageModel : NSObject

@property (nonatomic, strong) NSMutableDictionary * sectionModels;

@property (nonatomic, strong) NSString * firstSectionModelName;

@property (nonatomic, strong) NSString * name;

@end

@interface WVRRecommendPageReformer : WVRNetDataReformerCMS

@end
