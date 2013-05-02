//
//  InAppPurchaseStore.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/03/29.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "ReactiveCocoa/ReactiveCocoa.h"

#import "InAppPurchaseStore.h"
#import "TitleManager.h"
#import "TitleInfo.h"

#define PKEY_LAST_UPDATED @"InAppPurchaseStore.lastUpdated"
#define PRODUCT_UPDATE_INTERVAL 60.0 * 60.0
#define TRANSACTION_TIMEOUT 5.0

@interface InAppPurchaseStore () {
    BOOL transactionResumed;
}

@property (nonatomic) NSMutableDictionary *skProductMDic;
@property (nonatomic, strong) void (^onTransactionFailed)(NSError *error);
@property (nonatomic, strong) void (^onTransactionPurchased)(NSString *productId, NSData* receiptData);
@property (nonatomic, strong) void (^onTransactionRestored)(NSString *productId, NSData* receiptData);

@end

@implementation InAppPurchaseStore

-(id)init {
    @throw @"InAppPurchaseStore is singleton";
    return nil;
}

-(id)initWithRunningTransaction:(BOOL)running onPurchase:(void (^)(NSString *productId, NSData *receiptData)) purchaseBlock onFailed:(void (^)(NSError *error)) failBlock onRestore:(void (^)(NSString *productId, NSData *receiptData)) restoreBlock {
    self = [super init];
    if (!self) {
        return self;
    }

    _onTransactionPurchased = purchaseBlock;
    _onTransactionFailed = failBlock;
    _onTransactionRestored = restoreBlock;

    _online = NO;
    _restoreRunning = NO;
    _transactionRunning = running;
    transactionResumed = running;

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    _skProductMDic = [NSMutableDictionary new];
    _lastUpdated = [ud objectForKey:PKEY_LAST_UPDATED];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver: self];

    // singleton and forever exists. no leaks.
    [[RACSignal interval: PRODUCT_UPDATE_INTERVAL] subscribeNext:^(NSDate *date) {
        [self checkOnline];
    }];

    if (transactionResumed) {
        [self performSelector: @selector(checkResumedTransaction) withObject: nil afterDelay:TRANSACTION_TIMEOUT];
    }

    [self checkOnline];

    return self;
}

-(void)checkOnline {
    NSMutableSet *pids = [NSMutableSet new];
    for (TitleInfo *ti in [[TitleManager instance] titleInfoSet]) {
        if ([ti productId]) {
            [pids addObject: [ti productId]];
        }
    }
	SKProductsRequest *pr = [[SKProductsRequest alloc] initWithProductIdentifiers: pids];
	pr.delegate = self;
	[pr start];
}

-(void)checkResumedTransaction {
    if (transactionResumed) {
        self.transactionRunning = NO;
    }
}

-(void)setOnline:(BOOL)online {
    [self willChangeValueForKey:@"online"];
    _online = online;
    [self didChangeValueForKey:@"online"];
}

-(void)setTransactionRunning:(BOOL)transactionRunning {
    [self willChangeValueForKey:@"transactionRunning"];
    _transactionRunning = transactionRunning;
    transactionResumed = NO;
    [self didChangeValueForKey:@"transactionRunning"];
}

-(void)setRestoreRunning:(BOOL)restoreRunning {
    [self willChangeValueForKey:@"restoreRunning"];
    _restoreRunning = restoreRunning;
    [self didChangeValueForKey:@"restoreRunning"];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    _skProductMDic = [NSMutableDictionary new];
    for (SKProduct *skp in [response products]) {
        NSString *pid = [skp productIdentifier];
        TitleInfo *ti = nil;
        for (TitleInfo *iti in [[TitleManager instance] titleInfoSet]) {
            if ([pid isEqualToString: [iti productId]]) {
                ti = iti;
                break;
            }
        }
        if (ti == nil) {
            NSLog(@"InAppPurchaseStore productsRequest received unknown productId: %@", [skp productIdentifier]);
            continue;
        }
        ti.price = [skp price];
        ti.priceLocale = [skp priceLocale];
        [_skProductMDic setObject:skp forKey: pid];
    }
    
    [self willChangeValueForKey:@"lastUpdated"];
    _lastUpdated = [NSDate date];
    [self didChangeValueForKey:@"lastUpdated"];

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:_lastUpdated forKey: PKEY_LAST_UPDATED];

    [self setOnline: YES];
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    [self setOnline: NO];
}

-(void)buyWithProductId:(NSString *)productId {
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

-(void)restore {
    [self setRestoreRunning: YES];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
	for (SKPaymentTransaction *transaction in transactions) {
		switch (transaction.transactionState) {
			case SKPaymentTransactionStatePurchasing:
                break;
				
			case SKPaymentTransactionStatePurchased:
                [self onTransactionPurchased](transaction.payment.productIdentifier, transaction.transactionReceipt);
                [queue finishTransaction: transaction];
                [self setTransactionRunning: NO];
                break;
				
            case SKPaymentTransactionStateFailed:
                [self onTransactionFailed](transaction.error);
                [queue finishTransaction: transaction];
                [self setTransactionRunning: NO];
                break;
				
            case SKPaymentTransactionStateRestored:
                break;
				
            default:
                NSLog(@"unknown SKPaymentTransactionState");
                break;
		}
	}
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    NSLog(@"paymentQueueRestoreCompletedTransactionsFinished");
    for (SKPaymentTransaction *t in queue.transactions) {
        NSLog(@"transaction %@", t);
        [self onTransactionRestored](t.payment.productIdentifier, t.transactionReceipt);
        [queue finishTransaction:t];
    }
    [self setRestoreRunning: NO];
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    NSLog(@"restoreCompletedTransactionsFailedWithError %@", error);
    for (SKPaymentTransaction *t in queue.transactions) {
        NSLog(@"transaction %@", t);
        [queue finishTransaction:t];
    }
    [self setRestoreRunning: NO];
}

@end
