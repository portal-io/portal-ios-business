//
//  WVRFootballReviewViewSection.m
//  WhaleyVR
//
//  Created by qbshen on 2017/5/16.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRFootballReviewViewSection.h"
#import "WVRSectionModel.h"
#import "WVRFootballModel.h"
#import "WVRFootballRecordCell.h"
#import "WVRBIModel.h"
//#import "WVRLoginTool.h"
#import "WVRSQFindSplitCell.h"

@implementation WVRFootballReviewViewSection

@section(([NSString stringWithFormat:@"%d",(int)WVRSectionModelTypeFootballRecord]), NSStringFromClass([WVRFootballReviewViewSection class]))

-(instancetype)init
{
    self = [super init];
    if (self) {
//        [self registerNibForCollectionView:self.collectionView];
    }
    return self;
}

- (void)registerNibForCollectionView:(UICollectionView*)collectionView
{
    [super registerNibForCollectionView:collectionView];
    NSArray* allCellClass = @[[WVRFootballRecordCell class], [WVRSQFindSplitCell class]];
    NSArray* allHeaderClass = @[];
    
    for (Class class in allCellClass) {
        NSString * name = NSStringFromClass(class);
        [collectionView registerNib:[UINib nibWithNibName:name bundle:nil] forCellWithReuseIdentifier:name];
    }
    
    for (Class class in allHeaderClass) {
        NSString * name = NSStringFromClass(class);
        [collectionView registerNib:[UINib nibWithNibName:name bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:name];
    }
}


- (WVRCollectionViewSectionInfo*)getSectionInfo:(WVRSectionModel*)sectionModel
{
    NSMutableArray * cellInfos = [NSMutableArray array];
    for (WVRFootballModel* model in sectionModel.itemModels) {
        if ([model.type isEqualToString:@"1"]) {
            continue;
        }
        [self addCellInfoTo:cellInfos withModel:model];
    }
    
    self.cellDataArray = cellInfos;
    
    return self;
}

- (void)addCellInfoTo:(NSMutableArray *)cellInfos withModel:(WVRFootballModel *)model {
    
    kWeakSelf(self);
    WVRFootballRecordCellInfo * cellInfo = [WVRFootballRecordCellInfo new];
    cellInfo.cellNibName = NSStringFromClass([WVRFootballRecordCell class]);
    cellInfo.cellSize = CGSizeMake(SCREEN_WIDTH, fitToWidth(266.f));
    cellInfo.gotoNextBlock = ^(id args) {
        [weakself gotoDetail:model];
    };
    cellInfo.itemModel = model;
    [cellInfos addObject:cellInfo];
}

@end
