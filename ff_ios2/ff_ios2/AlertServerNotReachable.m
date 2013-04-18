//
//  AlertServerDisconnected.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/15.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "Reachability.h"
#import "AlertServerNotReachable.h"

@implementation AlertServerNotReachable

-(void)show {
    Reachability *r = [Reachability reachabilityForInternetConnection];
    if (![r isReachable]) {
        NSLog(@"AlertServerDisconnected show called but no internet connection.");
        return;
    }	
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Distribution Server Down", nil) message: NSLocalizedString(@"Couldn't connect to distribution server. Please wait until recovery.", nil) delegate: self cancelButtonTitle: NSLocalizedString(@"Close", nil) otherButtonTitles: nil];
    [av show];
}

@end
