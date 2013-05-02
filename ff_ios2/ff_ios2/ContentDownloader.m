//
//  ContentDownloader.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/08.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "ReactiveCocoa/ReactiveCocoa.h"
#import "JSONKit.h"

#import "ContentDownloader.h"
#import "FFPath.h"
#import "TitleInfo.h"
#import "NSFileManager+Overwrite.h"
#import "AuthCookie.h"
#import "TitleManager.h"
#import "JsonDownloadDelegate.h"

#define CATALOGUE_TEMP_PATH @"Auth/catalogue_temp.json"
#define USER_INFO_PATH_KEY @"path"

@interface ContentDownloader() {
    ContentDownloadStatus _status;
}

@property (nonatomic) TitleInfo *titleInfo;
@property (nonatomic) RACSubject *finishSubject;
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
    _authCookie = [[AuthCookie alloc] initWithTitleInfo: titleInfo];
    
    return self;
}

-(RACSignal *)start {
    self.status = ContentDownloadStatusInProgress;
    _finishSubject = [RACSubject subject];

    __weak ContentDownloader *ws = self;
    JsonDownloadDelegate *jdd = [[JsonDownloadDelegate alloc] initWithTitleInfo: _titleInfo path:CATALOGUE_PATH finishing:^NSURL *(NSObject *jsonObj) {
        [ws catalogueDownloaded: jsonObj];
        return [ws.titleInfo.depot URLByAppendingPathComponent: CATALOGUE_TEMP_PATH];;
    }];
    [[jdd start] subscribeError:^(NSError *error) {
        [ws downloadFailed: error];
    } completed:^{
        [ws.authCookie setCookiesWithUrl: ws.titleInfo.distributionUrl];
    }];

    return _finishSubject;
}

-(void)catalogueDownloaded: (NSObject *)jsonObj {
    NSDictionary *newCatalogue = (NSDictionary *)jsonObj;
    NSArray *newLocal = [newCatalogue objectForKey:@"local"];
    NSDictionary *newExpressDic = [newCatalogue objectForKey: @"express"];
    NSMutableArray *newExpress = [NSMutableArray arrayWithCapacity: [newExpressDic count]];
    for (NSString *k in [newExpressDic keyEnumerator]) {
        NSString *kv = [NSString stringWithFormat:@"%@%@", k, [newExpressDic objectForKey:k]];
        [newExpress addObject: kv];
    }
    NSArray *names = [newLocal arrayByAddingObjectsFromArray: newExpress];

    NSMutableArray *toMerge = [NSMutableArray new];
    for (NSString *name in names) {
        NSString *path = [NSString stringWithFormat:PUBLICATION_PATH_FORMAT, name];
        NSURL *fileUrl = [_titleInfo.depot URLByAppendingPathComponent: path];
        if (![fileUrl checkResourceIsReachableAndReturnError: nil]) {
            JsonDownloadDelegate *jdd = [[JsonDownloadDelegate alloc] initWithTitleInfo: _titleInfo path: path finishing:^NSURL *(NSObject *jsonObj) {
                return fileUrl;
            }];
            [toMerge addObject: [jdd start]];
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
    NSURL *tempFrom = [_titleInfo.depot URLByAppendingPathComponent: CATALOGUE_TEMP_PATH];
    NSURL *storeTo = [_titleInfo.depot URLByAppendingPathComponent: CATALOGUE_PATH];
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL success = [fm copyOverwriteItemAtURL: tempFrom toURL: storeTo error: &error];
    if (!success) {
        [self downloadFailed: error];
        return;
    }
    self.status = ContentDownloadStatusUpdated;
    [_finishSubject sendCompleted];
    [[TitleManager instance] notifyUpdated: _titleInfo];
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
