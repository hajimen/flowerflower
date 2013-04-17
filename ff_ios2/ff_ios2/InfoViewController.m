//
//  InfoViewController.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/16.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "InfoViewController.h"
#import "InfoMasterViewController.h"

@interface SplitViewControllerDelegate: NSObject <UISplitViewControllerDelegate>
@end

@interface InfoViewController ()

@property (nonatomic)UISplitViewController *splitVC;
@property (nonatomic)UINavigationController *nvc;
@property (nonatomic)InfoMasterViewController *infoMasterVC;
@property (nonatomic)SplitViewControllerDelegate *splitVCDelegate;

@end

@implementation SplitViewControllerDelegate

-(BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return NO;
}

@end

@implementation InfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _splitVC = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        _splitVC = [UISplitViewController new];
        _splitVCDelegate = [SplitViewControllerDelegate new];
        _splitVC.delegate = _splitVCDelegate;
        __weak InfoViewController *ws = self;
        _infoMasterVC = [[InfoMasterViewController alloc] initWithSelectionHandler:^(UIViewController *viewController) {
            if (ws) {
                ws.splitVC.viewControllers = @[ws.splitVC.viewControllers[0], viewController];
            }
        }];
        _splitVC.viewControllers = @[_infoMasterVC, [UIViewController new]];
        [self.view addSubview: _splitVC.view];
    } else {
        _nvc = [UINavigationController new];
        __weak InfoViewController *ws = self;
        _infoMasterVC = [[InfoMasterViewController alloc] initWithSelectionHandler:^(UIViewController *viewController) {
            if (ws) {
                [ws.nvc pushViewController: viewController animated: YES];
            }
        }];
        [_nvc pushViewController: _infoMasterVC animated: NO];
        [self.view addSubview: _nvc.view];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_splitVC) {
        NSIndexPath *ip = [NSIndexPath indexPathForItem: 0 inSection: 0];
        [_infoMasterVC tableView: _infoMasterVC.tableView didSelectRowAtIndexPath: ip];
        [_infoMasterVC.tableView selectRowAtIndexPath: ip animated: NO scrollPosition:UITableViewScrollPositionBottom];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
