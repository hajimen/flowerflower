//
//  AlertNewContent.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/25.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "AlertNewContent.h"

@implementation AlertNewContent

-(void)showWithMessage:(NSString *)message {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Arrived", nil) message: message delegate: nil cancelButtonTitle: NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    [av show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
}

@end
