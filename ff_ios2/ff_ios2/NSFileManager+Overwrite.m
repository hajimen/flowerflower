//
//  NSFileManager+Overwrite.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/10.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "NSFileManager+Overwrite.h"

@implementation NSFileManager (Overwrite)

-(BOOL)copyOverwriteItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError *__autoreleasing *)error {
    if ([self fileExistsAtPath: dstPath]) {
        if ([self removeItemAtPath: dstPath error: error]) {
            return NO;
        }
    }
    return [self copyItemAtPath: srcPath toPath: dstPath error: error];
}

-(BOOL)copyOverwriteItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL error:(NSError *__autoreleasing *)error {
    if ([dstURL checkResourceIsReachableAndReturnError: nil]) {
        if (! [self removeItemAtURL: dstURL error: error]) {
            return NO;
        }
    }
    return [self copyItemAtURL: srcURL toURL: dstURL error: error];
}

@end
