//
//  Cell.m
//  PSPDFKit
//
//  Copyright (c) 2012 Peter Steinberger. All rights reserved.
//

#import "TitleCell.h"
#import "TitleCollectionViewLayoutAttributes.h"
#import "UIImage+Resize.h"
#import "RoundedLabel.h"

#define LEFT_VIEW_WIDTH 77.0
#define IMAGE_WIDTH 64.0
#define MARGIN_X 9
#define MARGIN_Y 14
#define RIGHT_VIEW_WIDTH 50.0

@interface TitleCell ()

@property (nonatomic) UIView *leftView;
@property (nonatomic) UIView *middleView;
@property (nonatomic) UIView *rightView;

@end

@implementation TitleCell

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        CGFloat height = frame.size.height - MARGIN_Y * 2;
        CGFloat width = frame.size.width;

        _leftView = [[UIView alloc] initWithFrame: CGRectMake(MARGIN_X, MARGIN_Y, LEFT_VIEW_WIDTH - MARGIN_X, height)];
        _leftView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        _leftView.backgroundColor = [UIColor blueColor];
        
        UIImage *img = [UIImage imageNamed:@"test_image.png"];
        UIImageView *imgView = [[UIImageView alloc] initWithImage: [img resizedImageToFitInSize:CGSizeMake(IMAGE_WIDTH, height) scaleIfSmaller:YES]];
        [_leftView addSubview: imgView];
        
        _middleView = [[UIView alloc] initWithFrame: CGRectMake(LEFT_VIEW_WIDTH, MARGIN_Y, width - LEFT_VIEW_WIDTH - RIGHT_VIEW_WIDTH - MARGIN_X * 2, height)];
        _middleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        _rightView = [[UIView alloc] initWithFrame: CGRectMake(width - RIGHT_VIEW_WIDTH - MARGIN_X, MARGIN_Y, RIGHT_VIEW_WIDTH - MARGIN_X, height)];
        _rightView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        _rightView.backgroundColor = [UIColor yellowColor];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _middleView.frame.size.width, _middleView.frame.size.height)];
        label.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:50.0];
        label.textColor = [UIColor blackColor];
        label.text = @"test";
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(4.0, 0.0, _middleView.frame.size.width - 8.0, 40)];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.numberOfLines = 0;
        titleLabel.lineBreakMode = UILineBreakModeCharacterWrap;
        titleLabel.text = @"東京特許許可局";
        [_middleView addSubview: titleLabel];
        
        UILabel *tagLabel = [[RoundedLabel alloc] initWithFrame:CGRectMake(4.0, 44.0, _middleView.frame.size.width - 8.0, height)];
        tagLabel.font = [UIFont systemFontOfSize:12.0];
        tagLabel.textColor = [UIColor blackColor];
        tagLabel.textAlignment = UITextAlignmentCenter;
        tagLabel.text = @"TAG";
        [tagLabel sizeToFit];
        CGRect f = tagLabel.frame;
        f.size.width += 12.0;
        tagLabel.frame = f;
        [_middleView addSubview: tagLabel];
        
        // [_middleView addSubview: label];
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
        self.contentView.backgroundColor = [UIColor whiteColor];
    } else {
        self.contentView.backgroundColor = [UIColor redColor];
    }
}

@end
