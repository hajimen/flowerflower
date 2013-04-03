//
//  TitleInfo.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/03.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "TitleInfo.h"

@implementation TitleInfo

-(id)initWithId: (NSString *)titleId {
    self = [super init];
    if (!self) {
        return self;
    }

    _titleId = titleId;

    return self;
}


@end
