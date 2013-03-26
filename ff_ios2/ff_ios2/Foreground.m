//
//  Foreground.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/03/26.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "Foreground.h"

#import "Cordova/CDVViewController.h"
#import "IASKAppSettingsViewController.h"
#import "PSTCollectionView.h"

#import "TitleCollectionViewController.h"
#import "TitleCollectionViewLayout.h"


@implementation Foreground

-(id)init {
    self = [super init];
    if (self == nil) {
        return nil;
    }
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
    
    self.viewController = [[TitleCollectionViewController alloc] initWithCollectionViewLayout:[TitleCollectionViewLayout new]];
    
    UITabBarController *tabController = [UITabBarController new];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    
    [tabController setViewControllers:[NSArray arrayWithObject:navController] animated:NO];
    self.viewController = tabController;
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    return self;
}

@end
