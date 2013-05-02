//
//  Purchase.h
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/22.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "Cordova/CDVPlugin.h"

@interface Purchase : CDVPlugin

- (void)purchase: (CDVInvokedUrlCommand *)command;

- (void)price: (CDVInvokedUrlCommand *)command;

@end
