//
//  WVRProgramPackageViewModel.m
//  WhaleyVR
//
//  Created by qbshen on 17/4/13.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRProgramPackageViewModel.h"
#import "WVRHttpProgramPackage.h"
#import "WVRSectionModel.h"

@implementation WVRProgramPackageViewModel

+ (void)http_programPackageWithCode:(NSString *)code successBlock:(void(^)(WVRSectionModel *))successBlock failBlock:(void(^)(NSString *))failBlock
{
    WVRHttpProgramPackage *api = [[WVRHttpProgramPackage alloc] init];
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    params[kHttpParam_programPackage_code] = code;
    params[kHttpParam_programPackage_size] = @"100";
    params[kHttpParam_programPackage_page] = @"0";
    params[@"uid"] = [WVRUserModel sharedInstance].accountId;
    
    api.bodyParams = params;
    api.successedBlock = ^(WVRSectionModel *data) {
        successBlock(data);
    };
    api.failedBlock = ^(WVRNetworkingResponse *data) {
        failBlock(@"");
    };
    [api loadData];
}

@end
