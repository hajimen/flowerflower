//
//  AuthCookie.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/09.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "AuthCookie.h"
#import "TitleInfo.h"
#import "UserDefaultsKey.h"

@interface AuthCookie()

@property (nonatomic) TitleInfo* titleInfo;

@end


@implementation AuthCookie

-(id)initWithTitleInfo: (TitleInfo *)titleInfo {
    self = [super init];
    if (!self) {
        return self;
    }

    _titleInfo = titleInfo;
    
    return self;
}

-(void)setCookies:(NSArray *)cookies {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSData *d = [NSKeyedArchiver archivedDataWithRootObject: cookies];
    [ud setObject: d forKey: [NSString stringWithFormat: UDK_AUTH_COOKIE_FORMAT, _titleInfo.titleId]];
}

-(void)setCookiesWithResponse: (NSURLResponse *)response {
    NSDictionary *headerFields = [(NSHTTPURLResponse *)response allHeaderFields];
    NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields: headerFields forURL: _titleInfo.distributionUrl];
    [self setCookies: cookies];
}

-(NSArray *)cookies {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSData *d = [ud objectForKey: [NSString stringWithFormat: UDK_AUTH_COOKIE_FORMAT, _titleInfo.titleId]];
    if (d) {
        @try {
            NSArray *a = [NSKeyedUnarchiver unarchiveObjectWithData:d];
            return a;
        }
        @catch (NSException *exception) {
            NSLog(@"auth cookie restore failed.");
        }
    } else {
        return @[];
    }
}

@end
