//
//  ScaleChanger.h
//  ff_ios
//
//  Created by NAKAZATO Hajime on 12/06/28.
//  Copyright 2011 Nishizaike Kaoriha. All rights reserved.
//

#import <Foundation/Foundation.h>


#ifdef PHONEGAP_FRAMEWORK
#import <PhoneGap/PGPlugin.h>
#else
#import "PGPlugin.h"
#endif

@interface ScaleChanger : PGPlugin

- (void)ready:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) scaleChanged;

@end
