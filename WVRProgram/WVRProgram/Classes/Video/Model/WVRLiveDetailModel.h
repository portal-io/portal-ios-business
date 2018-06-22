//
//  WVRLiveDetailModel.h
//  WhaleyVR
//
//  Created by Snailvr on 2016/11/25.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRItemModel.h"
@class WVRLiveDetailStat, WVRLiveDetailGuest;

@interface WVRLiveDetailModel : WVRItemModel

@property (nonatomic, assign) int isDanmu;
@property (nonatomic, assign) int isLottery;

@property (nonatomic, copy  ) NSString * address;
@property (nonatomic, assign) long beginTime;
@property (nonatomic, assign) long endTime;
@property (nonatomic, copy  ) NSString * description_;
@property (nonatomic, copy  ) NSString * displayName;
@property (nonatomic, strong) NSArray<WVRLiveDetailGuest *> * guests;
@property (nonatomic, copy  ) NSString * Id;

@property (nonatomic, copy  ) NSString * pic;
@property (nonatomic, copy  ) NSString * vipPic;

@property (nonatomic, copy  ) NSString * poster;
@property (nonatomic, assign) NSInteger publishTime;
@property (nonatomic, copy  ) NSString * source;
@property (nonatomic, strong) WVRLiveDetailStat * stat;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, copy  ) NSString * subtitle;
@property (nonatomic, copy  ) NSString * superscript;
@property (nonatomic, copy  ) NSString * typeName;
@property (nonatomic, copy  ) NSString * behaviour;

+ (void)requestForLiveDetailWithCode:(NSString *)sid block:(void(^)(WVRLiveDetailModel *responseObj, NSError *error))block;

@end


@interface WVRLiveDetailStat : NSObject

@property (nonatomic, assign) NSInteger viewCount;
@property (nonatomic, assign) NSInteger playCount;
@property (nonatomic, assign) NSInteger playSeconds;
@property (nonatomic, copy  ) NSString * programType;
@property (nonatomic, copy  ) NSString * srcCode;
@property (nonatomic, copy  ) NSString * srcDisplayName;
@property (nonatomic, copy  ) NSString * videoType;

@end


@interface WVRLiveDetailGuest : NSObject

@property (nonatomic, copy  ) NSString * guestName;
@property (nonatomic, copy  ) NSString * guestPic;

@end


