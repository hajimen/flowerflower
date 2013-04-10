//
//  AssetDownloadDelegate.h
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/10.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NKAssetDownload;
@class RACSignal;

@interface AssetDownloadDelegate : NSObject <NSURLConnectionDownloadDelegate>

-(id)initWithAssetDownload: (NKAssetDownload *)assetDwonload finishing:(NSURL * (^)(NSURL *storedTo, NSObject *jsonObj))finishing;

-(RACSignal *)start;

@end
