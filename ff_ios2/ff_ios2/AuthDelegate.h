//
//  AuthDelegate.h
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/09.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa/ReactiveCocoa.h"

@class TitleInfo;

@interface AuthDelegate : NSObject <NSURLConnectionDownloadDelegate>

-(id)initWithReceipt:(NSData *)receipt titleInfo:(TitleInfo *)titleInfo finishing:(void (^)(BOOL successed))finishing;

-(RACSignal *)start;

@end
