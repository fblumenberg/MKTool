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
#import "CJAMacros.h"
#import "InnerBand.h"
#import "MKTMainMenuController.h"
#import "SBTableAlert.h"

#import "MKTConnectionsListViewController.h"
#import "MKTRoutesListViewController.h"
#import "MKTGpxLoggingListViewController.h"

#import "MKTConnection.h"
#import "MKTConnectedMenuController.h"

#import "MKTSettingsController.h" 

#define kMKTMainMenuDisplayedConnections 4

@interface MKTMainMenuController () <SBTableAlertDataSource, SBTableAlertDelegate, NSFetchedResultsControllerDelegate> {

  NSUInteger selectConnectionRow;
  NSUInteger editConnectionRow;
  BOOL hasConnections;
  BOOL showSelectConnections;

  NSUInteger connectionSection;
  NSUInteger functionsSection;

}

@property(nonatomic, strong) NSFetchedResultsController *connectionsFetchedResults;

- (void)showSettingsModal;

@end

@implementation MKTMainMenuController

@synthesize connectionsFetchedResults = _connectionsFetchedResults;

- (id)init {
  self = [super initWithStyle:UITableViewStyleGrouped];
  if (self) {

    connectionSection = 0;
    functionsSection = 1;

    selectConnectionRow = kMKTMainMenuDisplayedConnections;
    editConnectionRow = selectConnectionRow + 1;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.title = NSLocalizedString(@"MKTool", @"Main title");
  
  UIBarButtonItem* settingsButton = [[UIBarButtonItem alloc]
                         initWithImage:[UIImage imageNamed:@"icon-settings3.png"]
                         style:UIBarButtonItemStyleBordered
                         target:self
                         action:@selector(showSettingsModal)];
  
  self.navigationItem.rightBarButtonItem = settingsButton;

//  self.tableView.backgroundColor = [UIColor yellowColor];
//  self.tableView.backgroundView = nil;
}

- (void)viewDidUnload {
  [super viewDidUnload];

  self.connectionsFetchedResults = nil;
}

- (void)viewWillAppear:(BOOL)animated {

  [super viewWillAppear:animated];
  [self updateConnectionsSection];
  [self.tableView reloadData];
}

-(void) viewDidAppear:(BOOL)animated{
  [super viewDidAppear:animated];
  [self.navigationController setToolbarHidden:YES animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (void)updateConnectionsSection {
  id <NSFetchedResultsSectionInfo> sectionInfo = [[self.connectionsFetchedResults sections] objectAtIndex:0];

  NSUInteger numberOfConnections = [sectionInfo numberOfObjects];

  hasConnections = numberOfConnections != 0;
  showSelectConnections = NO; //numberOfConnections > kMKTMainMenuDisplayedConnections;

  selectConnectionRow = kMKTMainMenuDisplayedConnections;
  editConnectionRow = showSelectConnections ? selectConnectionRow + 1 : hasConnections ? numberOfConnections : 0;
}

- (void)showSettingsModal{
  [[MKTSettingsController sharedController] showFromController:IB_IS_IPAD()?self.splitViewController:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == connectionSection) {
    return editConnectionRow + 1;
  }
  else if (section == functionsSection) {
    return 2;
  }

  return 0;
}

DEFINE_KEY(kConnectionCellId)
DEFINE_KEY(kFunctionCellId)

- (void)configureConnectionCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {

  MKTConnection *connection = [self.connectionsFetchedResults objectAtIndexPath:indexPath];

  cell.textLabel.text = connection.name;
  cell.imageView.image = [connection cellImage];
  if([connection.connectionClass isEqualToString:@"MKSimConnection"])
    cell.detailTextLabel.text = @"";
  else
    cell.detailTextLabel.text = connection.address;
  cell.accessoryView = nil;
  cell.accessoryType = UITableViewCellAccessoryNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView connectionCellForIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"ConnectionCell";

  UITableViewCell *cell = nil;

  if (indexPath.row == editConnectionRow) {
    cell = [tableView dequeueReusableCellWithIdentifier:kFunctionCellId];
    if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFunctionCellId];
    }
    cell.textLabel.text = NSLocalizedString(@"Edit Connections", "Main Menu Edit Connection");
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.image = nil;
  }
  else if (indexPath.row == selectConnectionRow && showSelectConnections) {
    cell = [tableView dequeueReusableCellWithIdentifier:kFunctionCellId];
    if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFunctionCellId];
    }
    cell.textLabel.text = NSLocalizedString(@"Select Connection", @"Main Menu Select Connection");
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.imageView.image = nil;
  }
  else {
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [self configureConnectionCell:cell forIndexPath:indexPath];
  }

  return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView functionCellForIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"FunctionCell";

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }

  switch (indexPath.row) {
    case 0:
      cell.textLabel.text = NSLocalizedString(@"Routes", @"Waypointlist cell");
      break;
    case 1:
      cell.textLabel.text = NSLocalizedString(@"GPX-Logging", @"GpxLogging cell");
      break;
  }
  cell.accessoryView = nil;
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  cell.imageView.image = nil;

  return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  if (indexPath.section == connectionSection) {
    return [self tableView:tableView connectionCellForIndexPath:indexPath];
  }
  else if (indexPath.section == functionsSection) {
    return [self tableView:tableView functionCellForIndexPath:indexPath];
  }

  return nil;
}

#pragma mark - Table view delegate

- (void)openConnectionForIndexPath:(NSIndexPath *)indexPath {

  MKTConnection *connection = [self.connectionsFetchedResults objectAtIndexPath:indexPath];

  MKTConnectedMenuController *c = [[MKTConnectedMenuController alloc] initWIthConnection:connection];
  [self.navigationController pushViewController:c animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  if (indexPath.section == connectionSection) {
    if (indexPath.row == editConnectionRow) {
      MKTConnectionsListViewController *c = [MKTConnectionsListViewController new];
      [self.navigationController pushViewController:c animated:YES];
    }
    else if (showSelectConnections && indexPath.row == selectConnectionRow) {
      SBTableAlert *alert = [SBTableAlert alertWithTitle:@"Connections" cancelButtonTitle:NSLocalizedString(@"Cancel", @"Connections select") messageFormat:nil];
      alert.dataSource = self;
      alert.delegate = self;
      [alert show];
    }
    else {
      [self openConnectionForIndexPath:indexPath];
    }
  }
  else if (indexPath.section == functionsSection) {
    UIViewController *controler;

    switch (indexPath.row) {
      case 0:
        controler = [MKTRoutesListViewController new];
        break;
      case 1:
        controler = [MKTGpxLoggingListViewController new];
        break;
    }

    [self.navigationController pushViewController:controler animated:YES];
  }
}

#pragma mark - SBTableAlertDataSource

- (UITableViewCell *)tableAlert:(SBTableAlert *)tableAlert cellForRowAtIndexPath:(NSIndexPath *)indexPath; {
  static NSString *CellIdentifier = @"FunctionCell";

  UITableViewCell *cell = [tableAlert.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }

  [self configureConnectionCell:cell forIndexPath:indexPath];

  return cell;
}

- (NSInteger)tableAlert:(SBTableAlert *)tableAlert numberOfRowsInSection:(NSInteger)section {
  id <NSFetchedResultsSectionInfo> sectionInfo = [[self.connectionsFetchedResults sections] objectAtIndex:0];

  return [sectionInfo numberOfObjects];
}

- (void)tableAlert:(SBTableAlert *)tableAlert didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self openConnectionForIndexPath:indexPath];
}

///////////////////////////////////////////////////////////////////////////////////
#pragma mark - Fetched results controller delegate
///////////////////////////////////////////////////////////////////////////////////

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
  [self updateConnectionsSection];
  [self.tableView endUpdates];
}

///////////////////////////////////////////////////////////////////////////////////
#pragma mark - Fetched results controller
///////////////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)connectionsFetchedResults {

  if (_connectionsFetchedResults != nil) {
    return _connectionsFetchedResults;
  }

  _connectionsFetchedResults = [MKTConnection fetchedResultsControllerLastUsed];
  _connectionsFetchedResults.delegate = self;

  NSError *error = nil;
  if (![self.connectionsFetchedResults performFetch:&error]) {
    abort();
  }

  return _connectionsFetchedResults;
}

@end
