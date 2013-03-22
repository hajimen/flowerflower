//
//  Cell.m
//  PSPDFKit
//
//  Copyright (c) 2012 Peter Steinberger. All rights reserved.
//

#import "TitleCell.h"
#import "TitleCollectionViewLayoutAttributes.h"

@implementation TitleCell

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        label.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:50.0];
//        label.backgroundColor = [UIColor redColor];
        label.textColor = [UIColor blackColor];
        label.text = @"test";
        [self.contentView addSubview:label];
        _label = label;
    }
    return self;
}

-(void)applyLayoutAttributes:(PSUICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    
    TitleCollectionViewLayoutAttributes *attr = (TitleCollectionViewLayoutAttributes *) layoutAttributes;

    if (attr.row % 2 == 1) {
        self.label.backgroundColor = [UIColor whiteColor];
    } else {
        self.label.backgroundColor = [UIColor redColor];
    }
}

@end
