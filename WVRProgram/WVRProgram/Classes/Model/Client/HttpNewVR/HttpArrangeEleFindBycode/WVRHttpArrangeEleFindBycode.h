//
//  WVRHttpArrangeElements.h
//  WhaleyVR
//
//  Created by Xie Xiaojian on 2016/10/28.
//  Copyright © 2016年 Snailvr. All rights reserved.
//
#import "WVRNewVRBaseGetRequest.h"
#import "WVRHttpArrangeElementsPageModel.h"
#import "WVRHttpArrangeElementModel.h"
@class WVRSectionModel;

/*
 "id": 23,
 "createTime": 1478945818000,
 "updateTime": 1479112810000,
 "publishTime": 1479113151783,
 "name": "蒙面唱将第八期",
 "code": "MaskSinger_8th",
 "position": 0,
 "businessVersion": "null",
 "appType": "null",
 "type": 3,
 "parentId": 3,
 "isLeaf": true,
 "bigImageUrl": "http://image.aginomoto.com/image/get-image/10000004/14791127902672382433.jpg/zoom/1080/608",
 "introduction": "
 */
@interface WVRHttpArrangeEleFByCModel : NSObject

@property (nonatomic) NSString * Id;
@property (nonatomic) NSString * name;
@property (nonatomic) NSString * code;
@property (nonatomic) NSString * type;
@property (nonatomic) NSString * bigImageUrl;
@property (nonatomic) NSString * introduction;

@property (nonatomic) NSArray<WVRHttpArrangeElementModel *> *arrangeTreeElements;

@end


@interface WVRHttpArrangeEleFindBycodeModel : WVRNewVRBaseResponse

@property (nonatomic) WVRHttpArrangeEleFByCModel *data;

- (WVRSectionModel *)convertToSectionModel;

@end


@interface WVRHttpArrangeEleFindBycode : WVRNewVRBaseGetRequest

@property (nonatomic, copy) NSString *treeNodeCode;

@end

