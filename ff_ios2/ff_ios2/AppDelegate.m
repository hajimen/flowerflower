//
//  AppDelegate.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/03/14.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "AppDelegate.h"

#import "Cordova/CDVViewController.h"
#import "IASKAppSettingsViewController.h"
#import "PSTCollectionView.h"

#import "TitleCollectionViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
/*
    CDVViewController* cdvviewController = [[CDVViewController alloc] init];
    cdvviewController.wwwFolderName = @"www";
    cdvviewController.view.frame = [[UIScreen mainScreen] bounds];
    self.viewController = cdvviewController;
 */
    /*
    IASKAppSettingsViewController* sv = [[IASKAppSettingsViewController alloc] init];
    sv.showDoneButton = YES;
    sv.delegate = self;
    self.viewController = sv;
     */

    self.viewController = [[TitleCollectionViewController alloc] initWithCollectionViewLayout:[PSUICollectionViewFlowLayout new]];
    
    UITabBarController *tabController = [UITabBarController new];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    
    [tabController setViewControllers:[NSArray arrayWithObject:navController] animated:NO];
    self.viewController = tabController;

    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
