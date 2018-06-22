//
//  WVRProgramBIModel.m
//  WhaleyVR
//
//  Created by Bruce on 2017/8/11.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRProgramBIModel.h"
#import "WVRTrackEventMapping.h"

@implementation WVRProgramBIModel

+ (void)trackEventForTopicWithAction:(BITopicActionType)action topicId:(NSString *)topicId topicName:(NSString *)topicName videoSid:(NSString *)videoSid videoName:(NSString *)videoName index:(NSInteger)index isPackage:(BOOL)isPackage {
    
    WVRBIModel *model = [[WVRBIModel alloc] init];
    model.logInfo.currentPageId = isPackage ? @"programSet" : @"topic";
    model.logInfo.nextPageId = @"play";
    model.logInfo.eventId = @"onClick_view";
    
    NSMutableDictionary *currentPageProp = [NSMutableDictionary dictionary];
    NSMutableDictionary *eventProp = [NSMutableDictionary dictionary];
    
    currentPageProp[@"pageId"] = topicId;
    currentPageProp[@"pageName"] = topicName;
    currentPageProp[@"videoSid"] = videoSid;
    currentPageProp[@"videoName"] = videoName;
    
    switch (action) {
            case BITopicActionTypeBrowse: {
                
                model.logInfo.eventId = @"browse_view";
                model.logInfo.nextPageId = model.logInfo.currentPageId;
            }
            break;
            
            case BITopicActionTypeItemPlay: {
                
                eventProp[@"locationIndex"] = @(index);
            }
            break;
            
            case BITopicActionTypeListPlay: {
                
                eventProp[@"locationIndex"] = @(index);
            }
            break;
            
        default:
            break;
    }
    
    model.logInfo.eventProp = eventProp;
    model.logInfo.currentPageProp = currentPageProp;
    
    [model saveToSQLite];
}

+ (void)trackEventForDetailWithAction:(BIDetailActionType)action sid:(NSString *)sid name:(NSString *)name {
    
    WVRBIModel *model = [[WVRBIModel alloc] init];
    model.logInfo.currentPageId = @"videoDetails";
    if (action == BIDetailActionTypeReserveLive || action == BIDetailActionTypeBrowseLivePrevue) {
        model.logInfo.currentPageId = @"livePrevue";
    } else if (action == BIDetailActionTypeBrowseLivePlay) {
        model.logInfo.currentPageId = @"liveDetails";
    }
    
    model.logInfo.eventId = @"browse_view";
    model.logInfo.nextPageId = model.logInfo.currentPageId;
    
    NSMutableDictionary *currentPageProp = [NSMutableDictionary dictionary];
    NSMutableDictionary *eventProp = [NSMutableDictionary dictionary];
    
    currentPageProp[@"videoSid"] = sid;
    currentPageProp[@"videoName"] = name;
    
    switch (action) {
            case BIDetailActionTypeBrowseVR: {
                
            }
            break;
            
            case BIDetailActionTypeDownloadVR: {
                
                model.logInfo.eventId = @"download_click";
            }
            break;
            
            case BIDetailActionTypeCollectionVR: {
                
                model.logInfo.eventId = @"collection_click";
            }
            break;
            
            case BIDetailActionTypeBrowseLivePrevue:
            case BIDetailActionTypeBrowseLivePlay:
            break;
            
            case BIDetailActionTypeReserveLive: {
                
                model.logInfo.eventId = @"prevue_click";
            }
            break;
            
        default:
            break;
    }
    
    model.logInfo.eventProp = eventProp;
    model.logInfo.currentPageProp = currentPageProp;
    
    [model saveToSQLite];
}

+ (void)recommendTabSelect:(kTabBarIndex)selectedIndex {
    
    switch (selectedIndex) {
        case kRecommendTabBarIndex:
            [WVRTrackEventMapping trackEvent:@"home" flag:@"recommendation"];
            break;
        case kLiveTabBarIndex:
            [WVRTrackEventMapping trackEvent:@"home" flag:@"live"];
            break;
        case kLauncherTabBarIndex:
            [WVRTrackEventMapping trackEvent:@"home" flag:@"launcher"];
            break;
        case kFindTabBarIndex:
            [WVRTrackEventMapping trackEvent:@"home" flag:@"discovery"];
            break;
        case kAccountTabBarIndex:
            [WVRTrackEventMapping trackEvent:@"home" flag:@"me"];
            break;
            
        default:
            DDLogError(@"recommendTabSelect： 未预料的事件");
            break;
    }
}

@end
