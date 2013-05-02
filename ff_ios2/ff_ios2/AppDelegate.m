//
//  AppDelegate.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/03/14.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "ReactiveCocoa/ReactiveCocoa.h"

#import "AppDelegate.h"

#import "Foreground.h"
#import "RemoteNotification.h"
#import "PurchaseManager.h"

#import "LoopTest.h"
#import "AuthDelegate.h"
#import "TitleInfo.h"
#import "ContentDownloader.h"
#import "TitleManager.h"

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
@property (nonatomic) TitleInfo *updatedTitle;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self registerDefaultsFromSettingsBundle];

    [self localNotification: [launchOptions objectForKey: UIApplicationLaunchOptionsLocalNotificationKey]];

    self.remoteNotification = [RemoteNotification instance];
    [self.remoteNotification register_];
    [self.remoteNotification receive:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];

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
        self.foreground = [Foreground instance];
    }
    if (_updatedTitle) {
        [self.foreground showTitle: _updatedTitle];
    } else if (self.remoteNotification.updatedTitle) {
        [self.foreground showTitle: self.remoteNotification.updatedTitle];
    }
    _updatedTitle = nil;
    self.remoteNotification.updatedTitle = nil;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

////////////////////////////////////////////////////////////////////////
// remote notification
////////////////////////////////////////////////////////////////////////
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
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

////////////////////////////////////////////////////////////////////////
// local notification
////////////////////////////////////////////////////////////////////////
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [self localNotification: notification];
}

-(void)localNotification:(UILocalNotification *)ln {
    if (ln && ln.userInfo) {
        NSLog(@"local notification received");
        NSString *titleId = [ln.userInfo objectForKey: @"titleId"];
        _updatedTitle = [TitleInfo instanceWithId: titleId];
    } else {
        _updatedTitle = nil;
    }

}

////////////////////////////////////////////////////////////////////////
// defaults
////////////////////////////////////////////////////////////////////////
- (void)registerDefaultsFromSettingsBundle {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
}

@end
