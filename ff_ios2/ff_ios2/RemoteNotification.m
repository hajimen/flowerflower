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

static RemoteNotification *instance = nil;

@interface RemoteNotification ()

@property (nonatomic) NSData *deviceTokenData;

@end

@implementation RemoteNotification

#define TEST_ISSUE_NAME @"TEST ISSUE"
#define TEST_DOWNLOAD_URL @"http://kaoriha.org/nikki/index.rdf"

+(void)initialize {
    @synchronized(self) {
        if (instance == nil) {
            instance = [RemoteNotification new];
        }
    }
}

-(id)init {
    @throw @"RemoteNotification is singleton.";
}

+(RemoteNotification *)instance {
    return instance;
}

-(void)registerApnsTo: (NSURL *)url enable: (BOOL)enable {
    Reachability *rb = [Reachability reachabilityWithHostname: [url host]];
    rb.reachableBlock = ^(Reachability *rbb) {
        RegisterApnsDelegate *rad = [[RegisterApnsDelegate alloc] initWithDeviceTokenData:_deviceTokenData url: url];
        [[rad startWithEnable: enable] subscribeError:^(NSError *error) {
            NSLog(@"device token registration failed. url: %@", url);
        } completed:^{
            NSLog(@"device token registration ok");
        }];
    };
}

-(void)register_ {
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes: UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeNewsstandContentAvailability | UIRemoteNotificationTypeSound];
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
    
    // TODO read custom payload
}

- (void)clearBadge:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

@end
