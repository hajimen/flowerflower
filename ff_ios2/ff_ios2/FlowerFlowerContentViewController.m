//
//  FlowerFlowerContentViewController.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/20.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "ReactiveCocoa/ReactiveCocoa.h"
#import "SVProgressHUD.h"

#import "FlowerFlowerContentViewController.h"
#import "ScaleChanger.h"
#import "UserDefaultsKey.h"
#import "TitleInfo.h"
#import "TitleManager.h"
#import "HtmlDownloadDelegate.h"

@interface FlowerFlowerContentViewController () {
    BOOL settingsChanged;
}

@end

@implementation FlowerFlowerContentViewController

+(void)initialize {
//    [[NSURLCache sharedURLCache] setMemoryCapacity: 0];
}

-(id)initWithTitleInfo: (TitleInfo *)titleInfo {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self = [super init];
    if (!self) {
        return self;
    }

    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(userDefaultChanged) name: NSUserDefaultsDidChangeNotification object: nil];

    settingsChanged = NO;

    self.wwwFolderName = [titleInfo.depot absoluteString];
    self.startPage = titleInfo.contentHtmlPath;
    self.view.frame = [[UIScreen mainScreen] bounds];

    [self rac_liftSelector: @selector(contentUpdated:) withObjects: [[TitleManager instance] updateSignal: titleInfo]];

    _titleInfo = titleInfo;
    
    return self;
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *url = [[request URL] absoluteString];
    if ([url hasPrefix: [_titleInfo.distributionUrl absoluteString]]) {
        NSString *path = [url substringFromIndex: [[_titleInfo.distributionUrl absoluteString] length]];
        NSURL *storeTo = [_titleInfo.depot URLByAppendingPathComponent: path];
        HtmlDownloadDelegate *hdd = [[HtmlDownloadDelegate alloc] initWithUrl: [request URL] storeTo: storeTo];
        NSURLRequest *nr = [NSURLRequest requestWithURL: storeTo];
        __weak FlowerFlowerContentViewController *ws = self;
        [[[hdd start] deliverOn: RACScheduler.mainThreadScheduler] subscribeError:^(NSError *error) {
            if ([storeTo checkResourceIsReachableAndReturnError: nil]) {
                [ws.webView loadRequest: nr];
            } else {
                [SVProgressHUD showErrorWithStatus: NSLocalizedString(@"Cannot connect to distribution server.", nil)];
            }
        } completed:^{
            [ws.webView loadRequest: nr];
        }];
        return NO;
    } else if ([url hasPrefix: @"http:"] || [url hasPrefix: @"https:"]){
        [[UIApplication sharedApplication] openURL: [request URL]];
        return NO;
    } else {
        return [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
}

-(void)contentUpdated:(id) _ {
    __weak FlowerFlowerContentViewController *ws = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (ws) {
            [ws.webView stringByEvaluatingJavaScriptFromString: @"window.ff.FireUpdate(0);"];
        }
    });
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

-(BOOL)shouldAutorotate {
    return [[NSUserDefaults standardUserDefaults] boolForKey: UDK_AUTO_ROTATE_SWITCH];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return [self shouldAutorotate];
}

-(void)userDefaultChanged {
    settingsChanged = YES;
}

-(void)syncSettings {
    if (settingsChanged) {
        [self scaleChanged];
        settingsChanged = NO;
    }
}

- (void)didRotateFromInterfaceOrientation: (UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    [self.webView stringByEvaluatingJavaScriptFromString:
     [NSString stringWithFormat:
      @"document.querySelector('meta[name=viewport]').setAttribute('content', 'width=%d;', false); ",
      (int)self.webView.frame.size.width]];
    [self scaleChanged];
}

-(void)scaleChanged {
    [(ScaleChanger *)[self getCommandInstance:@"org.kaoriha.phonegap.plugins.scalechanger"] scaleChanged];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end
