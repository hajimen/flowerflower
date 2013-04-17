//
//  InfoMasterViewController.h
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/16.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoMasterViewController : UITableViewController <UITableViewDelegate>

-(id)initWithSelectionHandler:(void (^)(UIViewController *viewController)) selectionHandler;

@end
