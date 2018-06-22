//
//  WVRCollectionModel.m
//  WhaleyVR
//
//  Created by qbshen on 2017/1/6.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRCollectionVCModel.h"
#import "WVRHttpCollectionGet.h"
#import "WVRHttpCollectionSave.h"
#import "WVRHttpCollectionDel.h"
#import "WVRHttpCollectionOne.h"


@implementation WVRCollectionVCModel
+ (void)http_CollectionGetWithSuccessBlock:(void(^)(WVRCollectionVCModel*))successBlock failBlock:(void(^)(NSString *))failBlock
{
    WVRHttpCollectionGet  * cmd = [WVRHttpCollectionGet new];
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[kHttpParams_collectionGet_userLoginId] = [[WVRUserModel sharedInstance] accountId];
    params[kHttpParams_collectionGet_page] = @"0";
    params[kHttpParams_collectionGet_size] = @"1000";
    cmd.bodyParams = params;
    
    cmd.successedBlock = ^(WVRHttpCollectionGetModel* args){
        WVRCollectionVCModel * vcModel = [WVRCollectionVCModel new];
        vcModel.collections = [NSMutableArray array];
        for (WVRHttpCollectionModel* cur in args.data.content) {
            WVRCollectionModel * model = [WVRCollectionModel new];
            model.userName = cur.userName;
            model.programCode = cur.programCode;
            model.programName = cur.programName;
            model.programType = cur.programType;
            model.duration = cur.duration;
            model.status = cur.status;
            model.videoType = cur.videoType;
            model.thubImageUrl = cur.picUrl;
            [vcModel.collections addObject:model];
        }
        successBlock(vcModel);
    };
    
    cmd.failedBlock = ^(id args){
        if ([args isKindOfClass:[NSString class]]) {
            failBlock(args);
        }
    };
    [cmd execute];
}

+ (void)http_CollectionOneWithModel:(WVRTVItemModel*)tvModel successBlock:(void(^)(WVRCollectionModel*))successBlock failBlock:(void(^)(NSString *))failBlock
{
    WVRHttpCollectionOne  * cmd = [WVRHttpCollectionOne new];
    cmd.userLoginId = [[WVRUserModel sharedInstance] accountId];
    cmd.programCode = tvModel.code;
    
    cmd.successedBlock = ^(WVRHttpCollectionOneModel* args){
        if (!args.data) {
            successBlock(nil);
            return ;
        }
        WVRCollectionModel * model = [WVRCollectionModel new];
        model.userName = args.data.userName;
        model.programCode = args.data.programCode;
        model.programName = args.data.programName;
        model.programType = args.data.programType;
        model.duration = args.data.duration;
        model.status = args.data.status;
        model.videoType = args.data.videoType;
        successBlock(model);
    };
    
    cmd.failedBlock = ^(id args){
        if ([args isKindOfClass:[NSString class]]) {
            failBlock(args);
        }
    };
    [cmd execute];
}

+ (void)http_CollectionSaveWithModel:(WVRTVItemModel *)tvModel successBlock:(void(^)())successBlock failBlock:(void(^)(NSString *))failBlock
{
    WVRHttpCollectionSave  * cmd = [[WVRHttpCollectionSave alloc] init];
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[kHttpParams_collectionSave_userLoginId] = [[WVRUserModel sharedInstance] accountId];
    params[kHttpParams_collectionSave_userName] = [[WVRUserModel sharedInstance] username];
    params[kHttpParams_collectionSave_programCode] = tvModel.code;
    params[kHttpParams_collectionSave_programName] = tvModel.name.length>0? tvModel.name:@"name";
    params[kHttpParams_collectionSave_programType] = tvModel.programType.length>0? tvModel.programType:PROGRAMTYPE_MORETV_TV;
    params[kHttpParams_collectionSave_videoType] = [NSString stringWithFormat:@"%@",(long)tvModel.videoType.length>0? tvModel.videoType:@"moretv_2d"];
    params[kHttpParams_collectionSave_status] = @"1";
    params[kHttpParams_collectionSave_duration] = tvModel.duration.length>0? tvModel.duration:@"0";
    params[kHttpParams_collectionSave_picUrl] = tvModel.thubImageUrl.length>0? tvModel.thubImageUrl:@"null";
    cmd.bodyParams = params;
    
    cmd.successedBlock = ^(WVRNewVRBaseResponse* args){
        successBlock();
    };
    
    cmd.failedBlock = ^(id args){
        if ([args isKindOfClass:[NSString class]]) {
            failBlock(args);
        }
    };
    [cmd execute];
}

+ (void)http_CollectionDelWithModel:(WVRTVItemModel*)tvModel successBlock:(void(^)())successBlock failBlock:(void(^)(NSString *))failBlock
{
    WVRHttpCollectionDel  * cmd = [WVRHttpCollectionDel new];
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[kHttpParams_collectionDel_userLoginId] = [[WVRUserModel sharedInstance] accountId];
    params[kHttpParams_collectionDel_programCode] = tvModel.code;
    
    cmd.bodyParams = params;
    
    cmd.successedBlock = ^(WVRNewVRBaseResponse* args){
        successBlock();
    };
    
    cmd.failedBlock = ^(id args){
        if ([args isKindOfClass:[NSString class]]) {
            failBlock(args);
        }
    };
    [cmd execute];
}


@end
