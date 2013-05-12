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

#import "MKTGpxLoggingListViewController.h"

#import "InnerBand.h"
#import "MKTGpxSession.h"
#import "MKTGpxRecord.h"
#import "MKTGpxSessionViewController.h"

@interface MKTGpxLoggingListViewController () <NSFetchedResultsControllerDelegate> {
  NSMutableArray *_objects;
  BOOL userDrivenDataModelChange;
}

@property(nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

//- (void)showRouteViewController:(MKTRoute *)route;

//- (void)syncRoutes;

- (void)deleteSelectedSession;

@property(nonatomic, strong) UIBarButtonItem *spacer;
@property(nonatomic, strong) UIBarButtonItem *deleteButton;
@property(nonatomic, strong) UIBarButtonItem *syncButton;

@end

@implementation MKTGpxLoggingListViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize spacer,syncButton,deleteButton;

- (id)init {
  self = [super initWithStyle:UITableViewStylePlain];
  if (self) {
    self.title = NSLocalizedString(@"GPX-Loggin", @"GPX-Logging List title");
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
  
  self.deleteButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Delete", @"Delete toolbar button") style:UIBarButtonItemStyleBordered
                                                      target:self action:@selector(deleteSelectedSession)];
  self.deleteButton.tintColor = [UIColor redColor];

  
  self.syncButton = [[UIBarButtonItem alloc]
                      initWithImage:[UIImage imageNamed:@"icon-backforth.png"]
                      style:UIBarButtonItemStyleBordered
                      target:self
                      action:@selector(syncRoutes)];

  self.spacer = [[UIBarButtonItem alloc]
                   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                   target:nil action:nil];

  [self setToolbarItems:@[self.editButtonItem]];
  
  self.navigationController.toolbarHidden =NO;
  self.tableView.allowsSelectionDuringEditing = NO;
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  
  [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  } else {
    return YES;
  }
}

- (void)updateToolbar {
  
  NSMutableArray *tbArray = [NSMutableArray array];
  
  [tbArray addObject:self.editButtonItem];
  [tbArray addObject:self.spacer];
  
  
  if (self.tableView.isEditing) {
    [tbArray addObject:self.deleteButton];
  }
  
  [self setToolbarItems:tbArray];
  
  [self updateToolbarState];
}

- (void)updateToolbarState {
  if (self.isEditing) {
    NSUInteger count = [self.tableView indexPathsForSelectedRows].count;
    BOOL hasSelection = count > 0;
    
    self.deleteButton.enabled = hasSelection;
    
    if (hasSelection) {
      self.deleteButton.title = [NSString stringWithFormat:NSLocalizedString(@"Delete(%d)", @"Delete toolbar button"), count];
    }
    else {
      self.deleteButton.title = NSLocalizedString(@"Delete", @"Delete toolbar button");
    }
  }
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
  
  self.tableView.allowsMultipleSelectionDuringEditing = editing;
  [super setEditing:editing animated:animated];
  [self.tableView setEditing:editing animated:animated];
  
  [self updateToolbar];
}


- (void)deleteSelectedSession {
  
  for (NSIndexPath* indexPath in [self.tableView indexPathsForSelectedRows]) {
    MKTGpxSession* session = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [session destroy];
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
  
  MKTGpxSession *session = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  cell.textLabel.text = [NSDateFormatter localizedStringFromDate:session.startTime dateStyle:kCFDateFormatterShortStyle timeStyle:kCFDateFormatterNoStyle];
  
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ –– %@ (%d)",
                               [NSDateFormatter localizedStringFromDate:session.startTime dateStyle:kCFDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle],
                               [NSDateFormatter localizedStringFromDate:session.endTime dateStyle:kCFDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle],
                               [session.records count]];
  
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  // Return NO if you do not want the specified item to be editable.
  return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {

    [[self.fetchedResultsController objectAtIndexPath:indexPath] destroy];
    [[CoreDataStore mainStore] save];

  }
  else if (editingStyle == UITableViewCellEditingStyleInsert) {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
  }
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
  // Return NO if you do not want the item to be re-orderable.
  return NO;
}

- (void)showSessionViewController:(MKTGpxSession *)session {
  
  MKTGpxSessionViewController* sessionViewController = [[MKTGpxSessionViewController alloc] initWithSession:session];
  
  UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
  
  
  if ([rootViewController isKindOfClass:[UINavigationController class]]) {
    [(UINavigationController *) rootViewController pushViewController:sessionViewController animated:YES];
  }
  else if ([rootViewController isKindOfClass:[MGSplitViewController class]]) {
    
    MGSplitViewController *splitViewController = (MGSplitViewController *) rootViewController;
    
    UIViewController *controller = splitViewController.detailViewController;
    if ([controller isKindOfClass:[UINavigationController class]]) {
      controller.navigationItem.hidesBackButton = YES;
      
      [(UINavigationController *) controller popToRootViewControllerAnimated:NO];
      [(UINavigationController *) controller pushViewController:sessionViewController animated:YES];
    }
  }
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self updateToolbarState];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  if (!tableView.isEditing) {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MKTGpxSession* session = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self showSessionViewController:session];
  }

  [self updateToolbarState];
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
    NSLog(@"fetchedResultsController return %@",_fetchedResultsController);
    return _fetchedResultsController;
  }

  _fetchedResultsController = [MKTGpxSession fetchedResultsController];
  _fetchedResultsController.delegate = self;

  NSLog(@"fetchedResultsController create %@",_fetchedResultsController);

  NSError *error = nil;
  if (![self.fetchedResultsController performFetch:&error]) {
    abort();
  }

  return _fetchedResultsController;
}

///////////////////////////////////////////////////////////////////////////////////
#pragma mark - Synchronizing
///////////////////////////////////////////////////////////////////////////////////

@end
