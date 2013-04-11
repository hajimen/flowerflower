//
//  TitleManager.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/05.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <NewsstandKit/NewsstandKit.h>
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "ZipArchive.h"
#import "TitleManager.h"
#import "TitleInfo.h"
#import "UserDefaultsKey.h"
#import "TitleInfosConstant.h"

static TitleManager *_instance = nil;

@interface TitleManager () {
    NSMutableSet *_titleInfoSet;
}

@end


@implementation TitleManager

+(void)initialize {
    @synchronized(self) {
        if (!_instance) {
            _instance = [[self alloc] initOnce];
        }
    }
}

+(TitleManager *)instance {
    return _instance;
}

-(id)init {
    @throw @"TitleManager is singleton.";
    return nil;
}

-(id)initOnce {
    self = [super init];
    if (!self) {
        return self;
    }
    
    _titleInfoSet = [NSMutableSet new];

    NSDictionary *rp = [NSDictionary dictionaryWithContentsOfFile: [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: BUNDLE_PATH_TITLE_INFOS]];

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *versionUD = [ud stringForKey: UDK_TITLE_INFOS_VERSION];
    int versionPL = [[rp objectForKey: PLK_VERSION] intValue];
    if (versionUD == nil || [versionUD intValue] < versionPL) {
        for (NSDictionary *tip in [rp objectForKey: PLK_TITLES]) {
            TitleInfo *ti = [TitleInfo instanceWithId: [tip objectForKey: PLK_ID]];
            if (ti.name == nil) {
                NSString *statusPL = [tip objectForKey: PLK_STATUS];
                if ([statusPL isEqualToString: PLV_STATUS_COMPLETED]) {
                    ti.status = TitleStatusCompleted;
                } else if ([statusPL isEqualToString: PLV_STATUS_ON_AIR]) {
                    ti.status = TitleStatusOnAir;
                } else {
                    @throw @"TitleInfos.plist bad. wrong status";
                }
                NKLibrary *lib = [NKLibrary sharedLibrary];
                NKIssue *issue = [lib issueWithName: ti.titleId];
                if (issue == nil) {
                    issue = [lib addIssueWithName: ti.titleId date: [tip objectForKey: PLK_LAST_UPDATED]];
                }
                NSString *p = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: [tip objectForKey: PLK_BASE_RESOURCE_ZIP_PATH]];
                ZipArchive *za = [ZipArchive new];
                [za UnzipOpenFile: p];
                [za UnzipFileTo: [[issue contentURL] path] overWrite: YES];
                [za UnzipCloseFile];
            }
            ti.name = [tip objectForKey: PLK_NAME];
            ti.tags = [[tip objectForKey: PLK_TAGS] componentsSeparatedByString: @","];
            ti.lastUpdated = [tip objectForKey: PLK_LAST_UPDATED];
            if (ti.lastViewed == nil) {
                ti.lastViewed = [ti lastUpdated];
            }
            NKLibrary *lib = [NKLibrary sharedLibrary];
            NKIssue *issue = [lib issueWithName: ti.titleId];
            NSURL *cu = [issue contentURL];
            ti.thumbnailUrl = [cu URLByAppendingPathComponent: [tip objectForKey: PLK_THUMBNAIL_PATH]];
            ti.footnote = @"";
            if (! ti.price) {
                ti.price = UNKNOWN_PRICE;
            }
            ti.productId = [tip objectForKey: PLK_PRODUCT_ID];
            NSString *titleTypePL = [tip objectForKey: PLK_TYPE];
            if ([titleTypePL isEqualToString: PLV_TYPE_FLOWERFLOWER]) {
                ti.distributionUrl = [NSURL URLWithString: [tip objectForKey: PLK_DISTRIBUTION_URL]];
            }
        }
        [ud setObject: [rp objectForKey: PLK_VERSION] forKey: UDK_TITLE_INFOS_VERSION];
    } else {
        NSLog(@"load from NSUserDefaults");
    }
    for (NSDictionary *tip in [rp objectForKey: PLK_TITLES]) {
        TitleInfo *ti = [TitleInfo instanceWithId: [tip objectForKey: PLK_ID]];
        [_titleInfoSet addObject: ti];
    }

    return self;
}

-(NSSet *)titleInfoSet {
    return [_titleInfoSet copy];
}

-(TitleInfo *)titleInfoWithProductId:(NSString *)productId {
    for (TitleInfo *ti in _titleInfoSet) {
        if ([productId isEqualToString: ti.productId]) {
            return ti;
        }
    }
    @throw [NSString stringWithFormat: @"titleInfoWithProductId not found. bad productId: %@", productId];
}

-(void)registerPushNotification: (TitleInfo *)titleInfo {
    // TODO
}

@end
