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
#import "Reachability.h"

#import "TitleManager.h"
#import "TitleInfo.h"
#import "UserDefaultsKey.h"
#import "TitleInfosConstant.h"
#import "RemoteNotification.h"

static TitleManager *_instance = nil;

@interface TitleManager () {
    NSMutableSet *_titleInfoSet;
    BOOL _shouldRegisterToServer;
}

@property (nonatomic) Reachability *reachability;

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
    
    _shouldRegisterToServer = YES;
    _reachability = [Reachability reachabilityForInternetConnection];

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
                NKIssue *issue = ti.issue;
                if (issue == nil) {
                    issue = [[NKLibrary sharedLibrary] addIssueWithName: ti.titleId date: [tip objectForKey: PLK_LAST_UPDATED]];
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
            NSURL *cu = [ti.issue contentURL];
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

    [self rac_liftSelector: @selector(onReachabilityChanged:) withObjects: RACAble(reachability.isReachable)];
    
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

-(void)onReachabilityChanged:(NSNumber *)reachable {
    if (_shouldRegisterToServer && [reachable boolValue]) {
        for (TitleInfo *ti in _titleInfoSet) {
            if (ti.status != TitleStatusCompleted) {
                [self registerPushNotification: ti];
            }
        }
        _shouldRegisterToServer = NO;
    }
}

-(void)registerPushNotification: (TitleInfo *)titleInfo {
    if (_reachability.isReachable) {
        BOOL enable = (titleInfo.status == TitleStatusPushEnabled);
        [[RemoteNotification instance] registerApnsTo: [titleInfo distributionUrl] enable: enable];
    } else {
        _shouldRegisterToServer = YES;
    }
}

@end
