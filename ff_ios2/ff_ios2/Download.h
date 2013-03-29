//
//  Download.h
//  ff_ios2
//
//  Created by 岩田 健一 on 13/03/26.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Download : NSObject <NSURLConnectionDownloadDelegate>

-(void)resume;

@end
