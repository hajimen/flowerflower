//
//  AlertAuthError.h
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/15.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertAuthError : NSObject <UIAlertViewDelegate>

// response code 403
-(void)showWithUrl: (NSURL *)url;

@end
