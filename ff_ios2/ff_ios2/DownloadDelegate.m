//
//  DownloadDelegate.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/08.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <NewsstandKit/NewsstandKit.h>
#import "JSONKit.h"
#import "DownloadDelegate.h"
#import "TitleInfo.h"
#import "AuthCookie.h"

@interface DownloadDelegate()

@property (nonatomic) NSString *path;
@property (nonatomic) TitleInfo *titleInfo;
@property (nonatomic, strong) BOOL (^finishing)(NSURL *storedTo, NSObject *jsonObj);

@property (nonatomic) NKIssue *issue;
@property (nonatomic) RACSubject *finishedSubject;
@property (nonatomic) AuthCookie *authCookie;

@end

@implementation DownloadDelegate

-(id)initWithPath:(NSString *)path titleInfo:(TitleInfo *)titleInfo finishing:(BOOL (^)(NSURL *storedTo, NSObject *jsonObj))finishing{
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
    NSData *d = [NSData dataWithContentsOfURL: destinationURL];
    NSObject *jsonObj;
    @try {
        jsonObj = [d objectFromJSONDataWithParseOptions: JKParseOptionNone error:&error1];
    } @catch (NSException *e) {
        NSLog(@"JSON parse failed. Exception:%@", e);
        [_finishedSubject sendError: nil];
        return;
    }
    if (error1) {
        [_finishedSubject sendError: error1];
        return;
    }
    if(_finishing(destinationURL, jsonObj)) {
        NSURL *storeTo = [[_issue contentURL] URLByAppendingPathComponent: _path];
        success1 = [fm copyItemAtURL: destinationURL toURL: storeTo error: &error1];
    }
    BOOL success2 = [fm removeItemAtURL: destinationURL error: &error2];

    if (success1 && success2) {
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
    [_finishedSubject sendError: error];
}

@end
