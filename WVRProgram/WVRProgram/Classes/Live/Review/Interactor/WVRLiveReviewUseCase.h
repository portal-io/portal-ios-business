//
//  WVRHomeTopBarListUseCase.h
//  WVRProgram
//
//  Created by qbshen on 2017/9/15.
//  Copyright © 2017年 snailvr. All rights reserved.
//

#import <WVRInteractor/WVRUseCase.h>
#import "WVRHttpRecommendPageDetailModel.h"

@interface WVRLiveReviewUseCase : WVRUseCase<WVRUseCaseProtocol>

@property (nonatomic, strong) NSString * code;
@property (nonatomic, strong) NSString * subCode;
@property (nonatomic, strong) NSString * pageNum;
@property (nonatomic, strong) NSString * pageSize;

@end
