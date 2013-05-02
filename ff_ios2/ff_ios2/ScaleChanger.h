//
//  ScaleChanger.h
//  ff_ios
//
//  Created by NAKAZATO Hajime on 12/06/28.
//  Copyright 2011 Nishizaike Kaoriha. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Cordova/CDVPlugin.h"

@interface ScaleChanger : CDVPlugin

- (void)ready:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) scaleChanged;

@end
