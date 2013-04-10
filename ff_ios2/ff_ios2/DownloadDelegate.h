//
//  DownloadDelegate.h
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/08.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa/ReactiveCocoa.h"

@class TitleInfo;

@interface DownloadDelegate : NSObject <NSURLConnectionDownloadDelegate, NSURLConnectionDataDelegate>

-(id)initWithPath:(NSString *)path titleInfo:(TitleInfo *)titleInfo finishing:(BOOL (^)(NSURL *storedTo, NSObject *jsonObj))finishing;

-(RACSignal *)start;

@end
