//
//  Purchase.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/11.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <NewsstandKit/NewsstandKit.h>
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "ZipArchive.h"
#import "PurchaseManager.h"
#import "InAppPurchaseStore.h"
#import "UserDefaultsKey.h"
#import "TitleInfosConstant.h"
#import "TitleInfo.h"
#import "TitleManager.h"
#import "ContentDownloader.h"
#import "AuthDelegate.h"
#import "Reachability.h"

#define KOUCHABUTTON_BUNDLE_ID @"org.kaoriha.flowerflower.kouchabutton"
#define KOUCHABUTTON_TITLE_ID @"kouchabutton"
#define KANZENHITOGATA_BUNDLE_ID @"org.kaoriha.flowerflower.kanzenhitogata"
#define KANZENHITOGATA_TITLE_ID @"kanzenhitogata"

static PurchaseManager *instance = nil;

@interface  PurchaseManager ()

@property (nonatomic)InAppPurchaseStore *inAppPurchaseStore;
@property (nonatomic)Reachability *internetReachability;

@end

@implementation PurchaseManager

+(void)initialize {
    @synchronized(self) {
        if (instance == nil) {
            instance = [[PurchaseManager alloc] initOnce];
        }
    }
}

+(PurchaseManager *)instance {
    return instance;
}

-(id)initOnce {
    self = [super self];
    if (!self) {
        return self;
    }

    __weak PurchaseManager *ws = self;
    BOOL isTransactionRunning = [[NSUserDefaults standardUserDefaults] boolForKey: UDK_IS_TRANSACTION_RUNNING];
    _inAppPurchaseStore = [[InAppPurchaseStore alloc] initWithRunningTransaction: isTransactionRunning onPurchase:^(NSString *productId, NSData *receiptData) {
        [ws onPurchaseWithProductId: productId receiptData: receiptData];
    } onFailed:^(NSError *error) {
        [ws onFailed: error];
    } onRestore:^(NSString *productId, NSData *receiptData) {
        [ws onRestoreWithProductId: productId receiptData: receiptData];
    }];
    
    _internetReachability = [Reachability reachabilityForInternetConnection];
    [_internetReachability startNotifier];
    RAC(online) = RACAbleWithStart(inAppPurchaseStore.online);
    [RACAble(internetReachability.isReachable) subscribeNext:^(NSNumber *reachable) {
        if ([reachable boolValue]) {
            [ws.inAppPurchaseStore checkOnline];
        }
    }];
    RAC(transactionRunning) = RACAbleWithStart(inAppPurchaseStore.transactionRunning);
    RAC(restoreRunning) = RACAbleWithStart(inAppPurchaseStore.restoreRunning);
    RAC(lastUpdated) = RACAbleWithStart(inAppPurchaseStore.lastUpdated);

    return self;
}

-(id)init {
    @throw @"PurchaseManager is singleton";
    return nil;
}

-(void)setTransactionRunning:(BOOL)transactionRunning {
    [self willChangeValueForKey:@"transactionRunning"];

    _transactionRunning = transactionRunning;

    [[NSUserDefaults standardUserDefaults] setBool: transactionRunning forKey:UDK_IS_TRANSACTION_RUNNING];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self didChangeValueForKey:@"transactionRunning"];
}

-(void)setInitializing:(BOOL)initializing {
    [self willChangeValueForKey:@"transactionRunning"];
    _initializing = initializing;
    [self didChangeValueForKey:@"transactionRunning"];
}

-(void)buyWithTitleInfo:(TitleInfo *)titleInfo {
    [_inAppPurchaseStore buyWithProductId: titleInfo.productId];
}

-(void)restoreLegacyTitleWithBundleId: (NSString *)bundleId titleId:(NSString *)titleId {
    NSUbiquitousKeyValueStore *us = [NSUbiquitousKeyValueStore defaultStore];
    if ([self isAppInstalled: bundleId] || [us boolForKey: titleId]) {
        TitleInfo *ti = [TitleInfo instanceWithId: titleId];
        [us setBool: YES forKey: titleId];
        [us synchronize];
        [self purchased: ti.productId receiptData: nil];
    }
}

-(void)restore {
    [self restoreLegacyTitleWithBundleId: KOUCHABUTTON_BUNDLE_ID titleId: KOUCHABUTTON_TITLE_ID];
    [self restoreLegacyTitleWithBundleId: KANZENHITOGATA_BUNDLE_ID titleId: KANZENHITOGATA_TITLE_ID];
    [_inAppPurchaseStore restore];
}

-(void) onPurchaseWithProductId:(NSString *)productId receiptData: (NSData *)receiptData {
    [self purchased: productId receiptData: receiptData];
}

-(void) onRestoreWithProductId:(NSString *)productId receiptData: (NSData *)receiptData {
    [self purchased: productId receiptData: receiptData];
}

-(void)purchased:(NSString *)productId receiptData: (NSData *)receiptData {
    TitleInfo *ti = [[TitleManager instance] titleInfoWithProductId: productId];
    ti.purchased = YES;
    NSDictionary *tip = [self findFromTitleInfoPlist: ti];
    self.initializing = YES;
    [self unzipPurchasedTitleResource: ti titleInfoPlist: tip];
    if (ti.distributionUrl) {
        NSString *s = [tip objectForKey: PLK_STATUS];
        BOOL pushEnabled = s && [s isEqualToString: PLV_STATUS_ON_AIR];
        AuthDelegate *ad = [[AuthDelegate alloc] initWithReceipt: receiptData titleInfo: ti];
        [[ad start] subscribeError:^(NSError *error) {
            NSLog(@"AuthDelegate error: %@", error);
            UIAlertView *av = [[UIAlertView alloc] initWithTitle: @"Auth Error" message:@"Distribution server trouble. Please restore your purchase later." delegate: self cancelButtonTitle: @"Close" otherButtonTitles: nil];
            [av show];
            self.initializing = NO;
        } completed:^{
            __block ContentDownloader *cd = [[ContentDownloader alloc] initWithTitleInfo: ti];
            [[cd start] subscribeError:^(NSError *error) {
                NSLog(@"ContentDownloader error:%@", error);
                UIAlertView *av = [[UIAlertView alloc] initWithTitle: @"Download Error" message:@"Distribution server trouble. Please wait until recovery." delegate: self cancelButtonTitle: @"Close" otherButtonTitles: nil];
                [av show];
                self.initializing = NO;
                cd = nil;
            } completed:^{
                NSLog(@"ContentDownloader complete.");
                self.initializing = NO;
                cd = nil;
            }];
            if (pushEnabled) {
                [[TitleManager instance] registerPushNotification: ti];
                ti.status = TitleStatusPushEnabled;
            } else {
                ti.status = TitleStatusCompleted;
            }
        }];
    }
}

-(NSDictionary *)findFromTitleInfoPlist: (TitleInfo *)titleInfo {
    NSDictionary *rp = [NSDictionary dictionaryWithContentsOfFile: [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: BUNDLE_PATH_TITLE_INFOS]];
    for (NSDictionary *tip in [rp objectForKey: PLK_TITLES]) {
        NSString *tid = [tip objectForKey: PLK_ID];
        if ([titleInfo.titleId isEqualToString: tid]) {
            return tip;
        }
    }
    return nil;
}

-(void)unzipPurchasedTitleResource:(TitleInfo *)titleInfo titleInfoPlist: (NSDictionary *)tip {
    NSString *p = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: [tip objectForKey: PLK_PURCHASED_RESOURCE_ZIP_PATH]];
    ZipArchive *za = [ZipArchive new];
    [za UnzipOpenFile: p];
    [za UnzipFileTo: [[titleInfo.issue contentURL] path] overWrite: YES];
    [za UnzipCloseFile];
    return;
}

-(void)onFailed: (NSError *)error {
    NSLog(@"PurchaseManager IAP transaction failed. error:%@", error);
    UIAlertView *av = [[UIAlertView alloc] initWithTitle: @"Purchase Aborted" message:@"Purchase Aborted" delegate: self cancelButtonTitle: @"Close" otherButtonTitles: nil];
    [av show];
}

-(BOOL)isAppInstalled:(NSString *)customUrlScheme {
    NSURL *u = [NSURL URLWithString: [NSString stringWithFormat: @"%@://", customUrlScheme]];
    return [[UIApplication sharedApplication] canOpenURL: u];
}

@end
