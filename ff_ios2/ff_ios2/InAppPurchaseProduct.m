//
//  InAppPurchaseProduct.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/03/29.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "InAppPurchaseProduct.h"

@implementation InAppPurchaseProduct

-(NSString *)description {
    return [NSString stringWithFormat:@"localizedDescription: %@ localizedTitle: %@ price: %@ priceLocale: %@ productIdentifier: %@", _localizedDescription, _localizedTitle, _price, _priceLocale, _productIdentifier];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) return self;

    _localizedDescription = [aDecoder decodeObjectForKey:@"localizedDescription"];
    _localizedTitle = [aDecoder decodeObjectForKey:@"localizedTitle"];
    _price = [aDecoder decodeObjectForKey:@"price"];
    _priceLocale = [aDecoder decodeObjectForKey:@"priceLocale"];
    _productIdentifier = [aDecoder decodeObjectForKey:@"productIdentifier"];

    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_localizedDescription forKey:@"localizedDescription"];
    [aCoder encodeObject:_localizedTitle forKey:@"localizedTitle"];
    [aCoder encodeObject:_price forKey:@"price"];
    [aCoder encodeObject:_priceLocale forKey:@"priceLocale"];
    [aCoder encodeObject:_productIdentifier forKey:@"productIdentifier"];
}

@end
