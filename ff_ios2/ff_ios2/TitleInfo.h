//
//  TitleInfo.h
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/03.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TitleStatus) {
    TitleStatusOnAir,
    TitleStatusPushEnabled,
    TitleStatusCompleted
};

@interface TitleInfo : NSObject

@property (nonatomic, readonly) NSString *titleId;
@property (nonatomic) NSString *name;
@property (nonatomic) NSArray *tags;
@property (nonatomic) TitleStatus status;
@property (nonatomic) NSDate *lastViewed;
@property (nonatomic) NSDate *lastUpdated;
@property (nonatomic) NSURL *thumbnailUrl;
@property (nonatomic) NSString *footnote;

@property (nonatomic) NSDecimalNumber *price;   // nil if free
@property (nonatomic) NSLocale *priceLocale;
@property (nonatomic) BOOL purchased;
@property (nonatomic) NSString *productId;

+(TitleInfo *)instanceWithId: (NSString *)titleId;

@end

