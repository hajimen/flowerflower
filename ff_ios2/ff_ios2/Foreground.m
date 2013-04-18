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
#import "SVProgressHUD.h"
#import "Foreground.h"

#import "Cordova/CDVViewController.h"
#import "IASKAppSettingsViewController.h"
#import "PSTCollectionView.h"

#import "TitleCollectionViewController.h"
#import "TitleCollectionViewLayout.h"
#import "TitleInfo.h"
#import "InfoViewController.h"
#import "PurchaseManager.h"
#import "ContentDownloader.h"

static Foreground *instance = nil;

@interface Foreground()

@property (nonatomic) CDVViewController *cdvViewController;
@property (nonatomic) PurchaseManager *purchaseManager;

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

    TitleCollectionViewController *tvc = [[TitleCollectionViewController alloc] initWithCollectionViewLayout:[TitleCollectionViewLayout new]];
    
    UITabBarController *tabController = [UITabBarController new];
    
    InfoViewController *ivc = [InfoViewController new];

    [tabController setViewControllers:@[tvc, ivc] animated: NO];
    self.viewController = tabController;

    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    _purchaseManager = [PurchaseManager instance];
    
    RACSignal *prepareSignal = [[RACSignal combineLatest:@[RACAbleWithStart(purchaseManager.transactionRunning), RACAbleWithStart(purchaseManager.restoreRunning), RACAbleWithStart(purchaseManager.initializing)] reduce:^(NSNumber *t, NSNumber *r, NSNumber *i){
        NSLog(@"transactionRunning or initializing status changed");
        return [NSNumber numberWithBool:[t boolValue] || [i boolValue] || [r boolValue]];
    }] distinctUntilChanged];
    [self rac_liftSelector: @selector(prepareStatusChanged:) withObjects: prepareSignal];
    
    return self;
}

-(void) prepareStatusChanged:(NSNumber *)prepareing {
    __weak Foreground *ws = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (ws) {
            if ([prepareing boolValue]) {
                [SVProgressHUD showWithStatus: NSLocalizedString(@"Prepareing...", nil) maskType:SVProgressHUDMaskTypeClear];
            } else {
                [SVProgressHUD dismiss];
            }
        }
    });
}

-(void)cellTapped:(TitleInfo *)titleInfo {
    // TODO blog
    titleInfo.lastViewed = [NSDate date];
    if (titleInfo.status != TitleStatusCompleted && titleInfo.purchased) {
        [[[ContentDownloader alloc] initWithTitleInfo: titleInfo] start]; // TODO notify to web view
    }
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
