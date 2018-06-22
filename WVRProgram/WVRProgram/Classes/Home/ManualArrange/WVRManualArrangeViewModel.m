//
//  WVRSQArrangeMAMoreModel.m
//  WhaleyVR
//
//  Created by qbshen on 16/11/17.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRManualArrangeViewModel.h"
#import "WVRHttpArrangeEleFindBycode.h"

@implementation WVRManualArrangeViewModel

+ (void)http_recommendPageWithCode:(NSString *)code successBlock:(void(^)(WVRSectionModel *))successBlock failBlock:(void(^)(NSString *))failBlock {
    
    WVRHttpArrangeEleFindBycode *cmd = [[WVRHttpArrangeEleFindBycode alloc] init];
    cmd.treeNodeCode = code;
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[@"v"] = @"1";
    params[@"containArrange"] = @(YES);
    cmd.bodyParams = params;
    cmd.successedBlock = ^(WVRHttpArrangeEleFindBycodeModel* args) {
        [self httpSuccessBlock:args successBlock:^(WVRSectionModel *args) {
            successBlock(args);
        }];
    };
    
    cmd.failedBlock = ^(id args){
        if ([args isKindOfClass:[NSString class]]) {
            failBlock(args);
        }
    };
    [cmd execute];
}

+ (void)httpSuccessBlock:(WVRHttpArrangeEleFindBycodeModel *)args successBlock:(void(^)(WVRSectionModel *))successBlock {
    
    WVRSectionModel * sectionModel = [args convertToSectionModel];
    
    successBlock(sectionModel);
}

@end
