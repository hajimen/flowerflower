//
//  AppDelegate.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/03/14.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <NewsstandKit/NewsstandKit.h>
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "SVProgressHUD.h"

#import "AppDelegate.h"

#import "Foreground.h"
#import "RemoteNotification.h"
#import "Download.h"
#import "InAppPurchaseStore.h"

@interface AppDelegate()

@property (nonatomic) RemoteNotification *remoteNotification;
@property (nonatomic) Foreground *foreground;
@property (nonatomic) InAppPurchaseStore *iapStore;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLaunchingWithOptions");

    if ([launchOptions objectForKey:UIApplicationLaunchOptionsNewsstandDownloadsKey]) {
        [[Download new] resume];
    }
/*
    self.remoteNotification = [RemoteNotification new];
    [self.remoteNotification register_];
    [self.remoteNotification receive:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
*/
#if DEBUG
    [[NSUserDefaults standardUserDefaults] setBool: YES forKey:@"NKDontThrottleNewsstandContentNotifications"];
#endif

//    [MKStoreManager sharedManager];ngTransaction:NO plist:@"MKStoreKitConfigs.plist"
    self.iapStore = [[InAppPurchaseStore alloc] initWithRunningTransaction: NO plist:@"MKStoreKitConfigs.plist" onPurchase:^(NSString *productId, NSData *receiptData){
        NSLog(@"onPurchase called");
    } onFailed:^(NSError *error){
        NSLog(@"onFailed called error: %@", error);
    } onRestore:^(NSString *productId, NSData *receiptData){
        NSLog(@"onRestore called productId: %@", productId);
    }];
    
    SKPaymentQueue *q = [SKPaymentQueue defaultQueue];
    NSArray *ts = [q transactions];
    NSLog(@"first paymentQueue transactions: %@", ts);
    [[RACSignal interval: 10.0] subscribeNext:^(NSDate *date) {
        SKPaymentQueue *q = [SKPaymentQueue defaultQueue];
        NSArray *ts = [q transactions];
        NSLog(@"paymentQueue transactions: %@", ts);
    }];

    [RACAble(self.iapStore.transactionRunning) subscribeNext:^(NSNumber *transactionRunning) {
        if ([transactionRunning boolValue]) {
            [SVProgressHUD showWithStatus: NSLocalizedString(@"transactionRunning", nil) maskType:SVProgressHUDMaskTypeClear];
        } else {
            [SVProgressHUD dismiss];
        }
    }];
    
    [[RACAble(self.iapStore.online) take: 1] subscribeNext:^(NSNumber *online) {
        NSLog(@"store online");
       // [self.iapStore restore];
        [self.iapStore buy:@"non_consumable_test_1"];
        [[RACAble(self.iapStore.transactionRunning) take: 1] subscribeNext:^(NSNumber *running) {
            NSLog(@"buy ok");
        }]; /* */
    }];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (!self.foreground) {
        self.foreground = [Foreground new];
    }
/*
    NSLog(@"isFeaturePurchased: %d", [MKStoreManager isFeaturePurchased:@"not_hit"]);
    NSLog(@"purchasableObjects: %@", [[MKStoreManager sharedManager] purchasableObjects]);
    NSLog(@"pricesDictionary: %@", [[MKStoreManager sharedManager] pricesDictionary]);
*/
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

////////////////////////////////////////////////////////////////////////
// remote notification
////////////////////////////////////////////////////////////////////////
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	NSLog(@"deviceToken: %@", deviceToken);
    [self.remoteNotification registerOk: deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
    [self.remoteNotification registerFailedWithError:err];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)payload {
    NSLog(@"didReceiveNotification");
    [self.remoteNotification receive:payload];
}

@end
