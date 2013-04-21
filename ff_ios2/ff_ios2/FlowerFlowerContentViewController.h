//
//  FlowerFlowerContentViewController.h
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/20.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "Cordova/CDVViewController.h"

@class TitleInfo;

@interface FlowerFlowerContentViewController : CDVViewController

-(void)syncSettings;
-(id)initWithTitleInfo: (TitleInfo *)titleInfo;

@end
