//
//  DownloadDelegate.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/08.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <NewsstandKit/NewsstandKit.h>
#import "DownloadDelegate.h"
#import "TitleInfo.h"
#import "AuthCookie.h"

@interface DownloadDelegate()

@property (nonatomic) NSString *path;
@property (nonatomic) TitleInfo *titleInfo;
@property (nonatomic, strong) BOOL (^finishing)(BOOL successed, NSURL *storeURL);

@property (nonatomic) BOOL cancelled;
@property (nonatomic) NKIssue *issue;
@property (nonatomic) RACSubject *finishedSubject;
@property (nonatomic) AuthCookie *authCookie;

@end

@implementation DownloadDelegate

-(id)initWithPath:(NSString *)path titleInfo:(TitleInfo *)titleInfo finishing:(BOOL (^)(BOOL successed, NSURL *storeURL))finishing{
    self = [super init];
    if (!self) {
        return self;
    }

    _path = path;
    _titleInfo = titleInfo;
    _finishing = finishing;
    _authCookie = [[AuthCookie alloc] initWithTitleInfo: titleInfo];

    return self;
}

-(RACSignal *)start {
    _cancelled = NO;
    _finishedSubject = [RACSubject subject];

    NKLibrary *lib = [NKLibrary sharedLibrary];
    _issue = [lib issueWithName: _titleInfo.titleId];
    NSURL *u = [_titleInfo.distributionUrl URLByAppendingPathComponent: _path];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL: u];
    NSLog(@"req url: %@", [u absoluteURL]);
    NSDictionary *h = [NSHTTPCookie requestHeaderFieldsWithCookies: _authCookie.cookies];
    [req setAllHTTPHeaderFields: h];
    req.HTTPShouldHandleCookies = YES;
    NKAssetDownload *ad = [_issue addAssetWithRequest:req];
    [ad downloadWithDelegate: self];
    
    return _finishedSubject;
}

-(void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
}

-(void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
}

-(void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error1 = nil;
    NSError *error2 = nil;
    BOOL success1 = YES;
    if (!_cancelled && !_finishing(YES, destinationURL)) {
        NSURL *storeTo = [[_issue contentURL] URLByAppendingPathComponent: _path];
        success1 = [fm copyItemAtURL: destinationURL toURL: storeTo error: &error1];
    }
    BOOL success2 = [fm removeItemAtURL: destinationURL error: &error2];

    if (success1 && success2 && !_cancelled) {
        [_finishedSubject sendCompleted];
    } else {
        NSError *error = nil;
        if (!success1) {
            error = error1;
        } else if (!success2) {
            error = error2;
        }
        [_finishedSubject sendError: error];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (_cancelled) {
        return;
    } else {
        _finishing(NO, nil);
    }
    [_finishedSubject sendError: error];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *r = (NSHTTPURLResponse *)response;
    // TODO not called
    if ([r statusCode] == 200) {
        [_authCookie setCookiesWithResponse: response];
    } else {
        _cancelled = YES;
        _finishing(NO, nil);
    }
}

@end
