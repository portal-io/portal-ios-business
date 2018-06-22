//
//  WVRSearchViewController.m
//  WhaleyVR
//
//  Created by zhangliangliang on 9/23/16.
//  Copyright © 2016 Snailvr. All rights reserved.
//

#import "WVRSearchViewController.h"
#import "WVRSearchView.h"
#import "WVRSortItemModel.h"
#import "WVRSortItemView.h"
#import "WVRHttpSearch.h"
#import "SQRefreshHeader.h"

@interface WVRSearchViewController ()<WVRSearchViewDelegate>

@property (nonatomic, strong) WVRSearchView *contentView;

@end


@implementation WVRSearchViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self configSubviews];
    [_contentView showKeyboard];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view.window resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [[NSUserDefaults standardUserDefaults] setObject:_contentView.searchHistoryArray forKey:@"searchKeyWord"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)configSubviews {
    
    _contentView = [[WVRSearchView alloc] init];
    _contentView.frame = self.view.bounds;
    _contentView.delegate = self;
    [_contentView setSearchBarHolder:@"输入搜索文字"];
    [self.view addSubview:_contentView];
}

- (NSArray *)getModelArrayFromDicArray:(NSArray *)array
{
    NSMutableArray *modelArray = [[NSMutableArray alloc] init];
    
    for (WVRHttpSimpleProgramModel *cur in array) {
        
        WVRSortItemModel *model = [[WVRSortItemModel alloc] init];
        model.title = cur.display_name;
        model.desc = cur.desc;
        model.sid = cur.code;
        model.image = cur.big_pic;
        model.resource_code = cur.code;
        
        model.director = @[cur.director];
        model.actor = [self parseActors:cur.actors];
        model.tags = cur.tags;
        model.videoType = cur.video_type;//(WVRVideoStyleVR == _videoStyle) ? VIDEO_TYPE_VR : VIDEO_TYPE_3D;
        model.area = cur.area;
        
        [modelArray addObject:model];
    }
    
    return [modelArray copy];
}

- (NSString *)parseActors:(NSString *)actorStr
{
    NSString * str = @"";
    NSArray* arr = [actorStr componentsSeparatedByString:@";"];
    for (NSString* cur in arr) {
        str = [str stringByAppendingString:cur];
    }
    return str;
}

#pragma mark - WVRSearchViewDelegate

- (void)searchDataWithKeyWord:(NSString *)keyword {
    
    [self http_recommendPageWithCode:keyword];
    
    [self.view endEditing:YES];
}

#pragma mark - http movie

- (void)http_recommendPageWithCode:(NSString *)keyWord {
    
    SQShowProgress;
    WVRHttpSearch  * cmd = [WVRHttpSearch new];
    NSMutableDictionary * requestInfo = [NSMutableDictionary dictionary];
    requestInfo[kHttpParams_search_keyWord] = keyWord;
//    NSString *videoType = (WVRVideoStyleVR == _videoStyle) ? @"1" : @"2";
//    requestInfo[kHttpParams_search_type] = videoType;
    cmd.bodyParams = requestInfo;
    kWeakSelf(self);
    cmd.successedBlock = ^(WVRHttpSearchMainModel* args){
        [weakself hideProgress];
        [weakself parseHttpData:args];
    };
    
    cmd.failedBlock = ^(id args){
        [weakself hideProgress];
        [weakself requestFaild:args];
    };
    [cmd execute];
}


- (void)requestFaild:(NSString *)errorStr {
    
    [self showMessageToWindow:errorStr];
}

- (void)parseHttpData:(WVRHttpSearchMainModel *)data {
    
    NSArray *modelArray = [self getModelArrayFromDicArray:[[data data] program]];
    
    if (modelArray.count > 0) {
        
        _contentView.resultsIsNull = NO;
        
//        if (WVRVideoStyleVR == _videoStyle) {
//            
//            _contentView.isShow3DResult = NO;
//            
//            _contentView.tableView.hidden = YES;
//            _contentView.searchResultsView.hidden = NO;
//            [_contentView.searchResultsView setDataArray:modelArray];
//            _contentView.searchResultsView.collectionView.mj_footer.hidden = YES;
//            
//        } else if (WVRVideoStyle3D == _videoStyle) {
//            
            _contentView.searchResultsView.hidden = YES;
            
            _contentView.isShow3DResult = YES;
            _contentView.searchResultsFor3DArray = modelArray;
            _contentView.tableView.mj_header.hidden = NO;
            _contentView.tableView.hidden = NO;
            [_contentView.tableView reloadData];
//        }
    } else {
        _contentView.isShow3DResult = NO;
        
        _contentView.tableView.hidden = NO;
        _contentView.tableView.mj_header.hidden = YES;
        _contentView.searchResultsView.hidden = YES;
        _contentView.resultsIsNull = YES;
        [_contentView.tableView reloadData];
    }
}

@end
