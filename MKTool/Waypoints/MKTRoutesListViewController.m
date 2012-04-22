// ///////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2010, Frank Blumenberg
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

#import "MKTRoutesListViewController.h"

#import "MKTRouteContainerViewController.h"
#import "MKTRouteListViewController.h"

#import "InnerBand.h"
#import "MKTRoute.h"
#import "MKTPoint.h"

@interface MKTRoutesListViewController () <NSFetchedResultsControllerDelegate> {
  NSMutableArray *_objects;
  BOOL userDrivenDataModelChange;
}

@property(nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation MKTRoutesListViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize detailViewController = _detailViewController;

- (id)init {
  self = [super initWithStyle:UITableViewStylePlain];
  if (self) {
    self.title = NSLocalizedString(@"Routes", @"Routes Master title");
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
      self.clearsSelectionOnViewWillAppear = NO;
      self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  self.navigationItem.leftBarButtonItem = self.editButtonItem;

  UIBarButtonItem *reindexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                 target:self
                                                                                 action:@selector(manualMove:)];

  UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                             target:self
                                                                             action:@selector(insertNewObject:)];
  self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:addButton, reindexButton, nil];

  self.tableView.allowsMultipleSelectionDuringEditing = YES;

}

- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  } else {
    return YES;
  }
}

- (void)insertNewObject:(id)sender {
  MKTRoute *r = [MKTRoute create];
  r.name = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
  r.indexValue = [MKTRoute count];

  CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(50.123456, 9.123456);
  for (int i = 1; i < 10; i++) {
    MKTPoint *p = [r addPointAtCoordinate:coordinate];
    p.prefix = @"T";
    p.indexValue = i;
    p.altitudeValue = i;
  }

  [[CoreDataStore mainStore] save];
}

- (void)doReindex {

  int i = 0;
  for (MKTRoute *r in [MKTRoute allOrderedBy:@"index" ascending:YES]) {
    r.indexValue = ++i;
  }
}

- (void)reindex:(id)sender {
  userDrivenDataModelChange = YES;
  [self doReindex];
  [[CoreDataStore mainStore] save];
  userDrivenDataModelChange = NO;

  [self.tableView reloadData];
}

- (void)manualMove:(id)sender {
  NSMutableArray *array = [[self.fetchedResultsController fetchedObjects] mutableCopy];

  id objectToMove = [array objectAtIndex:1];
  [array removeObjectAtIndex:1];
  [array insertObject:objectToMove atIndex:3];

  int i = 0;
  for (MKTRoute *r in array) {
    r.indexValue = ++i;
  }

  [[CoreDataStore mainStore] save];
}

#pragma mark - Table View

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
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];

  [self configureCell:cell atIndexPath:indexPath];
  return cell;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }

  MKTRoute *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
  cell.textLabel.text = managedObject.name;
  cell.detailTextLabel.text = [managedObject.index description];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  // Return NO if you do not want the specified item to be editable.
  return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {

    [[self.fetchedResultsController objectAtIndexPath:indexPath] destroy];
    [self doReindex];
    [[CoreDataStore mainStore] save];


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
  for (MKTRoute *r in array) {
    r.indexValue = ++i;
  }

  NSError *error;
  BOOL success = [self.fetchedResultsController performFetch:&error];
  if (!success) {
  }

  [[CoreDataStore mainStore] save];

  userDrivenDataModelChange = NO;

  [self.tableView reloadData];
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
  // Return NO if you do not want the item to be re-orderable.
  return YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  if (!tableView.isEditing) {
    MKTRoute *route = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if(IS_IPAD()){
      MKTRouteListViewController *routeController = [[MKTRouteListViewController alloc] initWithRoute:route];
      [self.navigationController pushViewController:routeController animated:YES];
    }
    else       {
      MKTRouteContainerViewController *routeController = [[MKTRouteContainerViewController alloc] initWithRoute:route];
      [self.navigationController pushViewController:routeController animated:YES];
    }
  }
}


#pragma mark - Fetched results controller delegate

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


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {

  if (_fetchedResultsController != nil) {
    return _fetchedResultsController;
  }

  _fetchedResultsController = [MKTRoute fetchedResultsController];
  _fetchedResultsController.delegate = self;

  NSError *error = nil;
  if (![self.fetchedResultsController performFetch:&error]) {
    abort();
  }

  return _fetchedResultsController;
}

@end
