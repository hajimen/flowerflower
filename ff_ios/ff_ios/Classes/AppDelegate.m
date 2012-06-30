//
//  AppDelegate.m
//  ff_ios
//
//  Created by NAKAZATO Hajime on 11/09/12.
//  Copyright Nishizaike Kaoriha 2011. All rights reserved.
//

#import "AppDelegate.h"
#ifdef PHONEGAP_FRAMEWORK
	#import <PhoneGap/PhoneGapViewController.h>
#else
	#import "PhoneGapViewController.h"
#endif
#import <QuartzCore/QuartzCore.h>
#import "NavigationController.h"

@implementation AppDelegate

@synthesize invokeString, iaskController, isOnceRotated, lastAutoRotateSwitch, beforeInterfaceOrientation, beforeScaleSlider;

- (id) init
{	
	/** If you need to do any extra app-specific initialization, you can do it here
	 *  -jm
	 **/
    isOnceRotated = NO;
    return [super init];
}

/**
 * This is main kick off after the app inits, the views and Settings are setup here. (preferred - iOS4 and up)
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self registerDefaultsFromSettingsBundle];
    self.lastAutoRotateSwitch = [self isAutoRotateEnabled];

	BOOL s = [super application:application didFinishLaunchingWithOptions:launchOptions];

    remotePlugin = [self getCommandInstance:@"org.kaoriha.phonegap.plugins.remotenotification"];
    remotePlugin.launchPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    UISwipeGestureRecognizer* leftSwipeRecognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)] autorelease];
    leftSwipeRecognizer.numberOfTouchesRequired = 1;
    leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    leftSwipeRecognizer.cancelsTouchesInView = YES;
    [self.viewController.view addGestureRecognizer: leftSwipeRecognizer];

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(defaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];

    return s;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	NSLog(@"deviceToken: %@", deviceToken);
    [remotePlugin registerOK: deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
    [remotePlugin registerFailed:err];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)payload {
    NSLog(@"didReceiveNotification");
    [remotePlugin receive:payload];
}

// this happens while we are running ( in the background, or from within our own app )
// only valid if ff_ios.plist specifies a protocol to handle
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url 
{
    // must call super so all plugins will get the notification, and their handlers will be called 
	// super also calls into javascript global function 'handleOpenURL'
    return [super application:application handleOpenURL:url];
}

-(id) getCommandInstance:(NSString*)className
{
	/** You can catch your own commands here, if you wanted to extend the gap: protocol, or add your
	 *  own app specific protocol to it. -jm
	 **/
	return [super getCommandInstance:className];
}

/**
 Called when the webview finishes loading.  This stops the activity view and closes the imageview
 */
- (void)webViewDidFinishLoad:(UIWebView *)theWebView 
{
	// only valid if ff_ios.plist specifies a protocol to handle
	if(self.invokeString)
	{
		// this is passed before the deviceready event is fired, so you can access it in js when you receive deviceready
		NSString* jsString = [NSString stringWithFormat:@"var invokeString = \"%@\";", self.invokeString];
		[theWebView stringByEvaluatingJavaScriptFromString:jsString];
	}
	return [ super webViewDidFinishLoad:theWebView ];
}

- (void)webViewDidStartLoad:(UIWebView *)theWebView 
{
	return [ super webViewDidStartLoad:theWebView ];
}

/**
 * Fail Loading With Error
 * Error - If the webpage failed to load display an error with the reason.
 */
- (void)webView:(UIWebView *)theWebView didFailLoadWithError:(NSError *)error 
{
	return [ super webView:theWebView didFailLoadWithError:error ];
}

/**
 * Start Loading Request
 * This is where most of the magic happens... We take the request(s) and process the response.
 * From here we can re direct links and other protocalls to different internal methods.
 */
- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSURL *url = [request URL];
    // Intercept the external http requests and forward to Safari.app
	// Otherwise forward to the PhoneGap WebView
	if ([[url scheme] isEqualToString:@"http"] || [[url scheme] isEqualToString:@"https"]) {		[[UIApplication sharedApplication] openURL:url];
		return NO;
	} else {
		return [ super webView:theWebView shouldStartLoadWithRequest:request navigationType:navigationType ];
	}
}


- (BOOL) execute:(InvokedUrlCommand*)command
{
	return [ super execute:command];
}

-(void)handleSwipeGesture:(UISwipeGestureRecognizer *)sender {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = [self transitionSubtype:YES];

    [[self.viewController.view.window layer] addAnimation:transition forKey:@"SwitchToView"];
    
    IASKAppSettingsViewController *sv = [[[IASKAppSettingsViewController alloc] init] autorelease];
    sv.showDoneButton = YES;
    sv.delegate = self;

    NavigationController *nc = [[NavigationController alloc] initWithRootViewController:sv];
    nc.initialInterfaceOrientation = self.viewController.interfaceOrientation;
    self.iaskController = nc;
    
    self.beforeInterfaceOrientation = self.viewController.interfaceOrientation;
    self.beforeScaleSlider = [self scaleSlider];
    
    [self.viewController presentModalViewController:self.iaskController animated:NO];
}

-(void) settingsViewControllerDidEnd: (IASKAppSettingsViewController *) sender {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionReveal;
    transition.subtype = [self transitionSubtype:NO];
    [[self.iaskController.view.window layer] addAnimation:transition forKey:nil];
    
    [self.viewController dismissModalViewControllerAnimated: NO];

    if (self.beforeScaleSlider != [self scaleSlider] || self.beforeInterfaceOrientation != self.viewController.interfaceOrientation) {
        ScaleChanger *sc = [self getCommandInstance:@"org.kaoriha.phonegap.plugins.scalechanger"];
        [sc scaleChanged];
    }
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

-(void)defaultsChanged:(NSNotification *)notification {
    BOOL ar = [self isAutoRotateEnabled];

    if (!self.lastAutoRotateSwitch && ar && [[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        [UIViewController attemptRotationToDeviceOrientation];
    }

    if (self.lastAutoRotateSwitch != ar) {
        self.lastAutoRotateSwitch = ar;
    }
}

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
    [defaultsToRegister release];
}

- (void)didRotateFromInterfaceOrientation: (UIInterfaceOrientation)fromInterfaceOrientation {
    isOnceRotated = YES;
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    ScaleChanger *sc = [self getCommandInstance:@"org.kaoriha.phonegap.plugins.scalechanger"];
    [sc scaleChanged];
}

- (NSString *)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation {
    if (!isOnceRotated || [self isAutoRotateEnabled]) {
        return @"";
    } else {
        if (self.viewController.interfaceOrientation == interfaceOrientation) {
            return @"YES";
        } else {
            return @"NO";
        }
    }
}

-(BOOL) isAutoRotateEnabled {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"autoRotateSwitch"];
}

-(float) scaleSlider {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults floatForKey:@"scaleSlider"];
}

- (void)dealloc
{
    self.iaskController = nil;
	[ super dealloc ];
}

@end
