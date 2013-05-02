//
//  Purchase.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/22.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "Purchase.h"
#import "PurchaseManager.h"
#import "TitleInfo.h"
#import "FlowerFlowerContentViewController.h"
#import "Foreground.h"

@implementation Purchase

- (void)purchase: (CDVInvokedUrlCommand *)command {
    [[Foreground instance] dismissCdvViewController];

    FlowerFlowerContentViewController *ffcvc = (FlowerFlowerContentViewController *)self.viewController;
    [[PurchaseManager instance] buyWithTitleInfo: ffcvc.titleInfo];
}

- (void)price: (CDVInvokedUrlCommand *)command {
    FlowerFlowerContentViewController *ffcvc = (FlowerFlowerContentViewController *)self.viewController;
    
    NSString *buttonText = nil;
    if ([[PurchaseManager instance] online]) {
        NSNumberFormatter *nf = [NSNumberFormatter new];
        nf.numberStyle = NSNumberFormatterCurrencyStyle;
        nf.locale = ffcvc.titleInfo.priceLocale;
        NSDecimalNumber *p = ffcvc.titleInfo.price;
        if ([p isEqualToNumber: UNKNOWN_PRICE]) {
            buttonText = @"---";
        } else {
            buttonText = [nf stringFromNumber: ffcvc.titleInfo.price];
        }
    } else {
        buttonText = NSLocalizedString(@"Offline", nil);
    }

    CDVPluginResult *r = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsString: buttonText];
    [self.commandDelegate sendPluginResult: r callbackId: command.callbackId];
}

@end
