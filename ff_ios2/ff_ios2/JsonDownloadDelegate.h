//
//  JsonDownloadDelegate.h
//  ff_ios2
//
//  Created by 岩田 健一 on 13/05/02.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;
@class TitleInfo;

@interface JsonDownloadDelegate : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

-(id)initWithTitleInfo: (TitleInfo *)titleInfo path: (NSString *)path finishing: (NSURL *(^)(NSObject *jsonObj))finishing;
-(RACSignal *)start;

@end
