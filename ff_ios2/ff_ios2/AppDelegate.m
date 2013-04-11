//
//  AppDelegate.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/03/14.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <NewsstandKit/NewsstandKit.h>
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "EXTScope.h"
#import "SVProgressHUD.h"

#import "AppDelegate.h"

#import "Foreground.h"
#import "RemoteNotification.h"
#import "PurchaseManager.h"

#import "LoopTest.h"
#import "AuthDelegate.h"
#import "TitleInfo.h"
#import "ContentDownloader.h"

@interface AppDelegate()
{
    NSMutableArray *_events;
}
@property (nonatomic) RemoteNotification *remoteNotification;
@property (nonatomic) Foreground *foreground;
@property (nonatomic) PurchaseManager *purchaseManager;

@property (nonatomic) NSString *test1;
@property (nonatomic) NSString *test2;
@property (nonatomic) ContentDownloader *cd;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLaunchingWithOptions");
/*
    RACCommand *cmd = [RACCommand command];
    RACCommand *cmd2 = [RACCommand command];
    [[RACSignal combineLatest:@[cmd, cmd2] reduce:^(id _, ...) {
        NSLog(@"test 1");
        return nil;
    }] subscribeNext:^(id _){
    }];
    
    [cmd subscribeNext:^(id _) {
        NSLog(@"test 1.1");
    }];
    NSLog(@"test 2");
    [cmd execute:@1];
    [cmd2 execute:@1];
    NSLog(@"test 3");
    [cmd execute:@2];
    [cmd2 execute:@2];
    NSLog(@"test 4");
    */
    /*
    self.test1 = @"0";
    self.test2 = @"0";
    [[[RACSignal combineLatest:@[RACAbleWithStart(test1), RACAbleWithStart(test2)]] distinctUntilChanged] subscribeNext:^(id _){
        NSLog(@"test 1");
    }];
    NSLog(@"test 2");
    self.test1 = @"1";
    NSLog(@"test 3");
    self.test2 = @"2";
    NSLog(@"test 4");
    self.test1 = @"3";
*/
    /*
    RACCommand *cmd = [RACCommand command];
    RACCommand *cmd2 = [RACCommand command];
    RACSignal *sig = [RACSignal merge:@[cmd, cmd2]];
    [sig subscribeNext:^(id x) {
        NSLog(@"test 1");
    }];
    NSLog(@"test 2");
    [cmd execute:nil];
    NSLog(@"test 3");
    [cmd2 execute:nil];
    NSLog(@"test 4");
*/
/*
    [[RACSignal interval:1.0] subscribeNext:^(id x) {
        NSLog(@"start");
        [[LoopTest new] loop];
        NSLog(@"exit");
    }];
*/
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsNewsstandDownloadsKey]) {
//        [[Download new] resume];
    }
    
/*
    self.remoteNotification = [RemoteNotification new];
    [self.remoteNotification register_];
    [self.remoteNotification receive:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
*/
#if DEBUG
    [[NSUserDefaults standardUserDefaults] setBool: YES forKey:@"NKDontThrottleNewsstandContentNotifications"];
#endif

/*
    [[RACSignal interval: 10.0] subscribeNext:^(NSDate *date) {
        SKPaymentQueue *q = [SKPaymentQueue defaultQueue];
        NSArray *ts = [q transactions];
        NSLog(@"paymentQueue transactions: %@", ts);
    }];
*/
 /*
    [RACAble(self.iapStore.transactionRunning) subscribeNext:^(NSNumber *transactionRunning) {
        if ([transactionRunning boolValue]) {
            [SVProgressHUD showWithStatus: NSLocalizedString(@"transactionRunning", nil) maskType:SVProgressHUDMaskTypeClear];
        } else {
            [SVProgressHUD dismiss];
        }
    }];
*/
    TitleInfo *ti = [TitleInfo instanceWithId:@"TEST ISSUE"];
    ti.distributionUrl = [NSURL URLWithString:@"http://kaoriha.org/miyako/"];
    [[RACAble(self.purchaseManager.online) take: 1] subscribeNext:^(NSNumber *online) {
        NSLog(@"store online");
        [self.purchaseManager restore];
        /* [self.iapStore buy:@"non_consumable_test_1"];
        [[RACAble(self.iapStore.transactionRunning) take: 1] subscribeNext:^(NSNumber *running) {
            NSLog(@"buy ok");
        }];  */
/*
        NKLibrary *lib = [NKLibrary sharedLibrary];
        NKIssue *old = [lib issueWithName:@"TEST ISSUE"];
        if (old) {
            NSLog(@"old test issue removed");
            [lib removeIssue:old];
        }
        NKIssue *issue = [lib addIssueWithName:@"TEST ISSUE" date:[NSDate date]];
        if (![[NSFileManager defaultManager] createDirectoryAtURL:[[issue contentURL] URLByAppendingPathComponent:@"Auth"] withIntermediateDirectories: YES attributes:nil error:nil]) {
            NSLog(@"cannot create directory");
        }

        _cd = [[ContentDownloader alloc] initWithTitleInfo: ti];
        [[_cd start] subscribeError:^(NSError *error) {
            NSLog(@"ContentDownloader error:%@", error);
        } completed:^{
            NSLog(@"ContentDownloader complete.");
        }];

/*
        __block int c = 0;
        __block void (^loop)();
        loop = ^(){
            c ++;
            NKLibrary *lib = [NKLibrary sharedLibrary];
            NKIssue *old = [lib issueWithName:@"TEST ISSUE"];
            if (old) {
                NSLog(@"old test issue removed");
                [lib removeIssue:old];
            }
            NKIssue *issue = [lib addIssueWithName:@"TEST ISSUE" date:[NSDate date]];
            if (![[NSFileManager defaultManager] createDirectoryAtURL:[[issue contentURL] URLByAppendingPathComponent:@"Auth"] withIntermediateDirectories: YES attributes:nil error:nil]) {
                NSLog(@"cannot create directory");
            }
            
            _cd = [[ContentDownloader alloc] initWithTitleInfo: ti];
            [[_cd start] subscribeError:^(NSError *error) {
                NSLog(@"loop failed error:%@", error);
            } completed:^{
                NSLog(@"loop next");
                if (c < 1000) {
                    loop();
                }
            }];
        };
        // loop();
 */
    }];
    
    _cd = [[ContentDownloader alloc] initWithTitleInfo: ti];
    [[_cd resume] subscribeError:^(NSError *error) {
        NSLog(@"ContentDownloader error:%@", error);
    } completed:^{
        NSLog(@"ContentDownloader complete.");
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
    __block BOOL on;
    on = YES;
    {
        @weakify(self)
        [[[RACSignal interval:3.0] deliverOn:RACScheduler.mainThreadScheduler] subscribeNext:^(id x) {
            NSLog(@"start");
            @strongify(self)
            if (on) {
                self.foreground = nil;
            } else {
                self.foreground = [Foreground new];
            }
            on = !on;
            NSLog(@"exit");
        }];
    }
*/
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
