//
//  AlertAuthError.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/15.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "AlertAuthError.h"
#import "PurchaseManager.h"

@implementation AlertAuthError

-(void)showWithUrl:(NSURL *)url {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Auth Error", nil) message: NSLocalizedString(@"Distribution server auth error. Please restore your purchase.", nil) delegate: self cancelButtonTitle: NSLocalizedString(@"Cancel", nil) otherButtonTitles: NSLocalizedString(@"Restore Now", nil), nil];
    [av show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [[PurchaseManager instance] restore];
}

@end
