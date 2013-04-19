//
//  Foreground.h
//  ff_ios2
//
//  Created by 岩田 健一 on 13/03/26.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

@class TitleInfo;

#import <Foundation/Foundation.h>
#import "IASKAppSettingsViewController.h"

@interface Foreground : NSObject <IASKSettingsDelegate>

@property (nonatomic) UIWindow *window;

@property (nonatomic) UIViewController *viewController;

+(Foreground *)instance;

-(void)showTitle:(TitleInfo *)titleInfo;

@end
