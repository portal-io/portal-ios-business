//
//  WVRDanmuListView.m
//  WhaleyVR
//
//  Created by Bruce on 2016/12/27.
//  Copyright © 2016年 Snailvr. All rights reserved.

// 直播相关控件类

#import "WVRDanmuListView.h"
#import "WVRComputeTool.h"
#import "WVRLiveAlertView.h"

#import "SQKeyboardTool.h"

#import "SQDateTool.h"
#import "WVRWebSocketMsg.h"
#import "UIColor+UIHexColor.h"
#import "WVRLabel.h"
#import "UIView+Extend.h"
#import "UIColor+Extend.h"
#import "WVRAppContextHeader.h"

#define MARGIN_DANM_CONTENT (adaptToWidth(5))

#define MARGIN_TOP_HEADERL (adaptToWidth(5))

@interface WVRDanmuListView ()<UITableViewDelegate, UITableViewDataSource> {
    
    NSDictionary *_bannedMessageDict;
}

@property (nonatomic, strong) NSMutableArray<WVRDanmuListCellInfo *> *dataSourceArr;

@property (nonatomic, weak) UILabel *noticeLabel;

@property (nonatomic) SQKeyboardTool * mKeyTool;

@property (nonatomic, strong) UIPanGestureRecognizer * mPanG;

@property (nonatomic, strong) UILabel * headerL;
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, strong) UIView * headerBgV;
//@property (nonatomic, strong) CAGradientLayer * headerBgLayer;

@property (nonatomic, strong) UITableView * listView;

@end


float kDanmuCellFontSize = 14.f;
float _gap = 10;


@implementation WVRDanmuListView

static NSString *const kDanmuListCellId = @"kDanmuListCellId";

#pragma mark - initialize

- (instancetype)init NS_UNAVAILABLE {
    
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame delegate:(id)delegate {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.realDelegate = delegate;
        
        [self buildData];
        [self configSelf];
        [self configSubViews];
    }
    return self;
}

- (void)buildData {
    
    self.dataSourceArr = [NSMutableArray array];
    if (!self.listView) {
        self.listView = [[UITableView alloc] initWithFrame:self.frame style:UITableViewStylePlain];
        self.listView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.listView];
    }
}

- (void)configSelf {
    if (!self.mKeyTool) {
        self.mKeyTool = [SQKeyboardTool new];
        [self.mKeyTool addKeyHandleWithOwner:self];
    }
    self.tag = 1;
    self.backgroundColor = [UIColor clearColor];
    
    self.listView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.listView.tableFooterView = [[UIView alloc] init];
    self.listView.delegate = self;
    self.listView.dataSource = self;
    self.listView.showsVerticalScrollIndicator = NO;
    if (!self.mPanG) {
        self.mPanG = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipeing:)];
    }
    [self addGestureRecognizer:self.mPanG];
}

- (void)configSubViews {
    
    [self.listView registerClass:[WVRDanmuListCell class] forCellReuseIdentifier:kDanmuListCellId];
    if (!self.headerBgV) {
        UIView * bgview = [[UIView alloc] initWithFrame:CGRectZero];
        bgview.layer.masksToBounds = YES;
        bgview.layer.cornerRadius = 8.f;
        bgview.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
        
        [self addSubview:bgview];
        self.headerBgV = bgview;
    }
    if (!self.headerL) {
        UILabel * label = [[WVRLabel alloc] initWithFrame:CGRectZero];
        label.numberOfLines = 0;
//        label.lineBreakMode = NSLineBreakByCharWrapping;
        
        label.textColor = [UIColor redColor];
        label.backgroundColor = [UIColor clearColor];
        [self addSubview:label];
        self.headerL = label;
    }
}

- (void)layoutSubviews {
    
//    self.listView.frame = CGRectMake(0, self.headerL.height, self.width, self.height-self.headerHeight);
    if (self.height < HEIGHT_DANMU_LIST_VIEW) {
        self.headerL.frame = CGRectMake(_gap, MARGIN_TOP_HEADERL, self.width - 2*_gap, self.headerHeight);
        self.headerBgV.frame = CGRectMake(_gap/2, 0, self.width - _gap, self.headerHeight + 2*MARGIN_TOP_HEADERL);;
//        self.headerBgLayer.frame = self.headerBgV.bounds;
        self.listView.frame = CGRectMake(0, self.headerHeight > 0? self.headerHeight + 2*MARGIN_TOP_HEADERL : 0, self.width, self.height - self.headerHeight-2*MARGIN_TOP_HEADERL);
    } else {
        self.listView.frame = CGRectMake(0, self.headerHeight>0? self.headerHeight+2*MARGIN_TOP_HEADERL:0, self.width, self.height-self.headerHeight-2*MARGIN_TOP_HEADERL);
        self.headerL.frame = CGRectMake(_gap, MARGIN_TOP_HEADERL, self.width-2*_gap, self.headerHeight);
        self.headerBgV.frame = CGRectMake(_gap/2, 0, self.width-_gap, self.headerHeight+2*MARGIN_TOP_HEADERL);;
//        self.headerBgLayer.frame = self.headerBgV.bounds;
    }
    if (self.headerHeight == 0) {
        self.headerBgV.height = 0;
    }
    self.headerBgV.layer.cornerRadius = 8;
}

- (void)createNoticeLabel {
    
}

#pragma mark - functions

- (void)addDanmuWithArray:(NSArray *)list {
    
    if (!self.isSwitchOn) { return; }
    if (nil == list) { return; }
    
    for (WVRWebSocketMsg *msg in list) {
        
        [self parserMsg:msg];
    }
    
    if (self.dataSourceArr.count > 300) {
        [self.dataSourceArr removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 100)]];
    }
//    if (self.hidden) { return; }    // 不显示则不刷新UI
    
    [self scrollTableViewToBottom:NO];
}

- (void)parserMsg:(WVRWebSocketMsg *)msg {
    
    NSString *content = msg.content;
    NSString *nickname = msg.senderNickName;
    UIFont *font = FONT(kDanmuCellFontSize);
    NSMutableAttributedString *attStr = nil;
    
    switch (msg.msgType) {
        case WVRwebSocketMsgTypeNormal:
            attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", nickname, content]];
            attStr.yy_color = [UIColor whiteColor];
            [attStr yy_setColor:[UIColor colorWithHex:0xF7D164] range:NSMakeRange(0, nickname.length)];
            
            break;
        case WVRwebSocketMsgTypeTop:
            [self updateHeadMsg:msg];
            return;
            break;
        case WVRwebSocketMsgTypeTopDismiss:
            [self clearTopMsg];
            return;
            break;
            
        case WVRwebSocketMsgTypeManager:
            attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", content]];
            attStr.yy_color = [UIColor colorWithHexString:msg.colorStr];
            break;
        case WVRwebSocketMsgTypeUserBannedProhibitedWords:
        case WVRwebSocketMsgTypeUserBannedUNProhibitedWords:
            nickname = [NSString stringWithFormat:@"%@ ", msg.userBannedMsg.nickname];
            if ([msg.userBannedMsg.userId isEqualToString:[WVRUserModel sharedInstance].showRoomUserID]) {
                nickname = @"你";
            }
            attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@", nickname, [self paserUserBannedMsg:msg.msgType],[self parserDuration:msg.userBannedMsg.duration]]];
            attStr.yy_color = [UIColor whiteColor];
            [attStr yy_setColor:[UIColor redColor] range:NSMakeRange(0, attStr.length)];
            break;
        case WVRwebSocketMsgTypeUserBannedBlacklist:
        case WVRwebSocketMsgTypeUserBannedUNBlacklist:
            if ([msg.userBannedMsg.userId isEqualToString:[WVRUserModel sharedInstance].showRoomUserID]) {
                nickname = @"你";
                attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", nickname, [self paserUserBannedMsg:msg.msgType]]];
                attStr.yy_color = [UIColor whiteColor];
                [attStr yy_setColor:[UIColor redColor] range:NSMakeRange(0, attStr.length)];
            }else{
                return;
            }
            
            break;
        default:
            break;
    }
    attStr.yy_font = font;
    
    WVRDanmuListCellInfo *info = [[WVRDanmuListCellInfo alloc] init];
    info.message = attStr;
    
    [self.dataSourceArr addObject:info];
}

- (NSString *)parserDuration:(NSString *)duration {
    
    NSInteger dur = [duration integerValue];
    NSInteger min = dur/60;
    NSString * durStr = min > 0 ? [NSString stringWithFormat:@"%ld分钟", min] : @"";
    
    return durStr;
}

- (NSString *)paserUserBannedMsg:(WVRwebSocketMsgType)type {
    
    NSDictionary * dic = [self bannedMessageDict];
    
    return dic[@(type)];
}

- (NSDictionary *)bannedMessageDict {
    if (!_bannedMessageDict) {
        _bannedMessageDict = @{
                               @(WVRwebSocketMsgTypeUserBannedProhibitedWords):@"已被管理员禁言",
                               @(WVRwebSocketMsgTypeUserBannedUNProhibitedWords):@"已被管理员取消禁言",
                               @(WVRwebSocketMsgTypeUserBannedBlacklist):@"已被管理员加入黑名单",
                               @(WVRwebSocketMsgTypeUserBannedUNBlacklist):@"已被管理员移出黑名单"
                               };
    }
    return _bannedMessageDict;
}

- (BOOL)isSwitchOn {
    
    return self.tag > 0;
}

- (void)setSwitchOn:(BOOL)isOn {
    
    self.tag = isOn ? 1 : 0;
    
    if (self.hidden) {
        return;
    }
//    if (isOn) { [self scrollTableViewToBottom:NO]; }
    
    self.hidden = !isOn;
}

- (void)scrollTableViewToBottom:(BOOL)animated {
    
    if (self.dataSourceArr.count == 0) { return; }
    
    dispatch_async(dispatch_get_main_queue(), ^{

        [self.listView reloadData];
        if (self.dataSourceArr.count < 2) {
            return;     // 消息个数小于2，就不用滚动scrollview
        }
        
        [UIView animateWithDuration:0.25 animations:^{
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataSourceArr.count - 1 inSection:0];
            [self.listView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
        }];
    });
}

#pragma mark - tabbleViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSourceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WVRDanmuListCell *cell = [tableView dequeueReusableCellWithIdentifier:kDanmuListCellId];
    cell.tag = indexPath.row;
    WVRDanmuListCellInfo *cellInfo = [self.dataSourceArr objectAtIndex:indexPath.row];
    cell.width = self.width;
    cell.cellInfo = cellInfo;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WVRDanmuListCellInfo *cellInfo = [self.dataSourceArr objectAtIndex:indexPath.row];
    return cellInfo.cellHeight;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return self.headerHeight;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    self.headerL.frame = CGRectMake(0, 0, tableView.width, self.headerHeight);
//    return self.headerL;
//}

- (void)updateHeadMsg:(WVRWebSocketMsg *)msg {
    
    NSString *content = msg.content;
    UIFont *font = BOLD_FONT(kDanmuCellFontSize);
//    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", content]];
    
//    attStr.yy_font = font;
//    attStr.yy_color = [UIColor colorWithHexString:msg.colorStr];
//    self.headerL.attributedText = attStr;
//    CGSize size = CGSizeMake(self.width - 2 * _gap, 800);
//    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:size text:attStr];
    
    self.headerL.font = font;
    self.headerL.textColor = [UIColor colorWithHexString:msg.colorStr];
    self.headerL.text = content;
    CGSize size = [WVRComputeTool sizeOfString:content Size:CGSizeMake(self.width - 2 * _gap, 800) Font:self.headerL.font];
    CGFloat height = size.height;
    self.headerHeight = MIN(height, self.height);
    self.headerBgV.hidden = NO;
    [self setNeedsLayout];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(clearTopMsg) withObject:nil afterDelay:[msg.msgStayDuration integerValue]];
//    [self.listView reloadData];
}

- (void)clearTopMsg {
    
    self.headerL.text = @"";
    self.headerBgV.hidden = YES;
    self.headerL.height = 0;
    self.headerHeight = 0;
    [self setNeedsDisplay];
    [self scrollTableViewToBottom:YES];
    
}
//static CGFloat offsetY = 0.0;

- (void)swipeing:(UIPanGestureRecognizer *)panG {
    
    int scale = 2;
    CGPoint point = [panG translationInView:self];
    NSLog(@"yOffset%f", point.y);
//    if (fabs(offsetY - point.y) > 30) {
//        return;
//    }
    [self.realDelegate actionPanGustrue:(point.x * scale) Y:(point.y * scale)];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
//        CGPoint point = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:self];
//        NSLog(@"yOffset start:%f",point.y);
//        offsetY = point.y;
        [self.realDelegate actionTouchesBegan];
    }
    return YES;
}

@end


@implementation WVRDanmuListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
//        self.width = MIN(SCREEN_WIDTH, SCREEN_HEIGHT);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self contentLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentLabel.frame = CGRectMake(_gap, 0, self.width - 2*_gap, self.height);
}

- (YYLabel *)contentLabel {
    if (!_contentLabel) {
        
        YYLabel *label = [[YYLabel alloc] initWithFrame:CGRectMake(_gap, 0, self.width - 2*_gap, self.height)];
        label.backgroundColor = [UIColor clearColor];
        label.font = kFontFitForSize(kDanmuCellFontSize);
        label.numberOfLines = 3;
        label.lineBreakMode = NSLineBreakByCharWrapping;
        
        label.layer.shadowColor = [UIColor blackColor].CGColor;
        label.layer.shadowOpacity = 0.5;
        label.layer.shadowRadius = 1;
        label.layer.shadowOffset = CGSizeMake(1, 1);
        
        [self addSubview:label];
        
        _contentLabel = label;
    }
    return _contentLabel;
}

- (void)setCellInfo:(WVRDanmuListCellInfo *)cellInfo {
    
    self.contentLabel.height = cellInfo.cellHeight;
    self.contentLabel.attributedText = cellInfo.message;
}

@end


@implementation WVRDanmuListCellInfo

- (CGFloat)cellHeight {
    if (_cellHeight <= 0) {
        
        CGSize size = CGSizeMake(WIDTH_DANMU_VIEW - 2 * adaptToWidth(10), 800);
        YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:size text:_message];
        
        _cellHeight = layout.textBoundingSize.height;
        if (_cellHeight > 0) {
            _cellHeight = _cellHeight + MARGIN_DANM_CONTENT;
        }
    }
    return _cellHeight;
}

@end

