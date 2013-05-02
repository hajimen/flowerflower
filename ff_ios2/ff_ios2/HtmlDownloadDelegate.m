//
//  HtmlDownloadDelegate.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/22.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "ReactiveCocoa/ReactiveCocoa.h"
#import "HtmlDownloadDelegate.h"

@interface HtmlDownloadDelegate()

@property (nonatomic) NSURL *url;
@property (nonatomic) NSURL *storeTo;

@property (nonatomic) RACSubject *finishedSubject;
@property (nonatomic) NSURLConnection *conn;
@property (nonatomic) int statusCode;
@property (nonatomic) NSMutableData *data;

@end

@implementation HtmlDownloadDelegate

-(id)initWithUrl: (NSURL *)url storeTo: (NSURL *)storeTo {
    self = [super init];
    if (!self) {
        return self;
    }
    
    _url = url;
    _storeTo = storeTo;
    _conn = nil;
    
    return self;
}

-(RACSignal *)start {
    if (_conn) {
        [_conn cancel];
    }
    _conn = [[NSURLConnection alloc] initWithRequest: [NSURLRequest requestWithURL: _url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: 2.0] delegate: self];
    
    _finishedSubject = [RACSubject subject];
    
    return _finishedSubject;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (_statusCode == 200) {
        [_data writeToURL: _storeTo atomically: YES];
        [_finishedSubject sendCompleted];
    } else {
        [_finishedSubject sendError: nil];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData: data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [_finishedSubject sendError: error];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *ur = (NSHTTPURLResponse *)response;
    _statusCode = [ur statusCode];
    int cl = 0;
    NSString *cls = [[ur allHeaderFields] objectForKey: @"Content-Length"];
    if (cls) {
        cl = [cls intValue];
    }
    _data = [[NSMutableData alloc] initWithCapacity: cl];
}

@end
