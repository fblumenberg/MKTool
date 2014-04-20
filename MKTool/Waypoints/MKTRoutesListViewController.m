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

#import "MKTSettingsController.h"

#import "MKTRouteDropboxController.h"
#import "MKTRoutesListViewController.h"
#import "MKTRouteSyncViewController.h"

#import "MKTRouteContainerViewController.h"
#import "MKTRouteMasterViewController.h"

#import "MKTRouteListViewController.h"

#import "InnerBand.h"
#import "MKTRoute.h"
#import "MKTPoint.h"

@interface MKTRoutesListViewController () <NSFetchedResultsControllerDelegate,IASKSettingsDelegate,MKTRouteDropboxControllerDelegate> {
  NSMutableArray *_objects;
  BOOL userDrivenDataModelChange;
}

@property(nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (void)addNewRoute;
- (void)showRouteViewController:(MKTRoute *)route;

- (void)syncRoutes;

@property(nonatomic, strong) UIBarButtonItem *spacer;
@property(nonatomic, strong) UIBarButtonItem *addButton;
@property(nonatomic, strong) UIBarButtonItem *syncButton;

@end

@implementation MKTRoutesListViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize spacer,syncButton,addButton;

- (id)init {
  self = [super initWithStyle:UITableViewStylePlain];
  if (self) {
    self.title = NSLocalizedString(@"Routes", @"Routes Master title");
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
                                                                             action:@selector(addNewRoute)];
  self.addButton.style = UIBarButtonItemStyleBordered;

  
  self.syncButton = [[UIBarButtonItem alloc]
                      initWithImage:[UIImage imageNamed:@"icon-backforth.png"]
                      style:UIBarButtonItemStyleBordered
                      target:self
                      action:@selector(syncRoutes)];

  self.spacer = [[UIBarButtonItem alloc]
                   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                   target:nil action:nil];

  [self setToolbarItems:[NSArray arrayWithObjects:
                         self.editButtonItem,
                         self.spacer,
                         self.syncButton,
                         self.spacer,
                         self.addButton,
                         nil]];

  
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


- (void)addNewRoute{

  MKTRoute *r = [MKTRoute create];
  r.name = NSLocalizedString(@"Route", @"Route default name");

  [[IBCoreDataStore mainStore] save];
  
  [self showRouteViewController:r];
  
}


- (void)showSettingsModal{
  
  [[MKTSettingsController sharedController] showFromController:IB_IS_IPAD()?self.splitViewController:self];
}

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender{
  if (IB_IS_IPAD())
    [self.splitViewController dismissViewControllerAnimated:YES completion:nil];
  else
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)doReindex {
  
  int i = 0;
  for (MKTRoute *r in [MKTRoute allOrderedBy:@"index" ascending:YES]) {
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
  
  MKTRoute *route = [self.fetchedResultsController objectAtIndexPath:indexPath];
  cell.textLabel.text = route.name;
  
  NSUInteger numWP=[route countWP];
  NSUInteger numPOI=[route countPOI];
  NSLog(@"configureCell WP %d POI %d",numWP,numPOI);
  if(numWP==0 && numPOI==0){
    cell.detailTextLabel.text = NSLocalizedString(@"No Points", @"Route descr. no points");
  }
  else {
    if (numWP==0) {
      if (numPOI==1) {
        cell.detailTextLabel.text = NSLocalizedString(@"One POI", @"Route descr. one POI only");
      } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d POI", @"Route descr. multiple. POI only"),numPOI];
      }
    }
    else {
      if (numWP==1) {
        cell.detailTextLabel.text = NSLocalizedString(@"One Waypoint", @"Route descr. one WP");
      } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d Waypoints", @"Route descr. multiple. WP"),numWP];
      }
      
      if (numPOI>0) {
        if (numPOI==1) {
          cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingString:NSLocalizedString(@" and one POI", @"Route descr. one POI only")];
        } else {
          cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingFormat:NSLocalizedString(@" and %d POI", @"Route descr. multiple. POI only"),numPOI];
        }
      }
    }
  }

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
  for (MKTRoute *r in array) {
    r.indexValue = ++i;
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


- (void)showRouteViewController:(MKTRoute *)route {
    if(IB_IS_IPAD()){
        MKTRouteMasterViewController *routeController = [[MKTRouteMasterViewController alloc] initWithRoute:route];
        [self.navigationController pushViewController:routeController animated:YES];
    }
    else       {
        MKTRouteContainerViewController *routeController = [[MKTRouteContainerViewController alloc] initWithRoute:route];
        [self.navigationController pushViewController:routeController animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  if (!tableView.isEditing) {
    MKTRoute *route = [self.fetchedResultsController objectAtIndexPath:indexPath];

      [self showRouteViewController:route];
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

  _fetchedResultsController = [MKTRoute fetchedResultsController];
  _fetchedResultsController.delegate = self;

  NSError *error = nil;
  if (![self.fetchedResultsController performFetch:&error]) {
    abort();
  }

  return _fetchedResultsController;
}

///////////////////////////////////////////////////////////////////////////////////
#pragma mark - Synchronizing
///////////////////////////////////////////////////////////////////////////////////

- (void)syncRoutes {

  [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];

  [MKTRouteDropboxController sharedController].delegate = self;
  [[MKTRouteDropboxController sharedController] connectAndPrepareMetadataFromController:self];  
}

- (void)dropboxReady:(MKTRouteDropboxController*)dbController{

  [MBProgressHUD hideHUDForView:self.view.window animated:YES];

  MKTRouteSyncViewController* controller = [[MKTRouteSyncViewController alloc] initWithNibName:nil bundle:nil];
  UINavigationController* naviController = [[UINavigationController alloc] initWithRootViewController:controller];
  
  if (IB_IS_IPAD()) {
    naviController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.splitViewController presentViewController:naviController animated:YES completion:nil];
  }
  else
    [self presentViewController:naviController animated:YES completion:nil];
}

- (void)controller:(MKTRouteDropboxController*)crontroller dropboxInitFailedWithError:(NSError*)error{
  [MBProgressHUD hideHUDForView:self.view.window animated:YES];
  [MKTRouteDropboxController showError:error withTitle:NSLocalizedString(@"Getting the Route data folder failed", @"Getting Data Folder Error Title")];
}


- (void)controllerSyncCompleted:(MKTRouteDropboxController*)crontroller{
  [MBProgressHUD hideHUDForView:self.view.window animated:YES];
}

- (void)controller:(MKTRouteDropboxController*)crontroller syncFailedWithError:(NSError*)error{
  [MBProgressHUD hideHUDForView:self.view.window animated:YES];
  [MKTRouteDropboxController showError:error withTitle:NSLocalizedString(@"Synchronization failed", @"Routes Restore Error Title")];
}

- (void)controller:(MKTRouteDropboxController *)crontroller syncProgress:(CGFloat)progress{
  MBProgressHUD* hud = [MBProgressHUD HUDForView:self.view.window];
  hud.progress = progress;
  if(progress==1.0)
    hud.mode = MBProgressHUDModeIndeterminate;
    
}

- (void)controllerPausedInit:(MKTRouteDropboxController*)crontroller{
  [MBProgressHUD hideHUDForView:self.view.window animated:YES];
}

- (void)controllerRestartedInit:(MKTRouteDropboxController*)crontroller{
  
}

@end
