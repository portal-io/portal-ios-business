//
//  WVRHistoryCell.m
//  WhaleyVR
//
//  Created by qbshen on 2017/3/29.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRHistoryCell.h"
#import "WVRHistoryModel.h"

@interface WVRHistoryCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconTopCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconBottomCons;
@property (weak, nonatomic) IBOutlet UIImageView *iconV;
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *subTitleL;
@property (nonatomic, strong) WVRHistoryCellInfo * cellInfo;

@end


@implementation WVRHistoryCell


- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
}

- (void)fillData:(SQBaseTableViewInfo *)info
{
    self.cellInfo = (WVRHistoryCellInfo*)info;
    [self.iconV wvr_setImageWithURL:[NSURL URLWithString:[info.args thubImageUrl]] placeholderImage:HOLDER_IMAGE];
    if (info.indexPath.row == 0) {
        
        self.iconTopCons.constant = 0;
    } else {
        self.iconTopCons.constant = fitToWidth(10.f);
    }
//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[info.args programName]];
//    
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    
//    [paragraphStyle setLineSpacing:2.0f];//调整行间距
//    
//    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [[info.args programName] length])];
//    
//    self.titleL.attributedText = attributedString;
//    
//    [self.titleL sizeToFit];
    float progress = 1;
    if ([[info.args totalPlayTime] floatValue] >0 && [[info.args totalPlayTime] floatValue] >= [[info.args playTime] floatValue]) {
        progress = [[info.args playTime] floatValue]/[[info.args totalPlayTime] floatValue]*100;
        if (progress < 1) {
            progress = 1;
        }
    }else{
        progress = 1;
    }
    
    if([[info.args programType] isEqualToString:PROGRAMTYPE_RECORDED]||[[info.args programType] isEqualToString:PROGRAMTYPE_MORETV_MOVIE]){
        self.titleL.text = [info.args programName];
        if (progress >= 99) {
            self.subTitleL.text = [NSString stringWithFormat:@"已看完"];
        }else{
            self.subTitleL.text = [NSString stringWithFormat:@"已看至%.f%@",progress,@"%"];
        }
    }else{
        NSString * curE = [info.args curEpisode];
        int testNum = [curE intValue];
        self.titleL.text = [[[info.args programName] componentsSeparatedByString:@"["] firstObject];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        
        formatter.numberStyle = kCFNumberFormatterRoundHalfDown;
        
        NSString *string = [formatter stringFromNumber:[NSNumber numberWithInt: testNum]];
        if (progress == 100) {
            self.subTitleL.text = [NSString stringWithFormat:@"第%@集 已看完",string];
        }else{
            self.subTitleL.text = [NSString stringWithFormat:@"第%@集 已看至%.f%@",string,progress,@"%"];
        }
        
    }
}

- (void)didHighlight
{
    
}

- (void)didUnhighlight
{
    
}
@end
@implementation WVRHistoryCellInfo

@end
