//
//  WVRHttpSearch.h
//  WhaleyVR
//
//  Created by Xie Xiaojian on 2016/11/1.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRNewVRBaseGetRequest.h"
#import "WVRHttpSearchModel.h"

extern NSString * const kHttpParams_search_keyWord;
extern NSString * const kHttpParams_search_type;


@interface WVRHttpSearchMainModel : WVRNewVRBaseResponse

@property (nonatomic) WVRHttpSearchModel* data;

@end


@interface WVRHttpSearch : WVRNewVRBaseGetRequest

@end

