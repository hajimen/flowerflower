//
//  TitleCollectionViewLayout.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/03/22.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "TitleCollectionViewLayout.h"
#import "TitleCollectionViewController.h"
#import "TitleCell.h"
#import "TitleCollectionViewLayoutAttributes.h"

@interface TitleCollectionViewLayout ()

@property (nonatomic, assign) NSInteger itemsPerRow;

@end

@implementation TitleCollectionViewLayout

-(void)prepareLayout {
    if (self.collectionView.bounds.size.width > 1000) {
        self.itemsPerRow = 3;
    } else {
        self.itemsPerRow = 2;
    }
    CGFloat itemWidth = (self.collectionView.bounds.size.width - 10 * (self.itemsPerRow - 1)) / self.itemsPerRow;
    self.itemSize = CGSizeMake(itemWidth, 200);
    self.minimumLineSpacing = 50;
    self.minimumInteritemSpacing = 10;

    [super prepareLayout];
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attrs = [super layoutAttributesForElementsInRect:rect];

    for (TitleCollectionViewLayoutAttributes *attr in attrs) {
        attr.row = attr.indexPath.item / self.itemsPerRow;
    }
    
    return attrs;
}

+(Class)layoutAttributesClass {
    return [TitleCollectionViewLayoutAttributes class];
}

@end
