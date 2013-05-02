//
//  RegisterApnsDelegate.h
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/13.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;

@interface RegisterApnsDelegate : NSObject <NSURLConnectionDownloadDelegate>

-(id)initWithDeviceTokenData:(NSData *)deviceTokenData url:(NSURL *)url;

-(RACSignal *)startWithEnable: (BOOL) enable;

@end
