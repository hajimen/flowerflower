//
//  ContentDownloader.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/08.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <NewsstandKit/NewsstandKit.h>
#import "JSONKit.h"
#import "ContentDownloader.h"
#import "FFPath.h"
#import "UserDefaultsKey.h"
#import "TitleInfo.h"
#import "DownloadDelegate.h"

#define CATALOGUE_TEMP_PATH @"Auth/catalogye_temp.json"

@interface ContentDownloader() {
    ContentDownloadStatus _status;
}

@property (nonatomic) TitleInfo *titleInfo;

@end

@implementation ContentDownloader

@synthesize status = _status;

-(id)initWithTitleInfo:(TitleInfo *)titleInfo {
    self = [super init];
    if (!self) {
        return self;
    }

    _status = ContentDownloadStatusIdle;
    _titleInfo = titleInfo;
    
    return self;
}

-(void)start {
    self.status = ContentDownloadStatusInProgress;

    __weak ContentDownloader *bs = self;
    DownloadDelegate *dd = [[DownloadDelegate alloc] initWithPath: CATALOGUE_PATH titleInfo:_titleInfo finishing:^(NSURL *storedTo, NSObject *jsonObj) {
        [bs catalogueDownloaded: storedTo json: jsonObj];
        return YES;
    }];
    [[dd start] subscribeError:^(NSError *error) {
        [bs downloadFailed: error];
    }];
}

-(void)catalogueDownloaded: (NSURL *)storedTo json: (NSObject *)jsonObj {
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    NKLibrary *lib = [NKLibrary sharedLibrary];
    NKIssue *issue = [lib issueWithName: _titleInfo.titleId];
    NSURL *tempTo = [[issue contentURL] URLByAppendingPathComponent: CATALOGUE_TEMP_PATH];
    BOOL success = [fm copyItemAtURL: storedTo toURL: tempTo error: &error];
    if (!success) {
        [self downloadFailed: error];
        return;
    }

    NSDictionary *newCatalogue = (NSDictionary *)jsonObj;
    NSArray *newLocal = [newCatalogue objectForKey:@"local"];
    NSDictionary *newExpressDic = [newCatalogue objectForKey: @"express"];
    NSMutableArray *newExpress = [NSMutableArray arrayWithCapacity: [newExpressDic count]];
    for (NSString *k in [newExpressDic keyEnumerator]) {
        NSString *kv = [NSString stringWithFormat:@"%@%@", k, [newExpressDic objectForKey:k]];
        [newExpress addObject: kv];
    }
    NSArray *names = [newLocal arrayByAddingObjectsFromArray: newExpress];

    NSURL *contentUrl = [issue contentURL];
    NSMutableArray *toMerge = [NSMutableArray new];
    for (NSString *name in names) {
        NSString *path = [NSString stringWithFormat:PUBLICATION_PATH_FORMAT, name];
        NSURL *fileUrl = [contentUrl URLByAppendingPathComponent: path];
        if (![fileUrl checkResourceIsReachableAndReturnError: nil]) {
            DownloadDelegate *fdd = [[DownloadDelegate alloc] initWithPath: path titleInfo: _titleInfo finishing:^BOOL(NSURL *storedTo, NSObject *jsonObj) {
                return NO;
            }];
            [toMerge addObject: [fdd start]];
        }
    }
    
    if ([toMerge count] > 0) {
        __weak ContentDownloader *bs = self;
        [[RACSignal merge: toMerge] subscribeError:^(NSError *error) {
            [bs downloadFailed: error];
        } completed:^{
            [bs finishDownload];
        }];
    } else {
        self.status = ContentDownloadStatusNotModified;
    }
}

-(void)finishDownload {
    NKLibrary *lib = [NKLibrary sharedLibrary];
    NSURL *contentUrl = [[lib issueWithName: _titleInfo.titleId] contentURL];
    NSURL *tempFrom = [contentUrl URLByAppendingPathComponent: CATALOGUE_TEMP_PATH];
    NSURL *storeTo = [contentUrl URLByAppendingPathComponent: CATALOGUE_PATH];
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL success = [fm copyItemAtURL: tempFrom toURL: storeTo error: &error];
    if (!success) {
        [self downloadFailed: error];
        return;
    }
    self.status = ContentDownloadStatusUpdated;
}

-(void)downloadFailed: (NSError *)error {
    if (error) {
        if ([error.domain isEqualToString: @"SSErrorDomain"]) {
            self.status = ContentDownloadStatusFailedByServer;
        } else {
            self.status = ContentDownloadStatusFailedByUnknown;
        }
    } else {
        self.status = ContentDownloadStatusFailedByAuth;
    }
}

-(void)setStatus:(ContentDownloadStatus)status {
    [self willChangeValueForKey:@"status"];
    _status = status;
    [self didChangeValueForKey:@"status"];
}

@end
