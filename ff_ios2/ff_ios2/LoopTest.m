//
//  LoopTest.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/05.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "LoopTest.h"
#import "TitleCell.h"
#import "TagContainerView.h"

@implementation LoopTest

-(void)loop {
    for (int i = 0; i < 1; i ++) {
        CGRect r = CGRectMake(0, 0, 250, 150);
        NSMutableArray *a = [NSMutableArray arrayWithCapacity:1000];
        NSLog(@"inner start");
        for (int k = 0; k < 3; k ++) {
//            TagContainerView *tcv = [[TagContainerView alloc]initWithFrame:r];
//            [a addObject:tcv];
            TitleCell *c = [[TitleCell alloc] initWithFrame:r];
            [a addObject:c];
//            NSString *s = [NSString stringWithFormat:@"%d", k];
//            [a addObject:s];
        }
    }
}

@end
