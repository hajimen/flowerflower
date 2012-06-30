//
//  AppDelegate.h
//  ff_ios
//
//  Created by NAKAZATO Hajime on 11/09/12.
//  Copyright Nishizaike Kaoriha 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifdef PHONEGAP_FRAMEWORK
	#import <PhoneGap/PhoneGapDelegate.h>
#else
	#import "PhoneGapDelegate.h"
#endif

#import "RemoteNotification.h"
#import "ScaleChanger.h"
#import "IASKAppSettingsViewController.h"

@interface AppDelegate : PhoneGapDelegate <IASKSettingsDelegate> {

	NSString* invokeString;
    RemoteNotification* remotePlugin;
}

// invoke string is passed to your app on launch, this is only valid if you 
// edit ff_ios.plist to add a protocol
// a simple tutorial can be found here : 
// http://iphonedevelopertips.com/cocoa/launching-your-own-application-via-a-custom-url-scheme.html

@property (copy)  NSString* invokeString;
@property (nonatomic, retain) UINavigationController *iaskController;
@property (nonatomic) BOOL isOnceRotated;
@property (nonatomic) BOOL lastAutoRotateSwitch;
@property (nonatomic) UIInterfaceOrientation beforeInterfaceOrientation;
@property (nonatomic) float beforeScaleSlider;

@end

