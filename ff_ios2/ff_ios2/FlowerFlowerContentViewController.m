//
//  FlowerFlowerContentViewController.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/20.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "FlowerFlowerContentViewController.h"
#import "ScaleChanger.h"
#import "UserDefaultsKey.h"

@interface FlowerFlowerContentViewController () {
    BOOL settingsChanged;
}

@end

@implementation FlowerFlowerContentViewController

-(id)init {
    self = [super init];
    if (!self) {
        return self;
    }

    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(userDefaultChanged) name: NSUserDefaultsDidChangeNotification object: nil];

    settingsChanged = NO;

    return self;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

-(BOOL)shouldAutorotate {
    return [[NSUserDefaults standardUserDefaults] boolForKey: UDK_AUTO_ROTATE_SWITCH];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return [self shouldAutorotate];
}

-(void)userDefaultChanged {
    settingsChanged = YES;
}

-(void)syncSettings {
    if (settingsChanged) {
        [self scaleChanged];
        settingsChanged = NO;
    }
}

- (void)didRotateFromInterfaceOrientation: (UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    [self.webView stringByEvaluatingJavaScriptFromString:
     [NSString stringWithFormat:
      @"document.querySelector('meta[name=viewport]').setAttribute('content', 'width=%d;', false); ",
      (int)self.webView.frame.size.width]];
    [self scaleChanged];
}

-(void)scaleChanged {
    [(ScaleChanger *)[self getCommandInstance:@"org.kaoriha.phonegap.plugins.scalechanger"] scaleChanged];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end
