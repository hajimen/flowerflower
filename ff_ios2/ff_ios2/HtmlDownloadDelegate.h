//
//  HtmlDownloadDelegate.h
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/22.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;

@interface HtmlDownloadDelegate : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

-(id)initWithUrl: (NSURL *)url storeTo: (NSURL *)storeTo;
-(RACSignal *)start;

@end
