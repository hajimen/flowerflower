//
//  InAppPurchaseProduct.h
//  ff_ios2
//
//  Created by 岩田 健一 on 13/03/29.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InAppPurchaseProduct : NSObject <NSCoding>

@property (nonatomic) NSString *localizedDescription;
@property (nonatomic) NSString *localizedTitle;
@property (nonatomic) NSDecimalNumber *price;
@property (nonatomic) NSLocale *priceLocale;
@property (nonatomic) NSString *productIdentifier;

@end
