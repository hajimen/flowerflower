//
//  TagContainerView.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/03.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "TagContainerView.h"
#import "RoundedLabel.h"

#define V_MARGIN 4.0
#define H_MARGIN 4.0
#define FONT_SIZE 12.0

@interface TagContainerView ()

@property (nonatomic) NSArray *tagLabels;

@end

@implementation TagContainerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return self;
    }

    _tagLabels = @[];
    
    return self;
}

-(void)setTags:(NSArray *)tags {
    NSMutableArray *tls = [NSMutableArray arrayWithCapacity:[tags count]];
    
    for (NSString *tag in tags) {
        UILabel *tagLabel = [[RoundedLabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 100, 20)];
        tagLabel.font = [UIFont systemFontOfSize: FONT_SIZE];
        tagLabel.textColor = [UIColor blackColor];
        tagLabel.textAlignment = UITextAlignmentCenter;
        tagLabel.text = tag;
        [tagLabel sizeToFit];
        CGRect f = tagLabel.frame;
        f.size.width += FONT_SIZE;
        tagLabel.frame = f;
        [self addSubview: tagLabel];
        [tls addObject: tagLabel];
    }
    _tagLabels = tls;

    [self setNeedsLayout];
}

-(void)layoutTagLabels {
    CGFloat frameWidth = self.frame.size.width;
    CGFloat frameHeight = self.frame.size.height;
    CGFloat x = 0.0;
    CGFloat y = 0.0;
    BOOL overflow = NO;
    for (UILabel *tagLabel in _tagLabels) {
        if (overflow) {
            tagLabel.hidden = YES;
            continue;
        } else {
            tagLabel.hidden = NO;
        }
        CGSize size = tagLabel.frame.size;
        if (x + size.width > frameWidth) {
            x = 0.0;
            y += size.height + V_MARGIN;
        }
        if (y + size.height > frameHeight) {
            overflow = YES;
            tagLabel.hidden = YES;
            continue;
        }
        CGRect r = tagLabel.frame;
        r.origin.x = x;
        r.origin.y = y;
        tagLabel.frame = r;
        x += size.width + H_MARGIN;
    }
}

- (void)layoutSubviews
{
    [self layoutTagLabels];
    [super layoutSubviews];
}

@end
