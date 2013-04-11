//
//  Purchase.h
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/11.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TitleInfo;

@interface PurchaseManager : NSObject

-(void)buy: (TitleInfo *) titleInfo;
-(void)restore;

@end
