//
//  InfoMasterViewController.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/04/16.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "ReactiveCocoa/ReactiveCocoa.h"

#import "InfoMasterViewController.h"
#import "IASKAppSettingsViewController.h"
#import "ScrollableViewController.h"
#import "PurchaseManager.h"

@interface  RestoreViewController : ScrollableViewController
-(IBAction)restoreButtonTapped: (id)sender;
@property (nonatomic)PurchaseManager *purchaseManager;
@end

@implementation RestoreViewController

-(id)init {
    self = [super initWithNibName: @"RestoreView" bundle: [NSBundle mainBundle]];
    return self;
}

-(IBAction)restoreButtonTapped: (id)sender {
    NSLog(@"tapped");
    if (![[PurchaseManager instance] online]) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle: @"Not Online" message: @"Not online. Later please." delegate: nil cancelButtonTitle: @"Close" otherButtonTitles: nil];
        [av show];
        return;
    }
    [[PurchaseManager instance] restore];
}

@end

@interface  TagDescriptionViewController : ScrollableViewController
@end

@implementation TagDescriptionViewController

-(id)init {
    self = [super initWithNibName: @"TagDescriptionView" bundle: [NSBundle mainBundle]];
    return self;
}

@end

@interface AboutThisAppViewController : ScrollableViewController
@end

@implementation AboutThisAppViewController

-(id)init {
    self = [super initWithNibName: @"AboutThisAppView" bundle: [NSBundle mainBundle]];
    return self;
}

@end

@interface InfoMasterViewController ()

@property (nonatomic) NSArray *cells;
@property (nonatomic, strong) void (^selectionHandler)(UIViewController *viewController);

@end

@implementation InfoMasterViewController

-(id)initWithSelectionHandler:(void (^)(UIViewController *viewController)) selectionHandler {
    self = [self initWithStyle: UITableViewStylePlain];
    if (self) {
        _selectionHandler = selectionHandler;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _cells = @[@[@"Settings", [IASKAppSettingsViewController class]],
                   @[@"Restore", [RestoreViewController class]],
                   @[@"Tags", [TagDescriptionViewController class]],
                   @[@"About This App", [AboutThisAppViewController class]],
                   ];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_cells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
    }
    // Configure the cell...
    cell.textLabel.text = [[_cells objectAtIndex: indexPath.item] objectAtIndex: 0];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectionHandler([[[_cells objectAtIndex: indexPath.item] objectAtIndex: 1] new]);
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
