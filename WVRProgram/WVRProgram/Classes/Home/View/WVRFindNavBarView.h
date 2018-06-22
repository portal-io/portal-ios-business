//
//  WVRFindNavBarView.h
//  WhaleyVR
//
//  Created by qbshen on 2017/3/20.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRXibView.h"

@interface WVRFindNavBarView : WVRXibView

@property (nonatomic, copy) void(^startSearchClickBlock)();
@property (nonatomic, copy) void(^cacheClickBlock)();
@property (nonatomic, copy) void(^historyClickBlock)();

@end
