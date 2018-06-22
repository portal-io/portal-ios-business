//
//  WVRManualArrangeShareViewSection.m
//  WhaleyVR
//
//  Created by qbshen on 17/4/13.
//  Copyright © 2017年 Snailvr. All rights reserved.
//

#import "WVRManualArrangeShareViewSection.h"
#import "WVRSectionModel.h"
#import "WVRSQTagHorCell.h"
#import "WVRManualAShareCell.h"
#import "WVRManualArrangeShareHeader.h"

@implementation WVRManualArrangeShareViewSection
@section(([NSString stringWithFormat:@"%d",(int)WVRSectionModelTypeManualArrangeShare]), NSStringFromClass([WVRManualArrangeShareViewSection class]))

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
    NSArray* allCellClass = @[[WVRSQTagHorCell class]];
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


- (WVRBaseViewSection *)getSectionInfo:(WVRSectionModel *)sectionModel
{    
    NSMutableArray * cellInfos = [NSMutableArray array];
    WVRSQTagHorCellInfo * tagCellInfo = [WVRSQTagHorCellInfo new];
    tagCellInfo.cellNibName = NSStringFromClass([WVRSQTagHorCell class]);
    tagCellInfo.cellSize = CGSizeMake(SCREEN_WIDTH, fitToWidth(191.f));
    tagCellInfo.originDic = [self getSubTagCollectionDic:sectionModel];
    tagCellInfo.cellNibNames = [self getSubTagCollectionCellNibNames];
    tagCellInfo.headerNibNames = [self getSubTagCollectionHeaderNibNames];
    tagCellInfo.noSplitV = YES;
    [cellInfos addObject:tagCellInfo];
    self.cellDataArray = cellInfos;
    
    return self;
}

- (NSDictionary*)getSubTagCollectionDic:(WVRSectionModel*)sectionModel
{
    NSMutableDictionary * originDic = [NSMutableDictionary dictionary];
    originDic[@(0)] = [self getSubTagSectionInfo:sectionModel];
    return originDic;
}

- (NSArray*)getSubTagCollectionCellNibNames
{
    return @[NSStringFromClass([WVRManualAShareCell class])];
}

- (NSArray*)getSubTagCollectionHeaderNibNames
{
    return @[NSStringFromClass([WVRManualArrangeShareHeader class])];
}

- (SQCollectionViewSectionInfo*)getSubTagSectionInfo:(WVRSectionModel*)sectionModel
{
    
    SQCollectionViewSectionInfo * sectionInfo = [SQCollectionViewSectionInfo new];
    sectionInfo.edgeInsets = UIEdgeInsetsMake(fitToWidth(0), fitToWidth(20), fitToWidth(0), fitToWidth(20));
    SQCollectionViewHeaderInfo * headerInfo = [SQCollectionViewHeaderInfo new];
    headerInfo.cellNibName = NSStringFromClass([WVRManualArrangeShareHeader class]);
    headerInfo.cellSize = CGSizeMake(SCREEN_WIDTH, fitToWidth(91.f));
    sectionInfo.headerInfo = headerInfo;
    NSMutableArray * cellInfos = [NSMutableArray array];
    for (WVRItemModel* model in [sectionModel.itemModels objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, MIN(5, sectionModel.itemModels.count))]]) {
        
        [cellInfos addObject:[self getTagCellInfo:model]];
    }
    sectionInfo.cellDataArray = cellInfos;
    return sectionInfo;
}

- (WVRManualAShareCellInfo*)getTagCellInfo:(WVRItemModel* )model
{
//    kWeakSelf(self);
    WVRManualAShareCellInfo * tagCellInfo = [WVRManualAShareCellInfo new];
    tagCellInfo.cellNibName = NSStringFromClass([WVRManualAShareCell class]);
    tagCellInfo.cellSize = CGSizeMake((SCREEN_WIDTH-fitToWidth(20.f)*2)/5, fitToWidth(85.f));
    tagCellInfo.title = model.name;
    tagCellInfo.localImageStr = model.thubImageUrl;
    
    tagCellInfo.gotoNextBlock = ^(WVRManualAShareCellInfo* args){
        [[NSNotificationCenter defaultCenter] postNotificationName:NAME_NOTF_MANUAL_ARRANGE_SHARE object:model.thubImageUrl];
    };
    return tagCellInfo;
}



@end
