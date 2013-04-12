//
//  ContentDownloader.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/08.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <NewsstandKit/NewsstandKit.h>
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "JSONKit.h"

#import "ContentDownloader.h"
#import "FFPath.h"
#import "TitleInfo.h"
#import "NSFileManager+Overwrite.h"
#import "AuthCookie.h"
#import "AssetDownloadDelegate.h"

#define CATALOGUE_TEMP_PATH @"Auth/catalogye_temp.json"
#define USER_INFO_PATH_KEY @"path"

@interface ContentDownloader() {
    ContentDownloadStatus _status;
}

@property (nonatomic) TitleInfo *titleInfo;
@property (nonatomic) RACSubject *finishSubject;
@property (nonatomic) NKIssue *issue;
@property (nonatomic) AuthCookie *authCookie;

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
    _issue = [[NKLibrary sharedLibrary] issueWithName: _titleInfo.titleId];
    _authCookie = [[AuthCookie alloc] initWithTitleInfo: titleInfo];
    
    return self;
}

-(NKAssetDownload *)createAssetDownloadWithPath: (NSString *)path {
    NSURL *u = [_titleInfo.distributionUrl URLByAppendingPathComponent: path];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL: u];
    NSDictionary *h = [NSHTTPCookie requestHeaderFieldsWithCookies: _authCookie.cookies];
    [req setAllHTTPHeaderFields: h];
    req.HTTPShouldHandleCookies = YES;
    NKAssetDownload *ad = [_issue addAssetWithRequest:req];
    ad.userInfo = @{USER_INFO_PATH_KEY : path};
    return ad;
}

-(void)startCatalogueDownloadDelegate: (NKAssetDownload *)ad {
    __weak ContentDownloader *ws = self;
    AssetDownloadDelegate *add =  [[AssetDownloadDelegate alloc] initWithAssetDownload: ad finishing:^NSURL *(NSURL *storedTo, NSObject *jsonObj) {
        [ws catalogueDownloaded: storedTo json: jsonObj];
        return [ws.issue.contentURL URLByAppendingPathComponent: CATALOGUE_TEMP_PATH];;
    }];
    [[add start] subscribeError:^(NSError *error) {
        [ws downloadFailed: error];
    } completed:^{
        [ws.authCookie setCookiesWithUrl: ws.titleInfo.distributionUrl];
    }];
}

-(RACSignal *)start {
    self.status = ContentDownloadStatusInProgress;
    _finishSubject = [RACSubject subject];

    NKAssetDownload *ad = [self createAssetDownloadWithPath: CATALOGUE_PATH];

    [self startCatalogueDownloadDelegate: ad];

    return _finishSubject;
}

-(RACSignal *)resume {
    if ([[_issue downloadingAssets] count] == 0) {
        return nil;
    }

    self.status = ContentDownloadStatusInProgress;
    _finishSubject = [RACSubject subject];

    NSMutableArray *toMerge = [NSMutableArray new];
    NSURL *contentUrl = [_issue contentURL];

    for (NKAssetDownload *ad in [_issue downloadingAssets]) {
        NSLog(@"unfinished downloads exist");
        NSString *path = [ad.userInfo objectForKey: USER_INFO_PATH_KEY];
        if ([path isEqualToString: CATALOGUE_PATH]) {
            [self startCatalogueDownloadDelegate: ad];
        } else {
            NSURL *fileUrl = [contentUrl URLByAppendingPathComponent: path];
            AssetDownloadDelegate *add = [[AssetDownloadDelegate alloc] initWithAssetDownload: ad finishing:^NSURL *(NSURL *storedTo, NSObject *jsonObj) {
                return fileUrl;
            }];
            [toMerge addObject: [add start]];
        }
    }

    if ([toMerge count] > 0) {
        __weak ContentDownloader *bs = self;
        [[RACSignal merge: toMerge] subscribeError:^(NSError *error) {
            [bs downloadFailed: error];
        } completed:^{
            [bs finishDownload];
        }];
    }

    return _finishSubject;
}

-(void)catalogueDownloaded: (NSURL *)storedTo json: (NSObject *)jsonObj {
    NSDictionary *newCatalogue = (NSDictionary *)jsonObj;
    NSArray *newLocal = [newCatalogue objectForKey:@"local"];
    NSDictionary *newExpressDic = [newCatalogue objectForKey: @"express"];
    NSMutableArray *newExpress = [NSMutableArray arrayWithCapacity: [newExpressDic count]];
    for (NSString *k in [newExpressDic keyEnumerator]) {
        NSString *kv = [NSString stringWithFormat:@"%@%@", k, [newExpressDic objectForKey:k]];
        [newExpress addObject: kv];
    }
    NSArray *names = [newLocal arrayByAddingObjectsFromArray: newExpress];

    NSURL *contentUrl = [_issue contentURL];
    NSMutableArray *toMerge = [NSMutableArray new];
    for (NSString *name in names) {
        NSString *path = [NSString stringWithFormat:PUBLICATION_PATH_FORMAT, name];
        NSURL *fileUrl = [contentUrl URLByAppendingPathComponent: path];
        if (![fileUrl checkResourceIsReachableAndReturnError: nil]) {
            NKAssetDownload *ad = [self createAssetDownloadWithPath: path];
            AssetDownloadDelegate *add = [[AssetDownloadDelegate alloc] initWithAssetDownload: ad finishing:^NSURL *(NSURL *storedTo, NSObject *jsonObj) {
                return fileUrl;
            }];
            [toMerge addObject: [add start]];
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
        [_finishSubject sendCompleted];
    }
}

-(void)finishDownload {
    NKLibrary *lib = [NKLibrary sharedLibrary];
    NSURL *contentUrl = [[lib issueWithName: _titleInfo.titleId] contentURL];
    NSURL *tempFrom = [contentUrl URLByAppendingPathComponent: CATALOGUE_TEMP_PATH];
    NSURL *storeTo = [contentUrl URLByAppendingPathComponent: CATALOGUE_PATH];
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL success = [fm copyOverwriteItemAtURL: tempFrom toURL: storeTo error: &error];
    if (!success) {
        [self downloadFailed: error];
        return;
    }
    self.status = ContentDownloadStatusUpdated;
    [_finishSubject sendCompleted];
}

-(void)downloadFailed: (NSError *)error {
    if (error) {
        NSLog(@"ContentDownloader error:%@", error);
        if ([error.domain isEqualToString: @"SSErrorDomain"]) {
            self.status = ContentDownloadStatusFailedByServer;
        } else {
            self.status = ContentDownloadStatusFailedByUnknown;
        }
    } else {
        self.status = ContentDownloadStatusFailedByAuth;
    }
    [_finishSubject sendError: error];
}

-(void)setStatus:(ContentDownloadStatus)status {
    [self willChangeValueForKey:@"status"];
    _status = status;
    [self didChangeValueForKey:@"status"];
}

@end
