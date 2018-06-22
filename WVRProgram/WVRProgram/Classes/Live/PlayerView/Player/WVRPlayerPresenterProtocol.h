//
//  WVRPlayerPresenter.h
//  WhaleyVR
//
//  Created by qbshen on 2017/2/17.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRPresenterProtocol.h"

static NSString * const WVRPlayerErrorDomain = @"com.WVR.player";
static NSString * const WVRPlayerErrorStatusKey = @"WVRPlayerError";


@class WVRPlayerInfo;


typedef NS_ENUM(NSInteger, WVRSmallPlayerViewType) {
    WVRSmallPlayerViewDefault,
    WVRSmallPlayerViewBanner,
    WVRSmallPlayerViewSmall,
    WVRSmallPlayerViewFull,
    WVRSmallPlayerViewHalf
};

typedef NS_ENUM(NSInteger, WVRPlayerError) {
    WVRPlayerErrorUN,
    WVRPlayerErrorNet,
    
};

@protocol WVRPlayerPresenterProtocol <WVRPresenterProtocol>

- (void)changeWithType:(WVRSmallPlayerViewType)viewType;

- (void)saveOriginFrame;

- (WVRSmallPlayerViewType)checkCurViewType;

- (void)changeViewFrameForBanner;

- (void)changeViewFrameForFull;

- (void)didRotaionAnima;

- (void)updateToolVHiden;

- (void)updateNetSpeed;

- (void)stopPerformWithHiddenV:(BOOL)hidden;

- (void)startPerformWithHiddenV:(BOOL)hidden;

@optional

/**
 init

 @param info params for init
 */
- (void)initWithInfo:(WVRPlayerInfo *)info;

- (void)updateInfo:(WVRPlayerInfo *)newInfo;

- (BOOL)checkPlayEnvironment;

- (void)initPlayer;

- (void)prepare;

- (void)restart;

- (void)start;

- (void)stop;

- (void)destroy;

- (BOOL)isPlaying;

- (BOOL)isPaused;

- (void)updateFrame:(CGRect)frame;

- (void)destroyForLauncher;
/**
 The possible error codes for a `player` . When an error block or the corresponding delegate method are called, an `NSError` instance is passed as parameter. If the domain of this `NSError` is WVRPlayers, the `code` parameter will be set to one of these values.


 @param error
 
 //error = [NSError errorWithDomain:TCBlobDownloadErrorDomain
 //                            code:TCBlobDownloadErrorHTTPError
 //                        userInfo:@{ NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Erroneous HTTP status code %ld (%@)",
 //                                                               (long) httpResponse.statusCode,
 //                                                               [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]],
 //                                    TCBlobDownloadErrorHTTPStatusKey: @(httpResponse.statusCode) }];
 */
//- (void) onError:(NSError*) error;


/**
 player progress call back

 @param progress
 @param totalProgress <#totalProgress description#>
 */
//- (void)updateProgress:(float)progress cacheProgress:(float)cacheProgress totalDuration:(int64_t)duration;


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
@end
