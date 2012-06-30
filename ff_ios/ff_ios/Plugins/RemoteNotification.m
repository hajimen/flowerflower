//
//  RemoteNotification.m
//  ff_ios
//
//  Created by NAKAZATO Hajime on 11/09/21.
//  Copyright 2011 Nishizaike Kaoriha. All rights reserved.
//

#import "RemoteNotification.h"
#import "GTMStringEncoding.h"
#import "AppDelegate.h"

@implementation RemoteNotification
@synthesize callbackId;
@synthesize launchPayload;
@synthesize deviceTokenHex;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        isReadyRemoteNotificationFireEvent = NO;
        isOnceRegistered = NO;
        isOnceReceivedLaunchPayload = NO;
    }
    
    return self;
}

- (void)readyRemoteNotificationFireEvent:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    isReadyRemoteNotificationFireEvent = YES;
}

- (void)getLaunchPayload:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* cid = [arguments objectAtIndex:0];
    NSDictionary* payload;
    if (isOnceReceivedLaunchPayload) {
        payload = NULL;
    } else {
        payload = launchPayload;
        isOnceReceivedLaunchPayload = YES;
    }
    PluginResult* result = [PluginResult resultWithStatus: PGCommandStatus_OK messageAsDictionary:payload];
    NSString* js = [result toSuccessCallbackString:cid];
    [self writeJavascript:js];
}

UIRemoteNotificationType genRNType(NSMutableDictionary* dict, NSString* key, UIRemoteNotificationType t) {
    if([[dict valueForKey:key] boolValue]) {
        return t;
    }
    return 0;
}

/*
 @param successCallback: function(deviceToken)
 @param errorCallback: function(errorMessage)
 @param options: {"Badge" : 1, "Sound" : 1, "Alert" : 1}
 */
- (void)register_:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    self.callbackId = [arguments objectAtIndex:0];

    if (isOnceRegistered) {
        PluginResult* result = [PluginResult resultWithStatus: PGCommandStatus_OK messageAsString: deviceTokenHex];
        NSString* js = [result toSuccessCallbackString:callbackId];
        [self writeJavascript:js];
        return;
    }

    UIRemoteNotificationType accum = 0;
    accum |= genRNType(options, @"Badge", UIRemoteNotificationTypeBadge);
    accum |= genRNType(options, @"Sound", UIRemoteNotificationTypeSound);
    accum |= genRNType(options, @"Alert", UIRemoteNotificationTypeAlert);

 	[[UIApplication sharedApplication]
     registerForRemoteNotificationTypes: accum];
}

- (void)enabledTypes:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* cid = [arguments objectAtIndex:0];
    NSMutableDictionary *types = [[NSMutableDictionary alloc] init];

    UIRemoteNotificationType userConfig = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];

    if (userConfig & UIRemoteNotificationTypeBadge) {
        [types setObject:@"true" forKey:@"Badge"]; 
    }
    if (userConfig & UIRemoteNotificationTypeSound) {
        [types setObject:@"true" forKey:@"Sound"]; 
    }
    if (userConfig & UIRemoteNotificationTypeAlert) {
        [types setObject:@"true" forKey:@"Alert"]; 
    }

    PluginResult* result = [PluginResult resultWithStatus: PGCommandStatus_OK messageAsDictionary:types];
    NSString* js = [result toSuccessCallbackString:cid];
    [self writeJavascript:js];
}


- (void)registerOK:(NSData*)deviceToken {
    GTMStringEncoding *encoding = [GTMStringEncoding hexStringEncoding];
    NSString* hexToken = [encoding encode:deviceToken];
    self.deviceTokenHex = hexToken;
    isOnceRegistered = YES;
    PluginResult* result = [PluginResult resultWithStatus: PGCommandStatus_OK messageAsString: hexToken];
    NSString* js = [result toSuccessCallbackString:callbackId];
    [self writeJavascript:js];
}

- (void)registerFailed:(NSError*)err {
    PluginResult* result = [PluginResult resultWithStatus: PGCommandStatus_ERROR messageAsString: [err localizedDescription]];
    NSString* js = [result toErrorCallbackString:callbackId];
    [self writeJavascript:js];
}

- (void)receive:(NSDictionary *)payload {
    if (isReadyRemoteNotificationFireEvent) {
        NSString* s = [payload JSONRepresentation];
        [self writeJavascript:[NSString stringWithFormat:@"RemoteNotificationFireEvent(%@);", s]];
    } else {
        self.launchPayload = payload;
    }
}

- (void)clearBadge:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

@end
