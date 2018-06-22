//
//  WVRRedeemCodeExchangeModel.m
//  WhaleyVR
//
//  Created by Bruce on 2017/6/15.
//  Copyright © 2017年 Snailvr. All rights reserved.

// 兑换码兑换接口

#import "WVRRedeemCodeExchangeModel.h"
#import "YYModel.h"
#import "SQMD5Tool.h"

//#import "WVRWhaleyHTTPManager.h"
//#import "WVRRequestClient.h"

@implementation WVRRedeemCodeExchangeModel

// code subcode
//200	000	success	目前系统正常返回都是200
//400	001	用户id为空	参数缺失
//400	014	签名参数为空	签名参数为空
//400	032	兑换码为空	兑换码为空
//400	033	兑换码不存在	兑换码不存在                // 兑换码错误，请检查输入
//400	034	兑换码已被本人兑换	兑换码已被本人兑换       // 这个兑换码之前兑换过啦 :p
//400	035	兑换码已被他人兑换	兑换码已被他人兑换       // 这个兑换码已经被兑换过，如非本人操作请联系客服
//400	036	用户已拥有此券	用户已拥有此券              // 你已经拥有了同样的观看券了，这个兑换码还可以送给朋友哦 :p
//400	037	活动失效或者已过期	活动失效或者已过期       // 该兑换码已经过了有效兑换期 :(
//401	000	auth error	鉴权失败
//500	000	server error	系统异常


/// 兑换码兑换接口
+ (void)exchangeWithRedeemCode:(NSString *)redeemCode block:(void (^)(WVRMyTicketItemModel *model, NSError *error))block; {
    
//    NSMutableDictionary *param = [NSMutableDictionary dictionary];
//    param[@"uid"] = [WVRUserModel sharedInstance].accountId;
//    param[@"redeemCode"] = redeemCode;
//    
//    NSString *key = [WVRUserModel CMCPURCHASE_sign_secret];
//    NSString *str = [NSString stringWithFormat:@"%@%@", param[@"uid"], param[@"redeemCode"]];
//    NSString *sign = [SQMD5Tool encryptByMD5:str md5Suffix:key];
//    
//    param[@"sign"] = sign;
//    
//    NSString *url = [[WVRUserModel kNewVRBaseURL] stringByAppendingString:@"newVR-report-service/redeemCode/userDoRedeem"];
//    
//    [WVRRequestClient POSTService:url withParams:param completionBlock:^(id responseObj, NSError *error) {
//        
//        if (error) {
//            
//            block(nil, error);
//            
//        } else {
//            NSDictionary *dict = responseObj;
//            int code = [dict[@"code"] intValue];
//            NSString *msg = [NSString stringWithFormat:@"%@", dict[@"msg"]];
//            
//            if (code == 200) {
//                
//                NSDictionary *data = dict[@"data"];
//                WVRMyTicketItemModel *model = [WVRMyTicketItemModel yy_modelWithDictionary:data];
//                
//                block(model, nil);
//                
//            } else {
//                if (code == 400) {
//                    int subCode = [dict[@"subCode"] intValue];
//                    switch (subCode) {
//                        case 33:
//                            msg = @"兑换码错误，请检查输入";
//                            break;
//                        case 34:
//                            msg = @"这个兑换码之前兑换过啦 :p";
//                            break;
//                        case 35:
//                            msg = @"这个兑换码已经被兑换过，如非本人操作请联系客服";
//                            break;
//                        case 36:
//                            msg = @"你已经拥有了同样的观看券了，这个兑换码还可以送给朋友哦 :p";
//                            break;
//                        case 37:
//                        case 44:
//                            msg = @"该兑换码已经过了有效兑换期 :(";
//                            break;
//                            
//                        default:
//                            break;
//                    }
//                }
//                NSError *err = [NSError errorWithDomain:msg code:code userInfo:dict];
//                block(nil, err);
//            }
//        }
//    }];
}

@end
