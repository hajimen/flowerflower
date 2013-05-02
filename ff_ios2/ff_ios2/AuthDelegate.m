//
//  AuthDelegate.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/09.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <NewsstandKit/NewsstandKit.h>
#import "GTMStringEncoding.h"
#import "AuthDelegate.h"
#import "TitleInfo.h"
#import "FFPath.h"
#import "AuthCookie.h"

@interface AuthDelegate()

@property (nonatomic) NSData *receipt;
@property (nonatomic) TitleInfo *titleInfo;

@property (nonatomic) NKIssue *issue;
@property (nonatomic) RACSubject *finishedSubject;
@property (nonatomic) NSURLConnection *conn;
@property (nonatomic) int statusCode;
@property (nonatomic) AuthCookie *authCookie;

@end

@implementation AuthDelegate

-(id)initWithReceipt:(NSData *)receipt titleInfo:(TitleInfo *)titleInfo {
    self = [super init];
    if (!self) {
        return self;
    }

    _receipt = receipt;
    _titleInfo = titleInfo;
    _conn = nil;
    _authCookie = [[AuthCookie alloc] initWithTitleInfo: titleInfo];

    return self;
}

-(RACSignal *)start {
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL: [_titleInfo.distributionUrl URLByAppendingPathComponent: AUTH_OFFICE]];
    [req setHTTPMethod: @"POST"];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSString *rs = [[GTMStringEncoding rfc4648Base64StringEncoding] encode: _receipt];
    NSString *ps = [NSString stringWithFormat: @"receipt=%@", [self urlEncode: rs]];
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
    if (_statusCode == 200) {
        [_authCookie setCookiesWithResponse: response];
    }
}

- (NSString *) urlEncode: (NSString *)s
{
    CFStringRef sr = CFURLCreateStringByAddingPercentEscapes(NULL,  (CFStringRef)s,  NULL,  (CFStringRef)@"!*'();:@&amp;=+$,/?%#[]",  kCFStringEncodingUTF8);
    return (__bridge_transfer NSString *)sr;
}

@end
