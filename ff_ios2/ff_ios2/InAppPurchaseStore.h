//
//  InAppPurchaseStore.h
//  ff_ios2
//
//  Created by 岩田 健一 on 13/03/29.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface InAppPurchaseStore : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

-(id)initWithRunningTransaction:(BOOL)running onPurchase:(void (^)(NSString *productId, NSData *receiptData)) purchaseBlock onFailed:(void (^)(NSError *error)) failBlock onRestore:(void (^)(NSString *productId, NSData *receiptData)) restoreBlock;

-(void)buyWithProductId:(NSString *)productId;
-(void)checkOnline;
-(void)restore;

@property (nonatomic, readonly) BOOL online;
@property (nonatomic, readonly) BOOL transactionRunning;
@property (nonatomic, readonly) BOOL restoreRunning;
@property (nonatomic, readonly) NSDate *lastUpdated;

@end
