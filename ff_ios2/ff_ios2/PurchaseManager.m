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

#define KOUCHABUTTON_BUNDLE_ID @"org.kaoriha.flowerflower.kouchabutton"
#define KOUCHABUTTON_TITLE_ID @"kouchabutton"
#define KANZENHITOGATA_BUNDLE_ID @"org.kaoriha.flowerflower.kanzenhitogata"
#define KANZENHITOGATA_TITLE_ID @"kanzenhitogata"

static PurchaseManager *instance = nil;

@interface  PurchaseManager ()

@property (nonatomic)InAppPurchaseStore *inAppPurchaseStore;

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
    
    RAC(online) = RACAbleWithStart(inAppPurchaseStore.online);
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

-(void)buyWithTitleInfo:(TitleInfo *)titleInfo {
    [_inAppPurchaseStore buyWithProductId: titleInfo.productId];
}

-(void)restore {
    if ([self isAppInstalled: KOUCHABUTTON_BUNDLE_ID]) {
        TitleInfo *ti = [TitleInfo instanceWithId: KOUCHABUTTON_TITLE_ID];
        [self purchased: ti.productId];
    }
    if ([self isAppInstalled: KANZENHITOGATA_BUNDLE_ID]) {
        TitleInfo *ti = [TitleInfo instanceWithId: KANZENHITOGATA_TITLE_ID];
        [self purchased: ti.productId];
    }
    [_inAppPurchaseStore restore];
}

-(void) onPurchaseWithProductId:(NSString *)productId receiptData: (NSData *)receiptData {
    [self purchased: productId];
}

-(void) onRestoreWithProductId:(NSString *)productId receiptData: (NSData *)receiptData {
    [self purchased: productId];
}

-(void)purchased:(NSString *)productId {
    TitleInfo *ti = [[TitleManager instance] titleInfoWithProductId: productId];
    ti.purchased = YES;
    [self unzipPurchasedTitleResource: ti];
    if (ti.distributionUrl) {
        [self startDownload: ti];
        [[TitleManager instance] registerPushNotification: ti];
    }
}

-(void)unzipPurchasedTitleResource:(TitleInfo *)titleInfo {
    NSDictionary *rp = [NSDictionary dictionaryWithContentsOfFile: [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: BUNDLE_PATH_TITLE_INFOS]];
    for (NSDictionary *tip in [rp objectForKey: PLK_TITLES]) {
        NSString *tid = [tip objectForKey: PLK_ID];
        if ([titleInfo.titleId isEqualToString: tid]) {
            NKLibrary *lib = [NKLibrary sharedLibrary];
            NKIssue *issue = [lib issueWithName: titleInfo.titleId];
            NSString *p = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: [tip objectForKey: PLK_PURCHASED_RESOURCE_ZIP_PATH]];
            ZipArchive *za = [ZipArchive new];
            [za UnzipOpenFile: p];
            [za UnzipFileTo: [[issue contentURL] path] overWrite: YES];
            [za UnzipCloseFile];
            return;
        }
    }
    @throw [NSString stringWithFormat:@"unzipPurchasedTitleResource bad titleId: %@", titleInfo.titleId];
}

-(void)startDownload:(TitleInfo *)titleInfo {
    __block ContentDownloader *cd = [[ContentDownloader alloc] initWithTitleInfo: titleInfo];
    [[cd start] subscribeError:^(NSError *error) {
        NSLog(@"ContentDownloader error:%@", error);
        cd = nil;
    } completed:^{
        NSLog(@"ContentDownloader complete.");
        cd = nil;
    }];
}

-(void)onFailed: (NSError *)error {
    // TODO
    NSLog(@"PurchaseManager IAP transaction failed. error:%@", error);
}

-(BOOL)isAppInstalled:(NSString *)customUrlScheme {
    NSURL *u = [NSURL URLWithString: [NSString stringWithFormat: @"%@://", customUrlScheme]];
    return [[UIApplication sharedApplication] canOpenURL: u];
}

@end
