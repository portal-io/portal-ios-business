//
//  WVRModifyPWViewModel.h
//  WhaleyVR
//
//  Created by qbshen on 2017/8/25.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRViewModel.h"

@interface WVRModifyPWViewModel : WVRViewModel


@property (nonatomic, strong) NSString * oldPW;
@property (nonatomic, strong) NSString * inputPW;
@property (nonatomic, strong) NSString * inputCode;


@property (nonatomic, strong, readonly) RACSignal * mCompleteSignal;

@property (nonatomic, strong, readonly) RACSignal * fCompleteSignal;

-(RACCommand*)modifyPWCmd;

-(RACCommand*)forgotPWCmd;

@end
