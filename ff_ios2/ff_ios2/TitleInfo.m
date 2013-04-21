//
//  TitleInfo.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/03.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <NewsstandKit/NewsstandKit.h>
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "TitleInfo.h"
#import "UserDefaultsKey.h"
#import "AlertStorageStavation.h"

static NSMutableDictionary *instanceDic;
NSDecimalNumber *UNKNOWN_PRICE;

@implementation TitleInfo

+(void)initialize {
    instanceDic = [NSMutableDictionary new];
    @synchronized(self) {
        if (!UNKNOWN_PRICE) {
            UNKNOWN_PRICE = [NSDecimalNumber decimalNumberWithString: @"-1"];
        }
    }
}

+(TitleInfo *)instanceWithId: (NSString *)titleId {
    @synchronized(self) {
        TitleInfo *ti = [instanceDic valueForKey:titleId];
        if (!ti) {
            NSData *d = [[NSUserDefaults standardUserDefaults] dataForKey: [NSString stringWithFormat: UDK_TITLE_INFO_FORMAT, titleId]];
            if (d) {
                ti = [NSKeyedUnarchiver unarchiveObjectWithData: d];
            } else {
                ti = [[self alloc] initWithId: titleId];
            }
            [instanceDic setValue:ti forKey:titleId];
            [ti preparePersistence];
        }
        return ti;
    }
}

-(void)save {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSData *d = [NSKeyedArchiver archivedDataWithRootObject: self];
    [ud setObject: d forKey: [NSString stringWithFormat: UDK_TITLE_INFO_FORMAT, _titleId]];
}

-(void)preparePersistence {
    __weak TitleInfo *ws = self;
    [[RACSignal merge:@[RACAble(name), RACAble(tags), RACAble(status), RACAble(lastViewed), RACAble(lastUpdated), RACAble(thumbnailUrl), RACAble(footnote), RACAble(productId), RACAble(price), RACAble(priceLocale), RACAble(distributionUrl)]] subscribeNext:^(id _) {
        [ws save];
    }];
    [RACAble(purchased) subscribeNext:^(id _) {
        [ws save];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

-(id)initWithId: (NSString *)titleId {
    self = [super init];
    if (!self) {
        return self;
    }

    _titleId = titleId;

    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) {
        return self;
    }

    _titleId = [aDecoder decodeObjectForKey:@"titleId"];
    _name = [aDecoder decodeObjectForKey:@"name"];
    _tags = [aDecoder decodeObjectForKey:@"tags"];
    _status = [aDecoder decodeIntForKey:@"status"];
    _lastViewed = [aDecoder decodeObjectForKey:@"lastViewed"];
    _lastUpdated = [aDecoder decodeObjectForKey:@"lastUpdated"];
    _thumbnailUrl = [aDecoder decodeObjectForKey:@"thumbnailUrl"];
    _footnote = [aDecoder decodeObjectForKey:@"footnote"];
    
    _productId = [aDecoder decodeObjectForKey:@"productId"];
    _price = [aDecoder decodeObjectForKey:@"price"];
    _priceLocale = [aDecoder decodeObjectForKey:@"priceLocale"];
    _purchased = [aDecoder decodeIntForKey:@"purchased"];
    _distributionUrl = [aDecoder decodeObjectForKey:@"distributionUrl"];

    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_titleId forKey:@"titleId"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_tags forKey:@"tags"];
    [aCoder encodeInt:_status forKey:@"status"];
    [aCoder encodeObject:_lastViewed forKey:@"lastViewed"];
    [aCoder encodeObject:_lastUpdated forKey:@"lastUpdated"];
    [aCoder encodeObject:_thumbnailUrl forKey:@"thumbnailUrl"];
    [aCoder encodeObject:_footnote forKey:@"footnote"];

    [aCoder encodeObject:_productId forKey:@"productId"];
    [aCoder encodeObject:_price forKey:@"price"];
    [aCoder encodeObject:_priceLocale forKey:@"priceLocale"];
    [aCoder encodeInt:_purchased forKey:@"purchased"];
    [aCoder encodeObject:_distributionUrl forKey:@"distributionUrl"];
}

-(NKIssue *)issue {
    NKLibrary *lib = [NKLibrary sharedLibrary];
    return [lib issueWithName: _titleId];
}

-(NSURL *)thumbnailUrl {
    if (![_thumbnailUrl checkResourceIsReachableAndReturnError: nil]) {
        [[AlertStorageStavation new] show];
    }
    return _thumbnailUrl;
}

@end
