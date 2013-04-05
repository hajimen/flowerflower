//
//  TitleManager.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/05.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "ReactiveCocoa/ReactiveCocoa.h"
#import "EXTScope.h"
#import "TitleManager.h"
#import "TitleInfo.h"

static TitleManager *_instance = nil;

@interface TitleManager () {
    NSMutableSet *_titleInfoSet;
}

@end


@implementation TitleManager

+(void)initialize {
    @synchronized(self) {
        if (!_instance) {
            _instance = [[self alloc] initOnce];
        }
    }
}

+(TitleManager *)instance {
    return _instance;
}

-(id)init {
    @throw @"TitleManager is singleton.";
    return nil;
}

-(id)initOnce {
    self = [super init];
    if (!self) {
        return self;
    }
    
    _titleInfoSet = [NSMutableSet new];

    //debug
    NSString *p = [[NSBundle mainBundle] pathForResource:@"test_image2" ofType:@"png"];
    TitleInfo *ti = [TitleInfo instanceWithId:@"test"];
    ti.thumbnailUrl = [NSURL fileURLWithPath: p];
    ti.name = @"My Name";
    ti.tags = @[@"my tag", @"my tag 2", @"my tag 33"];
    ti.price = [NSDecimalNumber decimalNumberWithString:@"1000"];
    ti.priceLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"];
    ti.purchased = NO;
    ti.status = TitleStatusPushEnabled;
    ti.footnote = @"初回購入特別価格";
    ti.lastViewed = [NSDate dateWithTimeIntervalSinceNow:-100];
    ti.lastUpdated = [NSDate dateWithTimeIntervalSinceNow:-90];
    [_titleInfoSet addObject:ti];

    p = [[NSBundle mainBundle] pathForResource:@"test_image" ofType:@"png"];
    TitleInfo *ti2 = [TitleInfo instanceWithId:@"test2"];
    ti2.thumbnailUrl = [NSURL fileURLWithPath: p];
    ti2.name = @"東京特許許可局 東京特許許可局 東京特許許可局";
    ti2.tags = @[@"tag a", @"tag b", @"tag c", @"tag d", @"tag e", @"tag f", @"tag g"];
    ti2.price = nil;
    ti2.purchased = NO;
    ti2.status = TitleStatusPushEnabled;
    ti2.footnote = nil;
    ti2.lastViewed = [NSDate dateWithTimeIntervalSinceNow:-70];
    ti2.lastUpdated = [NSDate dateWithTimeIntervalSinceNow:-80];
    [_titleInfoSet addObject:ti2];

    __block BOOL w = YES;
    {
    @weakify(self)
    [[[RACSignal interval:2] take:1] subscribeNext:^(id noop) {
        NSLog(@"TitleManager tick");
/*
        if (w) {
            ti.lastViewed = [NSDate dateWithTimeIntervalSinceNow:-60];
        } else {
            ti2.lastViewed = [NSDate dateWithTimeIntervalSinceNow:-60];
        }
        w = !w;
*/

        @strongify(self)
        TitleInfo *ti3 = [TitleInfo instanceWithId:@"test3"];
        ti3.thumbnailUrl = [NSURL fileURLWithPath: p];
        ti3.name = @"Test Title";
        ti3.tags = @[@"tag A"];
        ti3.price = nil;
        ti3.purchased = NO;
        ti3.status = TitleStatusPushEnabled;
        ti3.footnote = nil;
        ti3.lastViewed = [NSDate dateWithTimeIntervalSinceNow:-80];
        ti3.lastUpdated = [NSDate dateWithTimeIntervalSinceNow:-70];
        NSLog(@"TitleManager 1");
        [self willChangeValueForKey:@"titleInfoSet"];
        NSLog(@"TitleManager 2");
        [_titleInfoSet addObject:ti3];
        NSLog(@"TitleManager 3");
        [self didChangeValueForKey:@"titleInfoSet"];
        NSLog(@"TitleManager 4");

    }];
    }

    return self;
}

-(NSSet *)titleInfoSet {
    return [_titleInfoSet copy];
}

@end
