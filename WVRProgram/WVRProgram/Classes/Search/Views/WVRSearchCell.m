//
//  WVRSearchCell.m
//  WhaleyVR
//
//  Created by qbshen on 2017/1/9.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRSearchCell.h"
#import "SQDateTool.h"

@interface WVRSearchCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconIV;
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *subTitleL;

@end
@implementation WVRSearchCell

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.titleL.font = kFontFitForSize(13.5f);
    self.subTitleL.font = kFontFitForSize(11.5f);
    
}

-(void)fillData:(SQBaseTableViewInfo *)info
{
    WVRSearchCellInfo * cellInfo = (WVRSearchCellInfo*) info;
    [self.iconIV wvr_setImageWithURL:[NSURL URLWithString:cellInfo.itemModel.thubImageUrl] placeholderImage:HOLDER_IMAGE];
    self.titleL.text = cellInfo.itemModel.name;
//    NSString * playCountStr = cellInfo.itemModel.playCount? cellInfo.itemModel.playCount:@"0";
    self.subTitleL.text = cellInfo.itemModel.intrDesc;//[NSString stringWithFormat:@"%@次播放",playCountStr];
}

@end

@implementation WVRSearchCellInfo

@end
