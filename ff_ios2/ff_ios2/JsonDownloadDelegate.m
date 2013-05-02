//
//  JsonDownloadDelegate.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/05/02.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "ReactiveCocoa/ReactiveCocoa.h"
#import "JSONKit.h"
#import "JsonDownloadDelegate.h"
#import "TitleInfo.h"
#import "NSFileManager+Overwrite.h"

@interface JsonDownloadDelegate ()

@property (nonatomic, strong) NSURL *(^finishing)(NSObject *jsonObj);
@property (nonatomic) NSURLConnection *conn;
@property (nonatomic) RACSubject *finishedSubject;
@property (nonatomic) int statusCode;
@property (nonatomic) NSMutableData *data;
@property (nonatomic) TitleInfo *titleInfo;
@property (nonatomic) NSString *path;

@end

@implementation JsonDownloadDelegate

-(id)initWithTitleInfo: (TitleInfo *)titleInfo path: (NSString *)path finishing: (NSURL *(^)(NSObject *jsonObj))finishing {
    self = [super init];
    if (!self) {
        return self;
    }

    _titleInfo = titleInfo;
    _path = path;
    _finishing = finishing;
    _conn = nil;
    
    return self;
}

-(RACSignal *)start {
    if (_conn) {
        [_conn cancel];
    }
    NSURL *url = [_titleInfo.distributionUrl URLByAppendingPathComponent: _path];
    _conn = [[NSURLConnection alloc] initWithRequest: [NSURLRequest requestWithURL: url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: 2.0] delegate: self];
    
    _finishedSubject = [RACSubject subject];
    
    return _finishedSubject;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (_statusCode == 200) {
        NSError *error1;
        NSObject *jsonObj;
        @try {
            jsonObj = [_data objectFromJSONDataWithParseOptions: JKParseOptionNone error: &error1];
        } @catch (NSException *e) {
            NSLog(@"JSON parse failed. Exception: %@", e);
            [_finishedSubject sendError: nil];
            return;
        }
        if (error1) {
            [_finishedSubject sendError: nil];
        }
        NSURL *storeTo = _finishing(jsonObj);
        if (storeTo) {
            [_data writeToFile: [storeTo path] atomically: YES];
        }
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
