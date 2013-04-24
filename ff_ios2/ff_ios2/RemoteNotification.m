//
//  RemoteNotification.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/03/25.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <NewsstandKit/NewsstandKit.h>
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "Reachability.h"

#import "RemoteNotification.h"
#import "GTMStringEncoding.h"
#import "RegisterApnsDelegate.h"
#import "TitleManager.h"
#import "TitleInfo.h"
#import "ContentDownloader.h"
#import "AlertNewContent.h"

static RemoteNotification *instance = nil;

@interface RemoteNotification ()

@property (nonatomic) NSData *deviceTokenData;

@end

@implementation RemoteNotification

+(void)initialize {
    @synchronized(self) {
        if (instance == nil) {
            instance = [[RemoteNotification alloc] initOnce];
        }
    }
}

-(id)init {
    @throw @"RemoteNotification is singleton.";
}

-(id)initOnce {
    self = [super init];
    if (self) {
        _deviceTokenData = nil;
        _updatedTitle = nil;
    }
    return self;
}

+(RemoteNotification *)instance {
    return instance;
}

-(void)registerApnsTo: (NSURL *)url enable: (BOOL)enable {
    if (!_deviceTokenData) {
        // in simulator
        return;
    }

    Reachability *rb = [Reachability reachabilityWithHostname: [url host]];
    if ([rb isReachable]) {
        RegisterApnsDelegate *rad = [[RegisterApnsDelegate alloc] initWithDeviceTokenData:_deviceTokenData url: url];
        [[rad startWithEnable: enable] subscribeError:^(NSError *error) {
            NSLog(@"device token registration failed. url: %@", url);
        } completed:^{
            NSLog(@"device token registration ok");
        }];
    }
}

-(void)register_ {
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes: UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeNewsstandContentAvailability];
}

-(void)registerOk:(NSData *) deviceTokenData {
    NSString *deviceTokenHex = [[GTMStringEncoding hexStringEncoding] encode:deviceTokenData];
    NSLog(@"device token: %@", deviceTokenHex);
    _deviceTokenData = deviceTokenData;
}

-(void)registerFailedWithError:(NSError *)error {
    NSString *msg = [error localizedDescription];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Remote Notification" message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [av show];
}

- (void)receive:(NSDictionary *)payload {
    if (!payload) {
        return;
    }
    NSLog(@"remote notification received");
    
    NSDictionary *aps = [payload objectForKey: @"aps"];
    NSString *titleId = [payload objectForKey: @"titleId"];
    if (titleId) {
        TitleInfo *ti = [TitleInfo instanceWithId: titleId];
        self.updatedTitle = ti;
        [[[ContentDownloader alloc] initWithTitleInfo: ti] start];
        NSLog(@"content download started");

        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            AlertNewContent *anc = [AlertNewContent new];
            [anc showWithMessage: [aps objectForKey: @"alert"]];
             
        }
        UILocalNotification *n =[UILocalNotification new];
        n.alertBody = [aps objectForKey: @"alert"];
        n.userInfo = @{@"titleId" : titleId};
        [[UIApplication sharedApplication] scheduleLocalNotification: n];
    }
}

- (void)clearBadge:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

@end
