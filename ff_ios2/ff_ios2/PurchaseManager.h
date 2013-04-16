//
//  Purchase.h
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/11.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TitleInfo;

@interface PurchaseManager : NSObject

@property (nonatomic, readonly) BOOL online;
@property (nonatomic, readonly) BOOL transactionRunning;
@property (nonatomic, readonly) BOOL restoreRunning;
@property (nonatomic, readonly) BOOL initializing;
@property (nonatomic, readonly) NSDate *lastUpdated;

+(PurchaseManager *)instance;

-(void)buyWithTitleInfo: (TitleInfo *) titleInfo;
-(void)restore;

@end
