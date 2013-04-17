//
//  InfoViewController.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/16.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "InfoViewController.h"
#import "InfoMasterViewController.h"

@interface InfoViewController ()

@property (nonatomic)UISplitViewController *splitVC;

@end

@implementation InfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _splitVC = [UISplitViewController new];
    UIViewController *r_vc = [UIViewController new];
    __weak InfoViewController *ws = self;
    UITableViewController *l_vc = [[InfoMasterViewController alloc] initWithSelectionHandler:^(UIViewController *viewController) {
        ws.splitVC.viewControllers = @[ws.splitVC.viewControllers[0], viewController];
    }];
    _splitVC.viewControllers = @[l_vc, r_vc];
    [self.view addSubview: _splitVC.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
