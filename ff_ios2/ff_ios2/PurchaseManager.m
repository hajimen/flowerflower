//
//  Purchase.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/11.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "ReactiveCocoa/ReactiveCocoa.h"
#import "PurchaseManager.h"
#import "InAppPurchaseStore.h"

static PurchaseManager *instance = nil;

@implementation PurchaseManager

+(void)initialize {
    @synchronized(self) {
        if (instance == nil) {
            instance = [[PurchaseManager alloc] initOnce];
        }
    }
}

+(PurchaseManager *)instance {
    return instance;
}

-(id)initOnce {
    self = [super self];
    if (!self) {
        return self;
    }
    return self;
}

-(id)init {
    @throw @"PurchaseManager is singleton";
    return nil;
}

-(void)buy: (TitleInfo *) titleInfo {
    // TODO
}

-(void)restore {
    // TODO
}

-(BOOL)isAppInstalled:(NSString *)customUrlScheme {
    NSURL *u = [NSURL URLWithString: [NSString stringWithFormat: @"%@://", customUrlScheme]];
    return [[UIApplication sharedApplication] canOpenURL: u];
}

@end
