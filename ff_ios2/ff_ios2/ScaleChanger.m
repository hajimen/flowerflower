//
//  ScaleChanger.m
//  ff_ios
//
//  Created by NAKAZATO Hajime on 12/06/28.
//  Copyright 2011 Nishizaike Kaoriha. All rights reserved.
//

#import "ScaleChanger.h"
#import "GTMStringEncoding.h"
#import "AppDelegate.h"
#import "JSONKit.h"
#import <math.h>
#import "UserDefaultsKey.h"

@implementation ScaleChanger

- (void)ready:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float rawScale = pow(1.3, [defaults floatForKey: UDK_SCALE_SLIDER] * 2.0 - 1.0);
    int fontSize = (int) lround(rawScale * 16.0);
    if (fontSize == 16) {
        return;
    }
    [self scaleChanged];
}

- (void) scaleChanged {
    if (((int)self.viewController.view.frame.size.width) == 0) {
        return;
    }

    NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
    CGFloat realWidth = self.viewController.view.frame.size.width;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float rawScale = pow(1.3, [defaults floatForKey: UDK_SCALE_SLIDER] * 2.0 - 1.0);

    int fontSize = (int) lround(rawScale * 16.0);
    float realEmWidth = realWidth / fontSize;
    int emWidth;
    if (realEmWidth < 16.0) {
        emWidth = 14;
    } else if (realEmWidth < 18.0) {
        emWidth = 16;
    } else if (realEmWidth < 20.0) {
        emWidth = 18;
    } else if (realEmWidth < 23.0) {
        emWidth = 20;
    } else if (realEmWidth < 25.0) {
        emWidth = 23;
    } else if (realEmWidth < 30.0) {
        emWidth = 25;
    } else if (realEmWidth < 34.0) {
        emWidth = 30;
    } else if (realEmWidth < 38.0) {
        emWidth = 34;
    } else if (realEmWidth < 42.0) {
        emWidth = 38;
    } else if (realEmWidth < 56.0) {
        emWidth = 42;
    } else {
        emWidth = 56;
    }

    int width = emWidth * 16;
    float middleScale = floorf(realWidth * 100.0 / width) / 100.0;
    
    NSString *scaleStr = [NSString stringWithFormat:@"%.2f", middleScale];

    [args setObject: [NSString stringWithFormat:@"%d", width] forKey:@"width"];
    [args setObject: scaleStr forKey:@"scale"];

    NSString* s = [args JSONString];
    [self.commandDelegate evalJs: [NSString stringWithFormat:@"ScaleChangedFireEvent(%@);", s]];

}

@end
