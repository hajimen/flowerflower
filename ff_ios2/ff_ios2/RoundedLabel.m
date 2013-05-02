//
//  RoundedLabel.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/02.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RoundedLabel.h"

@implementation RoundedLabel

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if (self) {
        [self roundInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self roundInit];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)roundInit {
    CALayer *layer = self.layer;
    layer.cornerRadius = 6.0f;
    layer.masksToBounds = YES;
}

@end
