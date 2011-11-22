//
//  AppDelegate.h
//  ff_ios
//
//  Created by 岩田 健一 on 11/09/12.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifdef PHONEGAP_FRAMEWORK
	#import <PhoneGap/PhoneGapDelegate.h>
#else
	#import "PhoneGapDelegate.h"
#endif

#import "RemoteNotification.h"

@interface AppDelegate : PhoneGapDelegate {

	NSString* invokeString;
    RemoteNotification* remotePlugin;
}

// invoke string is passed to your app on launch, this is only valid if you 
// edit ff_ios.plist to add a protocol
// a simple tutorial can be found here : 
// http://iphonedevelopertips.com/cocoa/launching-your-own-application-via-a-custom-url-scheme.html

@property (copy)  NSString* invokeString;

@end

