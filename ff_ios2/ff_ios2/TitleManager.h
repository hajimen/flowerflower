//
//  TitleManager.h
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/05.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TitleInfo;
@class RACSignal;

@interface TitleManager : NSObject

@property (nonatomic, readonly) NSSet *titleInfoSet;

+(TitleManager *)instance;

-(TitleInfo *)titleInfoWithProductId:(NSString *)productId;

-(void)registerPushNotification: (TitleInfo *)titleInfo;

-(void)notifyUpdated:(TitleInfo *)titleInfo;

-(RACSignal *)updateSignal:(TitleInfo *)titleInfo;

@end
