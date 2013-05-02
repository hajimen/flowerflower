//
//  AlertStorageStavation.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/22.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "AlertStorageStavation.h"

@implementation AlertStorageStavation

-(void)show {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Storage Stavation", nil) message: NSLocalizedString(@"Storage stavation. Please uninstall this app, make storage space, and reinstall this app.", nil) delegate: self cancelButtonTitle: NSLocalizedString(@"Close", nil) otherButtonTitles: nil];
    [av show];
}

@end
