//
//  RemoteNotification.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/03/25.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <NewsstandKit/NewsstandKit.h>

#import "RemoteNotification.h"
#import "GTMStringEncoding.h"
#import "InAppPurchaseStore.h"

@implementation RemoteNotification

#define TEST_ISSUE_NAME @"TEST ISSUE"
#define TEST_DOWNLOAD_URL @"http://kaoriha.org/nikki/index.rdf"

-(void)register_ {
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes: UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeNewsstandContentAvailability | UIRemoteNotificationTypeSound];
}

-(void)registerOk:(NSData *) deviceTokenData {
    NSString *deviceTokenHex = [[GTMStringEncoding hexStringEncoding] encode:deviceTokenData];
    NSLog(@"device token: %@", deviceTokenHex);

    // TODO tell server deviceToken
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
    
    // TODO
}

- (void)clearBadge:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

@end
