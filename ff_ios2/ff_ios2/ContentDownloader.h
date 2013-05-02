//
//  ContentDownloader.h
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/08.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ContentDownloadStatus) {
    ContentDownloadStatusIdle,
    ContentDownloadStatusInProgress,
    ContentDownloadStatusUpdated,
    ContentDownloadStatusNotModified,
    ContentDownloadStatusFailedByServer,
    ContentDownloadStatusFailedByAuth,
    ContentDownloadStatusFailedByUnknown
};

@class TitleInfo;
@class RACSignal;

@interface ContentDownloader : NSObject

-(id)initWithTitleInfo:(TitleInfo *)titleInfo;
-(RACSignal *)start;

@property (nonatomic, readonly) ContentDownloadStatus status;

@end
