//
//  AuthCookie.h
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/09.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TitleInfo;

@interface AuthCookie : NSObject

@property (nonatomic) NSArray *cookies;

-(id)initWithTitleInfo: (TitleInfo *)titleInfo;
-(void)setCookiesWithResponse: (NSURLResponse *)response;
-(void)setCookiesWithUrl: (NSURL *)url;

@end
