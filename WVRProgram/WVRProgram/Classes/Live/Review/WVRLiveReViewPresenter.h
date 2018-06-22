//
//  WVRLiveViewController.h
//  WhaleyVR
//
//  Created by Snailvr on 16/8/31.
//  Copyright © 2016年 Snailvr. All rights reserved.

// 直播



#import "SQBaseCollectionPresenter.h"

@interface WVRLiveReViewPModel : NSObject

@property (nonatomic) NSString * linkCode;
@property (nonatomic) NSString * subCode;

@end
@interface WVRLiveReViewPresenter : SQBaseCollectionPresenter

+ (instancetype)createPresenter:(id)createArgs;
-(UIView*)getView;

@end
