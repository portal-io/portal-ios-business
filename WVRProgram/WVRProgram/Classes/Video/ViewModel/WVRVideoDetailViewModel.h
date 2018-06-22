//
//  WVRVideoDetailViewModel.h
//  WhaleyVR
//
//  Created by Bruce on 2017/9/4.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WVRViewModel.h"
#import "WVRVideoDetailVCModel.h"

@interface WVRVideoDetailViewModel : WVRViewModel

@property (nonatomic, strong) NSDictionary *requestParams;

@property (nonatomic, strong) WVRVideoDetailVCModel *dataModel;

@property (nonatomic, strong, readonly) RACSignal * gSuccessSignal;
@property (nonatomic, strong, readonly) RACSignal * gFailSignal;

@property (nonatomic, strong, readonly) RACCommand * gDetailCmd;

@end
