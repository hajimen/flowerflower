//
//  ScrollableViewController.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/18.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "ScrollableViewController.h"

@interface ScrollableViewController ()

@end

@implementation ScrollableViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview: self.contentView];
    CGRect pf = self.view.frame;
    CGRect sf = self.contentView.frame;
    self.contentView.frame = CGRectMake(sf.origin.x, sf.origin.y, pf.size.width, sf.size.height);
    ((UIScrollView *)self.view).contentSize = self.contentView.frame.size;
}

-(void)viewDidUnload {
    self.contentView = nil;
    [super viewDidUnload];
}

@end
