//
//  RemoteNotification.h
//  ff_ios
//
//  Created by NAKAZATO Hajime on 11/09/21.
//  Copyright 2011 Nishizaike Kaoriha. All rights reserved.
//

#import <Foundation/Foundation.h>


#ifdef PHONEGAP_FRAMEWORK
#import <PhoneGap/PGPlugin.h>
#else
#import "PGPlugin.h"
#endif

@interface RemoteNotification : PGPlugin {
    @protected NSString* callbackId;
    @public NSDictionary* launchPayload;
    @protected BOOL isReadyRemoteNotificationFireEvent;
    @protected BOOL isOnceRegistered;
    @protected NSString* deviceTokenHex;
    @protected BOOL isOnceReceivedLaunchPayload;
}
@property(copy, nonatomic) NSString *callbackId;
@property (copy, nonatomic)  NSDictionary* launchPayload;
@property(copy, nonatomic) NSString *deviceTokenHex;

- (void)readyRemoteNotificationFireEvent:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)getLaunchPayload:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)register_:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)registerOK:(NSData*)deviceToken;
- (void)registerFailed:(NSError*)err;
- (void)receive:(NSDictionary *)payload;
- (void)clearBadge:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end
