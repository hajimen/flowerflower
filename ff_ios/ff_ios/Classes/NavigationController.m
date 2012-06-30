//
//  NavigationController.m
//  ff_ios
//
//  Created by NAKAZATO Hajime on 12/06/28.
//  Copyright (c) 2012年 Nishizaike Kaoriha. All rights reserved.
//

#import "NavigationController.h"

@interface NavigationController ()

@end

@implementation NavigationController

@synthesize initialInterfaceOrientation;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([self isAutoRotateEnabled]) {
        return YES;
    }
    return (interfaceOrientation == self.initialInterfaceOrientation);
}

-(BOOL) isAutoRotateEnabled {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"autoRotateSwitch"];
}

- (void)didRotateFromInterfaceOrientation: (UIInterfaceOrientation)fromInterfaceOrientation {
    self.initialInterfaceOrientation = self.interfaceOrientation;
}

@end
