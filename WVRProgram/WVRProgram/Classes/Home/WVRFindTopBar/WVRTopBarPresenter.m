//
//  WVRFindTopBarPresenterImpl.m
//  WhaleyVR
//
//  Created by qbshen on 2017/3/21.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRTopBarPresenter.h"
#import "WVRTopTabViewProtocol.h"
#import "WVRHtttpRecommendPage.h"
#import "WVRBaseViewCProtocol.h"
#import "WVRSectionModel.h"
#import "WVRTopBarViewModel.h"

@interface WVRTopBarPresenter ()

@property (nonatomic, weak) id<WVRTopTabViewProtocol,WVRBaseViewCProtocol> mTopBarView;
@property (nonatomic, strong) NSMutableArray* mItemModels;

@property (nonatomic, strong) WVRTopBarViewModel * gTopBarViewModel;

@end
@implementation WVRTopBarPresenter

-(instancetype)initWithParams:(id)params attchView:(id<WVRViewProtocol>)view
{
    self = [super init];
    if (self) {
        if ([view conformsToProtocol:@protocol(WVRTopTabViewProtocol)] && [view conformsToProtocol:@protocol(WVRBaseViewCProtocol)]) {
            self.args = params;
            self.mTopBarView = (id <WVRTopTabViewProtocol,WVRBaseViewCProtocol>)view;
        } else {
            NSException *exception = [[NSException alloc] init];
            @throw exception;
        }
        [self installRAC];
    }
    return self;
}

-(WVRTopBarViewModel *)gTopBarViewModel
{
    if (!_gTopBarViewModel) {
        _gTopBarViewModel = [[WVRTopBarViewModel alloc] init];
    }
    return _gTopBarViewModel;
}

-(void)installRAC
{
    @weakify(self);
    [[self.gTopBarViewModel mCompleteSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self httpSuccessBlock:x];
    }];
    [[self.gTopBarViewModel mFailSignal] subscribeNext:^(WVRErrorViewModel*  _Nullable x) {
        @strongify(self);
        [self failBlock:x.errorMsg];
    }];
}

-(void)fetchData
{
    [self requestInfo];
}

-(void)requestInfo:(id)requestParams
{
    self.args = requestParams;
    [self requestInfo];
}

-(void)requestInfo
{
    [self http_recommendPageWithCode:self.args];
}

#pragma http movie
-(void)http_recommendPageWithCode:(NSString*)code
{
    if (self.mItemModels.count==0) {
        [self.mTopBarView showLoadingWithText:nil];
    }
    self.gTopBarViewModel.code = code;
    [[self.gTopBarViewModel getTopBarListCmd] execute:nil];
//    WVRHtttpRecommendPage  * cmd = [WVRHtttpRecommendPage new];
//    cmd.code = code;//kHttpParams_RecommendPage_code_movie;
//    //    if (self.haveTV) {
//    NSMutableDictionary * params = [NSMutableDictionary dictionary];
//    params[kHttpParams_HaveTV] = @"1";
//    cmd.bodyParams = params;
//    //    }
//    cmd.successedBlock = ^(WVRHttpRecommendPageDetailParentModel* args){
//        [weakself httpSuccessBlock:args];
//    };
//    
//    cmd.failedBlock = ^(id args){
//        [weakself.mTopBarView hidenLoading];
//        if ([args isKindOfClass:[NSString class]]) {
//            if (weakself.mItemModels.count == 0) {
//                [weakself.mTopBarView showNetErrorVWithreloadBlock:^{
//                    [weakself requestInfo];
//                }];
//            }
//        }
//    };
//    [cmd execute];
}

-(void)httpSuccessBlock:(WVRHttpRecommendPageDetailModel* )args{
    [self.mTopBarView hidenLoading];
    NSArray * recommendAreas = [args  recommendAreas];
    WVRSectionModel * sectionModel = [self parseSectionHttpModel:[recommendAreas firstObject]];
    self.mItemModels = [NSMutableArray new];
    for (WVRItemModel * cur in sectionModel.itemModels) {
        switch (cur.linkType_) {
            case WVRLinkTypeMix:
                [self.mItemModels addObject:cur];
                break;
            case WVRLinkTypeList:
                [self.mItemModels addObject:cur];
                break;
            case WVRLinkTypePage:
                [self.mItemModels addObject:cur];
                break;
//            case WVRLinkTypeTitle:
//                [self.mItemModels addObject:cur];
//                break;
            default:
                break;
        }
    }
    
    if (self.mItemModels.count == 0) {
        [self.mTopBarView showNullViewWithTitle:nil icon:nil];
    }else{
        NSMutableArray * curTitles = [NSMutableArray new];
        for (WVRItemModel* cur in self.mItemModels) {
            [curTitles addObject:cur.name];
        }
        [self.mTopBarView updateWithTitles:curTitles andItemModels:self.mItemModels];
    }
    
}

-(void)failBlock:(NSString*)msg
{
    [self.mTopBarView hidenLoading];
    if (self.mItemModels.count == 0) {
        @weakify(self);
        [self.mTopBarView showNetErrorVWithreloadBlock:^{
            @strongify(self);
            [self requestInfo];
        }];
    }
}

-(WVRSectionModel*)parseSectionHttpModel:(WVRHttpRecommendArea*)recommendArea
{
    WVRSectionModel* sectionModel = [WVRSectionModel new];
    WVRSectionModelType sectionType = [sectionModel parseSectionTypeWithHttpRecAreaType:recommendArea.type];
    sectionModel.sectionType = sectionType;
    
    sectionModel.itemModels = [self parseHotHttpRecommendArea:recommendArea];
    return sectionModel;
}

-(NSMutableArray*)parseHotHttpRecommendArea:(WVRHttpRecommendArea*)recommendArea
{
    NSMutableArray * models = [NSMutableArray array];
    for (WVRHttpRecommendElement* element in [recommendArea recommendElements]) {
        WVRItemModel * model = [self parseHttpTextElement:element];
        [models addObject:model];
    }
    return models;
}

-(WVRItemModel *)parseHttpTextElement:(WVRHttpRecommendElement* )element
{
    WVRItemModel * model = [WVRItemModel new];
    model.name = element.name;
    model.linkArrangeType = element.linkArrangeType;
    model.linkArrangeValue = element.linkArrangeValue;
    model.recommendPageType = element.recommendPageType;
    model.code = element.code;
    model.recommendAreaCodes = element.recommendAreaCodes;
    return model;
}

-(void)dealloc
{
    DDLogDebug(@"");
}

@end
