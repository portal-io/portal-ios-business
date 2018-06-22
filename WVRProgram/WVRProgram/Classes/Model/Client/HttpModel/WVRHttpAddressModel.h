//
//  WVRHttpAddressModel.h
//  WhaleyVR
//
//  Created by qbshen on 2016/12/12.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRStoreapiBaseResponse.h"

@interface WVRHttpAddressModel : WVRStoreapiBaseResponse

@property (nonatomic) NSString* mobile;
@property (nonatomic) NSString* name;
@property (nonatomic) NSString* province;
@property (nonatomic) NSString* city;
@property (nonatomic) NSString* county;
@property (nonatomic) NSString* address;

@end
