//
//  Cell.m
//  PSPDFKit
//
//  Copyright (c) 2012 Peter Steinberger. All rights reserved.
//

#import "TitleCell.h"
#import "TitleCollectionViewLayoutAttributes.h"
#import "UIImage+Resize.h"

#define LEFT_VIEW_WIDTH 50.0
#define RIGHT_VIEW_WIDTH 50.0

@interface TitleCell ()

@property (nonatomic) UIView *leftView;
@property (nonatomic) UIView *middleView;
@property (nonatomic) UIView *rightView;

@end

@implementation TitleCell

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        CGFloat height = frame.size.height;
        CGFloat width = frame.size.width;

        _leftView = [[UIView alloc] initWithFrame: CGRectMake(0.0, 0.0, LEFT_VIEW_WIDTH, height)];
        _leftView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        _leftView.backgroundColor = [UIColor blueColor];
        
        UIImage *img = [UIImage imageNamed:@"test_image.png"];
        UIImageView *imgView = [[UIImageView alloc] initWithImage: [img resizedImageToFitInSize:CGSizeMake(LEFT_VIEW_WIDTH, height) scaleIfSmaller:YES]];
        [_leftView addSubview: imgView];
        
        _middleView = [[UIView alloc] initWithFrame: CGRectMake(LEFT_VIEW_WIDTH, 0.0, width - LEFT_VIEW_WIDTH - RIGHT_VIEW_WIDTH, height)];
        _middleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        _rightView = [[UIView alloc] initWithFrame: CGRectMake(width - RIGHT_VIEW_WIDTH, 0.0, RIGHT_VIEW_WIDTH, height)];
        _rightView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        _rightView.backgroundColor = [UIColor yellowColor];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _middleView.frame.size.width, _middleView.frame.size.height)];
        label.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:50.0];
        label.textColor = [UIColor blackColor];
        label.text = @"test";
        
        [_middleView addSubview: label];
        [self.contentView addSubview: _leftView];
        [self.contentView addSubview: _middleView];
        [self.contentView addSubview: _rightView];

        _label = label;
    }
    return self;
}

-(void)applyLayoutAttributes:(PSTCollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    
    TitleCollectionViewLayoutAttributes *attr = (TitleCollectionViewLayoutAttributes *) layoutAttributes;

    if (attr.row % 2 == 1) {
        self.label.backgroundColor = [UIColor whiteColor];
    } else {
        self.label.backgroundColor = [UIColor redColor];
    }
}

@end
