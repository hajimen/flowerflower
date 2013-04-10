//
//  NSFileManager+Overwrite.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/10.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "NSFileManager+Overwrite.h"

@implementation NSFileManager (Overwrite)

-(BOOL)copyOverwriteItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL error:(NSError *__autoreleasing *)error {
    NSData *d = [NSData dataWithContentsOfURL: srcURL];
    return [d writeToFile: [dstURL path] options: NSDataWritingAtomic error:error];
}

@end
