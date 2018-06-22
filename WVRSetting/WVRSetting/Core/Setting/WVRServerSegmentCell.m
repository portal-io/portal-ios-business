//
//  WVRServerSegmentCell.m
//  WhaleyVR
//
//  Created by qbshen on 2016/12/1.
//  Copyright © 2016年 Snailvr. All rights reserved.
//

#import "WVRServerSegmentCell.h"

@interface WVRServerSegmentCell ()

- (IBAction)segmentOnClick:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentV;
@property (nonatomic) WVRServerSegmentCellInfo * cellInfo;

@end


@implementation WVRServerSegmentCell

- (void)awakeFromNib
{
    [super awakeFromNib];

}

- (void)fillData:(SQBaseTableViewInfo *)info
{
    self.cellInfo = (WVRServerSegmentCellInfo *)info;
    self.textLabel.text = @"切换服务器";
    self.segmentV.selectedSegmentIndex = [WVRUserModel sharedInstance].isTest;
}

- (IBAction)segmentOnClick:(UISegmentedControl*)sender {
    if (sender.selectedSegmentIndex==0) {
        if (self.cellInfo.onLineBlock) {
            self.cellInfo.onLineBlock();
        }
    }else{
        if (self.cellInfo.onTestBlock) {
            self.cellInfo.onTestBlock();
        }
    }
}
@end


@implementation WVRServerSegmentCellInfo

@end
