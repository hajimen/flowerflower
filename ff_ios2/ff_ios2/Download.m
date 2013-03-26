//
//  Download.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/03/26.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <NewsstandKit/NewsstandKit.h>
#import "Download.h"

@interface Download ()

@property (nonatomic) BOOL test;

@end

@implementation Download

#define TEST_ISSUE_NAME @"TEST ISSUE"
#define TEST_DOWNLOAD_URL @"http://kaoriha.org/nikki/"

-(id)init {
    self = [super init];
    if (self) {
        self.test = NO;
    }
    return self;
}

-(void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    NSLog(@"didWriteData");
}

-(void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    NSLog(@"totalBytesWritten");
}

-(void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL {
    NSLog(@"connectionDidFinishDownloading");

    if (self.test) {
        return;
    }
    self.test = YES;

    NKLibrary *lib = [NKLibrary sharedLibrary];
    NKIssue *issue = [lib issueWithName:TEST_ISSUE_NAME];
    NSURL *url = [NSURL URLWithString:TEST_DOWNLOAD_URL];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NKAssetDownload *ad = [issue addAssetWithRequest:req];
    [ad downloadWithDelegate:self];
}

@end
