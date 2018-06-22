//
//  WVRPayBIModel.h
//  WhaleyVR
//
//  Created by Bruce on 2017/8/11.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WVRBIManager.h"
@class WVRPayModel;

@interface WVRPayBIModel : NSObject

+ (void)trackEventForPayWithAction:(BIPayActionType)action payModel:(WVRPayModel *)payModel fromVC:(UIViewController *)fromVC;

@end
