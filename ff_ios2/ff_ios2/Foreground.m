//
//  Foreground.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/03/26.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <NewsstandKit/NewsstandKit.h>
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "Foreground.h"

#import "Cordova/CDVViewController.h"
#import "IASKAppSettingsViewController.h"
#import "PSTCollectionView.h"

#import "TitleCollectionViewController.h"
#import "TitleCollectionViewLayout.h"
#import "TitleInfo.h"
#import "InfoViewController.h"

static Foreground *instance = nil;

@interface Foreground()

@property (nonatomic) CDVViewController *cdvViewController;

@end

@implementation Foreground

+(void)initialize {
    @synchronized(self) {
        if (!instance) {
            instance = [Foreground new];
        }
    }
}

+(Foreground *)instance {
    return instance;
}

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

    InfoViewController *ivc = [InfoViewController new];

    [tabController setViewControllers:@[navController, ivc] animated:NO];
    self.viewController = tabController;

    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    return self;
}

-(void)cellTapped:(TitleInfo *)titleInfo {
    // TODO blog
    titleInfo.lastViewed = [NSDate date];
    [self showCdvViewContoller: titleInfo];
}

-(void)showCdvViewContoller:(TitleInfo *)titleInfo {
    _cdvViewController = [CDVViewController new];
    _cdvViewController.wwwFolderName = [[titleInfo.issue contentURL] absoluteString];
    _cdvViewController.startPage = @"flowerflower/index.html";
    _cdvViewController.view.frame = [[UIScreen mainScreen] bounds];

    UISwipeGestureRecognizer* rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleCdvViewControllerRightSwipeGesture:)];
    rightSwipeRecognizer.numberOfTouchesRequired = 1;
    rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    rightSwipeRecognizer.cancelsTouchesInView = YES;
    [_cdvViewController.view addGestureRecognizer: rightSwipeRecognizer];

    CATransition *transition = [CATransition animation];
    transition.duration = 0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = [self transitionSubtype:YES];
    
    [[self.viewController.view.window layer] addAnimation:transition forKey:@"SwitchToView"];
    
    [self.viewController presentModalViewController: _cdvViewController animated:NO];
}

-(void)handleCdvViewControllerRightSwipeGesture:(UISwipeGestureRecognizer *)sender {
    [self dismissCdvViewController];
}

-(void)dismissCdvViewController {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionReveal;
    transition.subtype = [self transitionSubtype:NO];
    [[_cdvViewController.view.window layer] addAnimation:transition forKey:nil];
    
    [self.viewController dismissModalViewControllerAnimated: NO];
}

-(NSString *) transitionSubtype: (BOOL) isShow {
    BOOL horizontal;
    BOOL normal;
    switch (self.viewController.interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            horizontal = YES;
            normal = isShow;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            horizontal = YES;
            normal = !isShow;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            horizontal = NO;
            normal = isShow;
            break;
        case UIInterfaceOrientationLandscapeRight:
            horizontal = NO;
            normal = !isShow;
            break;
        default:
            return nil;
    }
    if (horizontal) {
        if (normal) {
            return kCATransitionFromRight;
        } else {
            return kCATransitionFromLeft;
        }
    } else {
        if (normal) {
            return kCATransitionFromBottom;
        } else {
            return kCATransitionFromTop;
        }
    }
}


@end
