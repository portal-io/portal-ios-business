//
//  WVRUserInfoView.m
//  WhaleyVR
//
//  Created by zhangliangliang on 8/29/16.
//  Copyright © 2016 Snailvr. All rights reserved.
//

#import "WVRUserInfoView.h"
#import "WVRConfigCell.h"
#import "WVRAvatarTableViewCell.h"

#import "WVRUserModel.h"
#import "WVRLoginStyleHeader.h"

#define __CELL_KEY             @"WVRConfigCell"
#define __AVATAR_CELL_KEY      @"WVRAvatarTableViewCell"

#define __QUICK_CELL(style, title, info, avatar) \
[self cellWithStyle:style title:title info:info avatar:avatar]

@interface WVRUserInfoView()
<UITableViewDelegate,
UITableViewDataSource, WVRThirdPartyLoginViewDelegate>

@end

@implementation WVRUserInfoView

- (id)init {
    
    self = [super init];
    
    if (self) {
        [self configSelf];
        [self allocSubviews];
        [self configSubviews];
        [self positionSubvies];
    }
    
    return self;
}

- (void)configSelf {
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    _itemViewArray = [[NSMutableArray alloc] init];
    
    NSDictionary *dic0 = @{
                           @"title" : @"头像",
                           @"info" : [WVRUserModel sharedInstance].loginAvatar ?: @"",
                           };
    
    NSDictionary *dic1 = @{
                           @"title" : @"昵称",
                           @"info" : [WVRUserModel sharedInstance].username? [WVRUserModel sharedInstance].username:@"",
                           };
    NSDictionary *dic2 = @{
                           @"title" : @"密码",
                           @"info" : @"前往重置",
                           };
    NSDictionary *dic3 = @{
                           @"title" : @"手机",
                           @"info" : [WVRUserModel sharedInstance].mobileNumber ?: @"",
                           };
    [_itemViewArray addObject:dic0];
    [_itemViewArray addObject:dic1];
    [_itemViewArray addObject:dic2];
    [_itemViewArray addObject:dic3];
}

- (void)allocSubviews {
    
    /* Table View */
    _tableView = [[UITableView alloc] init];
    
    _thirdPartyLoginView = [[WVRThirdPartyLoginView alloc] init];
}

- (void)configSubviews {
    
    /* Table View */
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView registerClass:[WVRConfigCell class] forCellReuseIdentifier:__CELL_KEY];
    [_tableView registerClass:[WVRAvatarTableViewCell class] forCellReuseIdentifier:__AVATAR_CELL_KEY];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView.scrollEnabled = NO;
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    
    _thirdPartyLoginView.delegate = self;
    [_thirdPartyLoginView setTintText:@"第三方账户绑定"];
    [_thirdPartyLoginView setBottomTintLabelHidden];
    @weakify(self);
    [[RACObserve([WVRUserModel sharedInstance], username) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self updateNickName:[WVRUserModel sharedInstance].username];
    }];
    [self addSubview:_tableView];
    [self addSubview:_thirdPartyLoginView];
}

- (void)positionSubvies {
    
    CGRect tmpRect = CGRectZero;
    
//    if (0 == self.bounds.size.height) {
//        tmpRect = self.bounds;
//        [self setFrame:tmpRect];
//    }
    
//    tmpRect = [self centerRectInSubviewWithWidth:self.width height:self.height-kNavBarHeight toTop:0];
//    [_tableView setFrame:tmpRect];
    _tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    tmpRect = [self centerRectInSubviewWithView:_thirdPartyLoginView toBottom:0];
    [_thirdPartyLoginView setFrame:tmpRect];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self positionSubvies];
}

- (void)updateAvator {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:WVRUserInfoStyleAvatar inSection:0];
    WVRAvatarTableViewCell *nickNameCell = [_tableView cellForRowAtIndexPath:indexPath];
    
    [nickNameCell updateAvatar];
}

- (void)updateNickName:(NSString *)nick {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:WVRUserInfoStyleNickname inSection:0];
    WVRConfigCell *nickNameCell = [_tableView cellForRowAtIndexPath:indexPath];
    
    [nickNameCell updateInfo:nick];
    
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)updatePhoneNum:(NSString *) phoneNum {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:WVRUserInfoStylePhoneNum inSection:0];
    WVRConfigCell *nickNameCell = [_tableView cellForRowAtIndexPath:indexPath];
    
    [nickNameCell updateInfo:phoneNum];
    
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)updateStatusOfQQIcon:(BOOL) QQisBinded WBIcon:(BOOL) WBisBinded WXIcon:(BOOL) WXisBinded {
    
    [_thirdPartyLoginView updateStatusOfQQIcon:QQisBinded WBIcon:WBisBinded WXIcon:WXisBinded];
}

#pragma mark - WVRThirdPartyLoginViewDelegate
- (void)bindView:(WVRThirdPartyLoginView *)view buttonClickedAtIndex:(NSInteger)index {
    
    if ([_delegate respondsToSelector:@selector(bindView:buttonClickedAtIndex:)]) {
        [_delegate bindView:self buttonClickedAtIndex:index];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (0 == indexPath.row) {
        return 215/2;
    } else {
        return 69;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < 0 || indexPath.row >= _itemViewArray.count) {
        return;
    }

    if (3 == indexPath.row) {
        if (self.gotoChangePhoneBlock) {
            self.gotoChangePhoneBlock();
        }
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(bindView:buttonClickedAtIndex:)]) {
        [_delegate bindView:self buttonClickedAtIndex:indexPath.row];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _itemViewArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    if (indexPath.row < 0 || indexPath.row > _itemViewArray.count) {
        return [[UITableViewCell alloc] init];
    } else {
        if (0 == indexPath.row) {
            WVRAvatarTableViewCell *viewCell = [tableView dequeueReusableCellWithIdentifier:__AVATAR_CELL_KEY];
            if (viewCell == nil) {
                viewCell = [[WVRAvatarTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:__AVATAR_CELL_KEY];
            }
        
            NSDictionary *dic = (NSDictionary*)_itemViewArray[indexPath.row];
            
            [viewCell updateTitle:(NSString*)[dic objectForKey:@"title"]];
            [viewCell updateAvatar];
            
            cell = viewCell;
        }else{
            
            WVRConfigCell *viewCell = [tableView dequeueReusableCellWithIdentifier:__CELL_KEY];
            if (viewCell == nil) {
                viewCell = [[WVRConfigCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:__CELL_KEY];
            }
            
//            if (3 == indexPath.row) {
//                [viewCell hideGoinImage];
//            }
            
            NSDictionary *dic = (NSDictionary*)_itemViewArray[indexPath.row];
            
            [viewCell updateTitle:(NSString*)[dic objectForKey:@"title"] ];
            [viewCell updateInfo:(NSString*)[dic objectForKey:@"info"]];
            
            cell = viewCell;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

@end
