//
//  WVRSQClassifyCell.m
//  WhaleyVR
//
//  Created by qbshen on 16/11/11.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRSQClassifyCell.h"
#import "WVRImageTool.h"

@interface WVRSQClassifyCell ()
@property (weak, nonatomic) IBOutlet UIImageView *thumIcon;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *introL;

@property (nonatomic) WVRSQClassifyCellInfo * cellInfo;

@end
@implementation WVRSQClassifyCell

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.nameL.font = kFontFitForSize(13.0f);
    self.introL.font = kFontFitForSize(11.0f);
}

-(void)fillData:(SQBaseCollectionViewInfo *)info
{
    self.cellInfo = (WVRSQClassifyCellInfo*)info;
    [self.thumIcon wvr_setImageWithURL:[NSURL URLWithString:[self parseImageUrl]] placeholderImage:HOLDER_IMAGE];
    self.nameL.text = self.cellInfo.videoModel.name;
    self.introL.text = self.cellInfo.videoModel.subTitle;
}

-(NSString*)parseImageUrl
{
    if (self.cellInfo.videoModel.scaleThubImage) {
        
    }else{
        self.cellInfo.videoModel.scaleThubImage = [WVRImageTool parseImageUrl:self.cellInfo.videoModel.thubImage scaleSize:self.thumIcon.size];
    }
    return self.cellInfo.videoModel.scaleThubImage;
}

@end
@implementation WVRSQClassifyCellInfo

@end
