//
//  TitleCollectionViewLayoutAttributes.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/03/22.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "TitleCollectionViewLayoutAttributes.h"

@implementation TitleCollectionViewLayoutAttributes

- (id)copyWithZone:(NSZone *)zone {
    TitleCollectionViewLayoutAttributes *layoutAttributes = [super copyWithZone:zone];
    layoutAttributes.row = self.row;

    return layoutAttributes;
}

@end
