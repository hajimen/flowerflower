//
//  AssetDownloadDelegate.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/10.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//
#import <NewsstandKit/NewsstandKit.h>
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "JSONKit.h"
#import "AssetDownloadDelegate.h"
#import "TitleInfo.h"
#import "NSFileManager+Overwrite.h"


@interface AssetDownloadDelegate ()

@property (nonatomic, strong) NSURL *(^finishing)(NSURL *storedTo, NSObject *jsonObj);

@property (nonatomic) RACSubject *finishedSubject;
@property (nonatomic) NKAssetDownload *assetDwonload;

@end

@implementation AssetDownloadDelegate

-(id)initWithAssetDownload: (NKAssetDownload *)assetDwonload finishing:(NSURL * (^)(NSURL *storedTo, NSObject *jsonObj))finishing {
    self = [super init];
    if (!self) {
        return self;
    }
    
    _assetDwonload = assetDwonload;
    _finishing = finishing;
    
    return self;
}

-(RACSignal *)start {
    _finishedSubject = [RACSubject subject];

    [_assetDwonload downloadWithDelegate: self];
    
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
    NSURL *storeTo = _finishing(destinationURL, jsonObj);
    if(storeTo) {
        success1 = [fm copyOverwriteItemAtURL: destinationURL toURL: storeTo error: &error1];
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
