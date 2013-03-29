//
//  InAppPurchaseStore.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/03/29.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "ReactiveCocoa/ReactiveCocoa.h"

#import "InAppPurchaseStore.h"
#import "InAppPurchaseProduct.h"

#define PLIST_KEY_NON_CONSUMABLE @"Non-Consumables"
#define PLIST_KEY_FREE_SUBSCRIPTION @"Free-Subscriptions"

#define PKEY_LAST_UPDATED @"InAppPurchaseStore.lastUpdated"
#define PKEY_PRODUCT_DIC @"InAppPurchaseStore.productDic"
#define PRODUCT_UPDATE_INTERVAL 60.0 * 60.0

@interface InAppPurchaseStore ()

@property (nonatomic) NSSet *nonConsumableProductIds;
@property (nonatomic) NSSet *freeSubscriptionProductIds;
@property (nonatomic) NSMutableDictionary *productMDic;
@property (nonatomic) SKProductsRequest *productsRequest;
@property (nonatomic) NSMutableDictionary *skProductMDic;
@property (nonatomic, strong) void (^onTransactionFailed)(NSError *error);
@property (nonatomic, strong) void (^onTransactionPurchased)(NSString *productId, NSData* receiptData);
@property (nonatomic, strong) void (^onTransactionRestored)(NSString *productId, NSData* receiptData);

@end

@implementation InAppPurchaseStore

-(id)initWithRunningTransaction:(BOOL)running plist:(NSString *)plist onPurchase:(void (^)(NSString *productId, NSData *receiptData)) purchaseBlock onFailed:(void (^)(NSError *error)) failBlock onRestore:(void (^)(NSString *productId, NSData *receiptData)) restoreBlock {
    self = [super init];
    if (!self) {
        return self;
    }

    _onTransactionPurchased = purchaseBlock;
    _onTransactionFailed = failBlock;
    _onTransactionRestored = restoreBlock;

    if (!running) {
        SKPaymentQueue *q = [SKPaymentQueue defaultQueue];
        NSArray *ts = [q transactions];
        for (SKPaymentTransaction *t in ts) {
            [q finishTransaction:t];
        }
    }

    _online = NO;
    _transactionRunning = running;
    NSDictionary *productIdPlistDic = [NSDictionary dictionaryWithContentsOfFile:
                                       [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:
                                        plist]];
    _nonConsumableProductIds = [NSSet setWithArray:[productIdPlistDic objectForKey:PLIST_KEY_NON_CONSUMABLE]];
    _freeSubscriptionProductIds = [NSSet setWithArray:[productIdPlistDic objectForKey:PLIST_KEY_FREE_SUBSCRIPTION]];

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    _productMDic = [NSMutableDictionary new];
    _skProductMDic = [NSMutableDictionary new];
    _lastUpdated = [ud objectForKey:PKEY_LAST_UPDATED];
    if (_lastUpdated) {
        NSData *d = [ud objectForKey: PKEY_PRODUCT_DIC];
        if (d) {
            @try {
                NSMutableDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:d];
                [_productMDic setDictionary:[dic mutableCopy]];
                NSLog(@"_productMDic restored: %@", _productMDic);
            }
            @catch (NSException *exception) {
                _lastUpdated = nil;
                NSLog(@"_productMDic restore failed.");
            }
        }
    }
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver: self];

    NSSet *s = [self.freeSubscriptionProductIds setByAddingObjectsFromSet: self.nonConsumableProductIds];
    
	_productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers: s];
	_productsRequest.delegate = self;
	[_productsRequest start];
    [[RACSignal interval: PRODUCT_UPDATE_INTERVAL] subscribeNext:^(NSDate *date) {
        [_productsRequest start];
    }];

    return self;
}

-(void)checkOnline {
	[_productsRequest start];
}

-(NSDictionary *)productDic {
    return _productMDic;
}

-(void)setOnline:(BOOL)online {
    [self willChangeValueForKey:@"online"];
    _online = online;
    [self didChangeValueForKey:@"online"];
}

-(void)setTransactionRunning:(BOOL)transactionRunning {
    [self willChangeValueForKey:@"transactionRunning"];
    _transactionRunning = transactionRunning;
    [self didChangeValueForKey:@"transactionRunning"];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
//    [self willChangeValueForKey:@"productDic"];
    for (SKProduct *skp in [response products]) {
        InAppPurchaseProduct *p = [InAppPurchaseProduct new];
        p.localizedDescription = [skp localizedDescription];
        p.localizedTitle = [skp localizedTitle];
        p.price = [skp price];
        p.priceLocale = [skp priceLocale];
        p.productIdentifier = [skp productIdentifier];
        NSString *k = [p productIdentifier];
        [_productMDic setObject:p forKey: k];
        [_skProductMDic setObject:skp forKey:k];
    }
    [_productMDic removeObjectsForKeys:[response invalidProductIdentifiers]];
    [_skProductMDic removeObjectsForKeys:[response invalidProductIdentifiers]];
//    [self didChangeValueForKey:@"productDic"];
    
    [self willChangeValueForKey:@"lastUpdated"];
    _lastUpdated = [NSDate date];
    [self didChangeValueForKey:@"lastUpdated"];

    NSLog(@"storekit response: %@", _productMDic);

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSData *d = [NSKeyedArchiver archivedDataWithRootObject:_productMDic];
    [ud setObject:d forKey: PKEY_PRODUCT_DIC];
    [ud setObject:_lastUpdated forKey: PKEY_LAST_UPDATED];

    [self setOnline: YES];
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    [self setOnline: NO];
}

-(void)buy:(NSString *)productId {
    if (![SKPaymentQueue canMakePayments]) {
        NSLog(@"cannot make payments");
        return;
    }
    if (_transactionRunning) {
        NSLog(@"another transaction running");
        return;
    }
    if (!_online) {
        NSLog(@"offline");
        return;
    }
    
    SKProduct *skp = [_skProductMDic objectForKey:productId];
    if (!skp) {
        NSLog(@"bad productId");
        return;
    }

    SKPayment *payment = [SKPayment paymentWithProduct: skp];

    [self setTransactionRunning: YES];
	[[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
	for (SKPaymentTransaction *transaction in transactions) {
		switch (transaction.transactionState) {
			case SKPaymentTransactionStatePurchasing:
                continue;
				
			case SKPaymentTransactionStatePurchased:
                [self onTransactionPurchased](transaction.payment.productIdentifier, transaction.transactionReceipt);
                break;
				
            case SKPaymentTransactionStateFailed:
                [self onTransactionFailed](transaction.error);
                break;
				
            case SKPaymentTransactionStateRestored:
                [self onTransactionRestored](transaction.payment.productIdentifier, transaction.transactionReceipt);
                break;
				
            default:
                NSLog(@"unknown SKPaymentTransactionState");
                break;
		}
        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
	}
    [self setTransactionRunning: NO];
}


@end
