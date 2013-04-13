//
//  RemoteNotification.h
//  ff_ios2
//
//  Created by 岩田 健一 on 13/03/25.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RemoteNotification : NSObject

+(RemoteNotification *)instance;
-(void)register_;
-(void)registerOk:(NSData *) data;
-(void)registerFailedWithError:(NSError *)error;
-(void)receive:(NSDictionary *)payload;
-(void)clearBadge:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
-(void)registerApnsTo: (NSURL *)url enable: (BOOL)enable;

@end
