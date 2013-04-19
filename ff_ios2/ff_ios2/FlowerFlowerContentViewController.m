//
//  FlowerFlowerContentViewController.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/20.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "FlowerFlowerContentViewController.h"
#import "ScaleChanger.h"

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

-(void)userDefaultChanged {
    settingsChanged = YES;
}

-(void)syncSettings {
    if (settingsChanged) {
        ScaleChanger *sc = [self getCommandInstance:@"org.kaoriha.phonegap.plugins.scalechanger"];
        [sc scaleChanged];
        settingsChanged = NO;
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end
