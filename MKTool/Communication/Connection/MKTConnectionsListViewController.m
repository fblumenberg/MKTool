// ///////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2012, Frank Blumenberg
//
// See License.txt for complete licensing and attribution information.
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// ///////////////////////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "IASKAppSettingsViewController.h"
#import "MBProgressHUD.h"

#import "UIActionSheet+BlocksKit.h"

#import "UIViewController+MGSplitViewController.h"

#import "MKTConnectionsListViewController.h"
#import "MKTConnectionViewController.h"
#import "InnerBand.h"
#import "MKTConnection.h"

@interface MKTConnectionsListViewController () <NSFetchedResultsControllerDelegate> {
  NSMutableArray *_objects;
  BOOL userDrivenDataModelChange;
}

@property(nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (void)addNewConnection;
- (void)showConnectionViewController:(MKTConnection *)connection;

@property(nonatomic, strong) UIBarButtonItem *spacer;
@property(nonatomic, strong) UIBarButtonItem *addButton;

@end

@implementation MKTConnectionsListViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize spacer, addButton;

- (id)init {
  self = [super initWithStyle:UITableViewStylePlain];
  if (self) {
    self.title = NSLocalizedString(@"Connections", @"MKTConnectionsListViewController title");
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
      self.clearsSelectionOnViewWillAppear = YES;
      self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.navigationItem.title = self.title;

  self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                 target:self
                                                                 action:@selector(addNewConnection)];
  self.addButton.style = UIBarButtonItemStyleBordered;


  self.spacer = [[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                               target:nil action:nil];

  [self setToolbarItems:[NSArray arrayWithObjects:
          self.editButtonItem,
          self.spacer,
          self.addButton,
          nil]];

  self.navigationController.toolbarHidden = NO;
  self.tableView.allowsSelectionDuringEditing = NO;
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  if (IB_IS_IPAD())
    [self.detailViewController popToRootViewControllerAnimated:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  } else {
    return YES;
  }
}


- (void)addNewConnection {

  MKTConnection *conn = [MKTConnection create];
  conn.name = NSLocalizedString(@"Connection", @"MKTConnection default name");
  conn.connectionClass = @"MKIpConnection";
  conn.address = @"127.0.0.1";
  conn.connectionData=@"";

  [[IBCoreDataStore mainStore] save];

  [self showConnectionViewController:conn];

}

- (void)doReindex {

  int i = 0;
  for (MKTConnection *r in [MKTConnection allOrderedBy:@"index" ascending:YES]) {
    r.indexValue = ++i;
  }
}

///////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table View
///////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
  return [sectionInfo numberOfObjects];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil)
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];

  [self configureCell:cell atIndexPath:indexPath];
  return cell;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

  MKTConnection *connection = [self.fetchedResultsController objectAtIndexPath:indexPath];
  cell.textLabel.text = connection.name;
  cell.imageView.image = [connection cellImage];
  if([connection.connectionClass isEqualToString:@"MKSimConnection"])
    cell.detailTextLabel.text = @"";
  else
    cell.detailTextLabel.text = connection.address;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  // Return NO if you do not want the specified item to be editable.
  return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {

    [[self.fetchedResultsController objectAtIndexPath:indexPath] destroy];
    [self doReindex];
    [[IBCoreDataStore mainStore] save];


  } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
  }
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {

  userDrivenDataModelChange = YES;

  NSMutableArray *array = [[self.fetchedResultsController fetchedObjects] mutableCopy];

  id objectToMove = [array objectAtIndex:fromIndexPath.row];
  [array removeObjectAtIndex:fromIndexPath.row];
  [array insertObject:objectToMove atIndex:toIndexPath.row];

  int i = 0;
  for (MKTConnection *conn in array) {
    conn.indexValue = ++i;
  }

  NSError *error;
  BOOL success = [self.fetchedResultsController performFetch:&error];
  if (!success) {
  }

  [[IBCoreDataStore mainStore] save];

  userDrivenDataModelChange = NO;

  [self.tableView reloadData];
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
  // Return NO if you do not want the item to be re-orderable.
  return YES;
}


- (void)showConnectionViewController:(MKTConnection *)connection {
  MKTConnectionViewController *controller = [[MKTConnectionViewController alloc] initWithConnection:connection];


  if (IB_IS_IPAD()) {
    BOOL animated = self.isRootForDetailViewController;
    [self.detailViewController popToRootViewControllerAnimated:NO];
    [self.detailViewController pushViewController:controller animated:animated];
  }
  else {
    [self.navigationController pushViewController:controller animated:YES];
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  if (!tableView.isEditing) {
    MKTConnection *conn = [self.fetchedResultsController objectAtIndexPath:indexPath];

    [self showConnectionViewController:conn];
  }
}


///////////////////////////////////////////////////////////////////////////////////
#pragma mark - Fetched results controller delegate
///////////////////////////////////////////////////////////////////////////////////

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
  if (userDrivenDataModelChange) return;
  [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {

  if (userDrivenDataModelChange) return;
  switch (type) {
    case NSFetchedResultsChangeInsert:
      [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
      break;

    case NSFetchedResultsChangeDelete:
      [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
      break;
  }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
  UITableView *tableView = self.tableView;

  if (userDrivenDataModelChange) return;
  switch (type) {

    case NSFetchedResultsChangeInsert:
      [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;

    case NSFetchedResultsChangeDelete:
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;

    case NSFetchedResultsChangeUpdate:
      NSLog(@"Update");
      [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
      break;

    case NSFetchedResultsChangeMove:
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
      [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
  }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
  if (userDrivenDataModelChange) return;
  [self.tableView endUpdates];
}


///////////////////////////////////////////////////////////////////////////////////
#pragma mark - Fetched results controller
///////////////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)fetchedResultsController {

  if (_fetchedResultsController != nil) {
    return _fetchedResultsController;
  }

  _fetchedResultsController = [MKTConnection fetchedResultsController];
  _fetchedResultsController.delegate = self;

  NSError *error = nil;
  if (![self.fetchedResultsController performFetch:&error]) {
    abort();
  }

  return _fetchedResultsController;
}

@end
