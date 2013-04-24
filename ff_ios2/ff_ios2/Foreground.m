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

#import "FlowerFlowerContentViewController.h"
#import "IASKAppSettingsViewController.h"
#import "PSTCollectionView.h"

#import "TitleCollectionViewController.h"
#import "TitleCollectionViewLayout.h"
#import "TitleInfo.h"
#import "InfoViewController.h"
#import "PurchaseManager.h"
#import "ContentDownloader.h"
#import "UserDefaultsKey.h"

static Foreground *instance = nil;

@interface TabBarController : UITabBarController
@end

@implementation TabBarController

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

-(BOOL)shouldAutorotate {
    return [[NSUserDefaults standardUserDefaults] boolForKey: UDK_AUTO_ROTATE_SWITCH];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return [self shouldAutorotate];
}

@end

@interface NavigationController : UINavigationController
@end

@implementation NavigationController

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

-(BOOL)shouldAutorotate {
    return [[NSUserDefaults standardUserDefaults] boolForKey: UDK_AUTO_ROTATE_SWITCH];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return [self shouldAutorotate];
}

@end


@interface Foreground()

@property (nonatomic) FlowerFlowerContentViewController *ffcViewController;
@property (nonatomic) PurchaseManager *purchaseManager;
@property (nonatomic) NavigationController *settingsViewController;

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

    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(userDefaultChanged) name: NSUserDefaultsDidChangeNotification object: nil];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];

    TitleCollectionViewController *tvc = [[TitleCollectionViewController alloc] initWithCollectionViewLayout:[TitleCollectionViewLayout new]];
    tvc.tabBarItem.image = [UIImage imageNamed:@"tabbar-title.png"];
    tvc.tabBarItem.title = NSLocalizedString(@"Titles", nil);
    
    TabBarController *tabController = [TabBarController new];
    
    InfoViewController *ivc = [InfoViewController new];
    ivc.tabBarItem.image = [UIImage imageNamed:@"tabbar-settings.png"];
    ivc.tabBarItem.title = NSLocalizedString(@"Infos & Settings", nil);

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
    
    _settingsViewController = nil;
    
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

-(void)showTitle:(TitleInfo *)titleInfo {
    // TODO blog
    titleInfo.lastViewed = [NSDate date];
    if (titleInfo.status != TitleStatusCompleted && titleInfo.purchased) {
        [[[ContentDownloader alloc] initWithTitleInfo: titleInfo] start];
    }
    [self showCdvViewContoller: titleInfo];
}

-(void)showCdvViewContoller:(TitleInfo *)titleInfo {
    _ffcViewController = [[FlowerFlowerContentViewController alloc] initWithTitleInfo: titleInfo];

    for (UILocalNotification *ln in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if (ln.userInfo) {
            NSString *titleId = [ln.userInfo objectForKey: @"titleId"];
            if (titleId && [titleInfo.titleId isEqualToString: titleId]) {
                [[UIApplication sharedApplication] cancelLocalNotification: ln];
            }
        }
    }

    UISwipeGestureRecognizer* rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleCdvViewControllerRightSwipeGesture:)];
    rightSwipeRecognizer.numberOfTouchesRequired = 1;
    rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    rightSwipeRecognizer.cancelsTouchesInView = YES;
    [_ffcViewController.view addGestureRecognizer: rightSwipeRecognizer];

    UISwipeGestureRecognizer* leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleCdvViewControllerLeftSwipeGesture:)];
    leftSwipeRecognizer.numberOfTouchesRequired = 1;
    leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    leftSwipeRecognizer.cancelsTouchesInView = YES;
    [_ffcViewController.view addGestureRecognizer: leftSwipeRecognizer];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = [self transitionSubtype:YES];
    
    [[self.viewController.view.window layer] addAnimation:transition forKey:@"SwitchToView"];
    
    [self.viewController presentModalViewController: _ffcViewController animated:NO];
}

-(void)handleCdvViewControllerRightSwipeGesture:(UISwipeGestureRecognizer *)sender {
    [self dismissCdvViewController];
}

-(void)handleCdvViewControllerLeftSwipeGesture:(UISwipeGestureRecognizer *)sender {
    [self showSettingsViewController];
}

-(void)showSettingsViewController {
    if (!_settingsViewController) {
        IASKAppSettingsViewController *sv = [IASKAppSettingsViewController new];
        sv.showDoneButton = YES;
        sv.delegate = self;
        
        _settingsViewController = [[NavigationController alloc] initWithRootViewController: sv];
    }

    CATransition *transition = [CATransition animation];
    transition.duration = 0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = [self transitionSubtype:YES];
    
    [[_ffcViewController.view.window layer] addAnimation: transition forKey:@"SwitchToView"];
    
    [_ffcViewController presentModalViewController: _settingsViewController animated: NO];
}

-(void) settingsViewControllerDidEnd: (IASKAppSettingsViewController *) sender {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionReveal;
    transition.subtype = [self transitionSubtype:NO];
    [[_settingsViewController.view.window layer] addAnimation:transition forKey:nil];
    
    [_ffcViewController syncSettings];
    [_ffcViewController dismissModalViewControllerAnimated: NO];
}

-(void)dismissCdvViewController {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionReveal;
    transition.subtype = [self transitionSubtype:NO];
    [[_ffcViewController.view.window layer] addAnimation:transition forKey:nil];
    
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

-(void)userDefaultChanged {
    if ([[NSUserDefaults standardUserDefaults] boolForKey: UDK_AUTO_ROTATE_SWITCH]) {
        [UIViewController attemptRotationToDeviceOrientation];
   }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end
