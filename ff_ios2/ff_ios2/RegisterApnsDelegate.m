//
//  RegisterApnsDelegate.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/13.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "ReactiveCocoa/ReactiveCocoa.h"
#import "RegisterApnsDelegate.h"
#import "AuthCookie.h"
#import "FFPath.h"
#import "GTMStringEncoding.h"

@interface RegisterApnsDelegate ()

@property (nonatomic) NSData *deviceTokenData;
@property (nonatomic) NSURL *url;

@property (nonatomic) RACSubject *finishedSubject;
@property (nonatomic) NSURLConnection *conn;
@property (nonatomic) int statusCode;

@end

@implementation RegisterApnsDelegate

-(id)initWithDeviceTokenData:(NSData *)deviceTokenData url:(NSURL *)url {

    self = [super init];
    if (!self) {
        return self;
    }
    
    _deviceTokenData = deviceTokenData;
    _url = url;
    _conn = nil;
    
    return self;
}

-(RACSignal *)startWithEnable: (BOOL) enable {
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL: [_url URLByAppendingPathComponent: REGISTER_APNS_OFFICE]];
    [req setHTTPMethod: @"POST"];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSString *ds = [[GTMStringEncoding hexStringEncoding] encode: _deviceTokenData];
    NSString *es;
    if (enable) {
        es = @"true";
    } else {
        es = @"false";
    }
    NSString *ps = [NSString stringWithFormat: @"deviceToken=%@&enable=%@", ds, es];
    NSData *psData = [ps dataUsingEncoding: NSUTF8StringEncoding];
    [req setHTTPBody: psData];
    
    if (_conn) {
        [_conn cancel];
    }
    _conn = [[NSURLConnection alloc] initWithRequest: req delegate: self];
    
    _finishedSubject = [RACSubject subject];
    
    return _finishedSubject;
}

-(void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
}

-(void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
}

-(void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL {
    NSError *error = nil;
    
    if (_statusCode == 200) {
        [_finishedSubject sendCompleted];
    } else {
        [_finishedSubject sendError: error];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [_finishedSubject sendError: error];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _statusCode = [(NSHTTPURLResponse *)response statusCode];
}

@end
