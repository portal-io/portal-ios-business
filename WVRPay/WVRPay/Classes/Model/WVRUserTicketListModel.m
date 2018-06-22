//
//  WVRUserTicketListModel.m
//  WhaleyVR
//
//  Created by Bruce on 2017/6/7.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRUserTicketListModel.h"

@implementation WVRUserTicketListModel

@end


@implementation WVRUserTicketItemModel
@synthesize cellHeight = _cellHeight;
@synthesize nameHeight = _nameHeight;


+ (NSArray *)modelPropertyBlacklist {
    
    return @[ @"cellHeight", @"nameHeight", ];
}

- (float)cellHeight {
    
    if (!_merchandiseName) {
        return adaptToWidth(85);
    }
    
    if (!_cellHeight) {
        
        UIFont *font = kFontFitForSize(16);
        NSString *defaultStr = @"兑换券";
        float tmpHeight = [WVRComputeTool sizeOfString:defaultStr Size:CGSizeMake(800, 800) Font:font].height;
        
        float screen_width = MIN(SCREEN_WIDTH, SCREEN_HEIGHT);
        float width = screen_width - 3 * adaptToWidth(10) - adaptToWidth(50);
        
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:_merchandiseName attributes:@{ NSFontAttributeName: font }];
        
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, _merchandiseName.length)];
        
        _nameHeight = [WVRComputeTool sizeOfString:attStr Size:CGSizeMake(width, 800)].height;
        
        _cellHeight = adaptToWidth(85) - tmpHeight + _nameHeight;
    }
    
    return _cellHeight;
}

@end


@implementation WVROrderListPage

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{ @"content" : [WVRUserTicketItemModel class], };
}

@end
