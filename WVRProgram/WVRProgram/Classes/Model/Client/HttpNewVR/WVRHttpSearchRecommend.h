//
//  WVRHttpSearchRecommend.h
//  WhaleyVR
//
//  Created by Xie Xiaojian on 2016/11/1.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WVRNewVRBaseGetRequest.h"
#import "WVRHttpSearchRecommendModel.h"

extern NSString * const kHttpParams_searchRecommend_keyWord;
extern NSString * const kHttpParams_searchRecommend_type;
extern NSString * const kHttpParams_searchRecommend_code;

@interface WVRHttpSearchRecommendMainModel : WVRNewVRBaseResponse
    
@property(nonatomic) NSArray<WVRHttpSearchRecommendModel *> *data;
    
@end


@interface WVRHttpSearchRecommend : WVRNewVRBaseGetRequest
    
@end
