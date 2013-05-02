//
//  Uuid.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/05/02.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "Uuid.h"

@implementation Uuid

+(NSString *)string {
    CFUUIDRef ur = CFUUIDCreate(nil);
    NSString *us = (NSString *)CFBridgingRelease(CFUUIDCreateString(nil, ur));
    CFRelease(ur);
    return us;
}

@end
