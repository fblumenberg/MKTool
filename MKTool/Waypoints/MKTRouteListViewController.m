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

#import <IBAForms/IBAForms.h>
#import <CoreLocation/CoreLocation.h>

#import "InnerBand.h"
#import "MKTRouteListViewController.h"
#import "MKTRouteMapViewController.h"
#import "MKTPointViewController.h"
#import "MKTPointBulkViewController.h"
#import "MKTPoint.h"
#import "NSArray+BlocksKit.h"

#import "UIViewController+MGSplitViewController.h"

#import "SettingsFieldStyle.h"

///////////////////////////////////////////////////////////////////////////////////
#pragma mark -
///////////////////////////////////////////////////////////////////////////////////
@interface MKTTextFormFieldCell : IBATextFormFieldCell
@end

///////////////////////////////////////////////////////////////////////////////////
#pragma mark -
///////////////////////////////////////////////////////////////////////////////////
@interface MKTRouteListViewController () <UITableViewDataSource, UITextFieldDelegate, NSFetchedResultsControllerDelegate, CLLocationManagerDelegate> {

  BOOL userDrivenDataModelChange;
}

@property(nonatomic, strong) CLLocationManager *lm;
@property(nonatomic, strong) UIPopoverController *popoverController;
@property(nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic, strong) UIBarButtonItem *spacer;
@property(nonatomic, strong) UIBarButtonItem *addButton;
@property(nonatomic, strong) UIBarButtonItem *addWithGpsButton;
@property(nonatomic, strong) UIBarButtonItem *deleteButton;
@property(nonatomic, strong) UIBarButtonItem *updateButton;
@property(nonatomic, strong) UIBarButtonItem *ulButton;
@property(nonatomic, strong) UIBarButtonItem *dlButton;
@property(nonatomic, strong) UIBarButtonItem *wpGenButton;


- (void)deleteSelectedPoints;
- (void)changeSelectedPoints;

- (void)addPoint;
- (void)addPointWithGps;

- (void)updateToolbarState;
- (void)updateToolbar;

- (NSIndexPath *)correctedIndexPath:(NSIndexPath *)indexPath;


@end

///////////////////////////////////////////////////////////////////////////////////
#pragma mark -
///////////////////////////////////////////////////////////////////////////////////
@implementation MKTRouteListViewController

@synthesize lm;

@synthesize addButton;
@synthesize addWithGpsButton;
@synthesize deleteButton;
@synthesize updateButton;

@synthesize spacer;
@synthesize ulButton;
@synthesize dlButton;
@synthesize wpGenButton;

@synthesize popoverController;

@synthesize route = _route;
@synthesize delegate = _delegate;

@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - Initializing

- (id)initWithRoute:(MKTRoute *)route {
  return [self initWithRoute:route delegate:nil];
}

- (id)initWithRoute:(MKTRoute *)route delegate:(id <MKTRouteViewControllerDelegate>)delegate {

  if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
    self.route = route;
    self.delegate = delegate;
    self.title = NSLocalizedString(@"Route", @"Waypoint Lists title");
    
    self.lm = [CLLocationManager new];
    self.lm.delegate = self;
    self.lm.desiredAccuracy = kCLLocationAccuracyBest;
  }

  return self;
}

- (void)dealloc
{
  [self.lm stopUpdatingLocation];
  self.lm.delegate = nil;
}

#pragma mark - View lifecycle

- (void)loadView {
  [super loadView];
}


- (void)initToolbarButtons {
  // create the possible toolbar buttons
  self.spacer = [[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                               target:nil action:nil];

  self.wpGenButton = [[UIBarButtonItem alloc] initWithTitle:@"WP"
                                                      style:UIBarButtonItemStyleBordered
                                                     target:self action:@selector(showWpGenerator)];


  self.addButton = [[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                               target:self
                    action:@selector(addPoint)];
  self.addButton.style = UIBarButtonItemStyleBordered;

  self.addWithGpsButton = [[UIBarButtonItem alloc]
          initWithImage:[UIImage imageNamed:@"icon-add-gps.png"]
                  style:UIBarButtonItemStyleBordered
                 target:self
                 action:@selector(addPointWithGps)];

  self.deleteButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Delete", @"Delete toolbar button") style:UIBarButtonItemStyleBordered
                                                      target:self action:@selector(deleteSelectedPoints)];
  self.deleteButton.tintColor = [UIColor redColor];


  self.updateButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Change", @"Change points toolbar button") style:UIBarButtonItemStyleBordered
                                                      target:self action:@selector(changeSelectedPoints)];


  self.ulButton = [[UIBarButtonItem alloc]
          initWithImage:[UIImage imageNamed:@"icon-ul1.png"]
                  style:UIBarButtonItemStyleBordered
                 target:self
                 action:@selector(uploadRoute)];

  self.dlButton = [[UIBarButtonItem alloc]
          initWithImage:[UIImage imageNamed:@"icon-dl1.png"]
                  style:UIBarButtonItemStyleBordered
                 target:self
                 action:@selector(downloadRoute)];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  [self initToolbarButtons];
}

- (void)viewDidUnload {
  [super viewDidUnload];
  self.route = nil;
  self.fetchedResultsController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self updateToolbar];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
  [super viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  self.tableView.allowsMultipleSelectionDuringEditing = NO;
  [super setEditing:NO animated:NO];
  [self.tableView setEditing:NO animated:NO];
  
  [[CoreDataStore mainStore] save];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)updateToolbar {

  NSMutableArray *tbArray = [NSMutableArray array];

  [tbArray addObject:self.editButtonItem];
  [tbArray addObject:self.spacer];

  
  if (self.tableView.isEditing) {
    [tbArray addObject:self.updateButton];
    [tbArray addObject:self.spacer];
    [tbArray addObject:self.deleteButton];
  }
  else {
    if(IS_IPHONE()){
      [tbArray addObject:self.wpGenButton];
    }
    
    if(IS_GPS_ENABLED())
      [tbArray addObject:self.addWithGpsButton];
    
    [tbArray addObject:self.addButton];
  }

  if (self.delegate) {
    
    self.toolbarItems = tbArray;
    NSLog(@"updated toolbar %@",self.toolbarItems);
    [self.delegate controllerDidChangeToolbar:self];
////    [self setToolbarItems:tbArray animated:YES];
//    self.navigationController.toolbarHidden = NO;
  }
  else {
    [self setToolbarItems:tbArray animated:YES];
    self.navigationController.toolbarHidden = NO;
  }

  [self updateToolbarState];
}

- (void)updateToolbarState {
  if (self.isEditing) {
    NSUInteger count = [self.tableView indexPathsForSelectedRows].count;
    BOOL hasSelection = count > 0;

    self.deleteButton.enabled = hasSelection;
    self.updateButton.enabled = hasSelection;

    if (hasSelection) {
      self.deleteButton.title = [NSString stringWithFormat:NSLocalizedString(@"Delete(%d)", @"Delete toolbar button"), count];
      self.updateButton.title = [NSString stringWithFormat:NSLocalizedString(@"Change(%d)", @"Change toolbar button"), count];
    }
    else {
      self.deleteButton.title = NSLocalizedString(@"Delete", @"Delete toolbar button");
      self.updateButton.title = NSLocalizedString(@"Change", @"Change toolbar button");
    }

  }
  else {
    self.addWithGpsButton.enabled = IS_GPS_ENABLED();
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextFieldDelegate Functions

- (void)_textChanged:(id)sender {
  UITextField *text = (UITextField *) sender;
  self.route.name = text.text;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  [textField setTextAlignment:UITextAlignmentLeft];
  return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  //	self.currentFirstResponder = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
///////////////////////////////////////////////////////////////////////////////////////////////////

- (NSIndexPath *)correctedIndexPath:(NSIndexPath *)indexPath {
  return [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - 1];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

  NSInteger n = 2;
  return n;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0)
    return 1;

  id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];

  return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)cellForExtra:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"WaypointExtraCell";
  
  MKTTextFormFieldCell *cell = (MKTTextFormFieldCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
  if (!cell) {
    cell = [[MKTTextFormFieldCell alloc] initWithFormFieldStyle:[SettingsFieldStyleText new] reuseIdentifier:CellIdentifier];
    
    cell.textField.textAlignment = UITextAlignmentLeft;
    cell.textField.returnKeyType = UIReturnKeyDone;
    cell.accessoryType = UITableViewCellAccessoryNone;
  }
  
  [[cell label] setText:NSLocalizedString(@"Name", @"Waypoint List name label")];
  
  [[cell textField] setText:self.route.name];
  
  [[cell textField] setDelegate:self];
  [[cell textField] addTarget:self action:@selector(_textChanged:) forControlEvents:UIControlEventEditingChanged];
  [[cell textField] setSecureTextEntry:NO];
  [[cell textField] setKeyboardType:UIKeyboardTypeAlphabet];
  [[cell textField] setAutocapitalizationType:UITextAutocapitalizationTypeNone];
  [[cell textField] setAutocorrectionType:UITextAutocorrectionTypeNo];
  [cell setNeedsLayout];
  return cell;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0)
    return [self cellForExtra:theTableView indexPath:indexPath]; 

  static NSString *CellIdentifier = @"IKPointListCell";

  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
  }

  [self configureCell:cell atIndexPath:indexPath];

  return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self updateToolbarState];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (!tableView.isEditing) {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section > 0){
 
      MKTPoint *p = [self.fetchedResultsController objectAtIndexPath:[self correctedIndexPath:indexPath]];
      [self showViewControllerForPoint:p];
    }
  }
  [self updateToolbarState];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return (indexPath.section > 0);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

  if (editingStyle == UITableViewCellEditingStyleDelete) {

    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - 1];

    MKTPoint *p = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"%@", p);

    [self.route deletePointAtIndexPath:indexPath];

  } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

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

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
  return (indexPath.section > 0);
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {

  NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
  MKTPoint *point = [self.fetchedResultsController objectAtIndexPath:indexPath2];

  if (point.typeValue == MKTPointTypeWP) {
    cell.imageView.image = [UIImage imageNamed:@"icon-flag.png"];
    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ - Waypoint", @"Waypoint cell"), point.name];
  } else {
    cell.imageView.image = [UIImage imageNamed:@"icon-poi.png"];
    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ - POI", @"POI cell"), point.name];
  }

  cell.detailTextLabel.text = [NSString stringWithFormat:@"%d m - %d s - %.0f m/s %@",
                                                         point.altitudeValue, point.holdTimeValue,
                                                         (point.speedValue * 0.1), [point formatHeading]];

  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  [cell setNeedsLayout];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Fetched results controller delegate
///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
  if (userDrivenDataModelChange) return;
  [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {

  if (userDrivenDataModelChange) return;
  switch (type) {
    case NSFetchedResultsChangeInsert:
      [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex + 1] withRowAnimation:UITableViewRowAnimationFade];
      break;

    case NSFetchedResultsChangeDelete:
      [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex + 1] withRowAnimation:UITableViewRowAnimationFade];
      break;
  }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {

  UITableView *tableView = self.tableView;

  indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1];
  newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:newIndexPath.section + 1];

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

///////////////////////////////////////////////////////////////////////////////////
#pragma mark -
///////////////////////////////////////////////////////////////////////////////////

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {

  if (_fetchedResultsController != nil) {
    return _fetchedResultsController;
  }

  _fetchedResultsController = [MKTPoint fetchedResultsControllerForRoute:self.route];
  _fetchedResultsController.delegate = self;

  NSError *error = nil;
  if (![self.fetchedResultsController performFetch:&error]) {
    abort();
  }

  return _fetchedResultsController;
}

///////////////////////////////////////////////////////////////////////////////////
#pragma mark - 
///////////////////////////////////////////////////////////////////////////////////

- (void) addedPoint:(MKTPoint*)newPoint{
  NSIndexPath *indexPath =[self.fetchedResultsController indexPathForObject:newPoint];
  indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1];
  
  
  if( [[self.tableView indexPathsForVisibleRows] match:^BOOL(NSIndexPath* i){
    return [i isEqual:indexPath];
  }]){
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
  }
  else {
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
  }
}

- (void)addPoint {
  MKTPoint* newPoint = [self.route addPointAtCenter];
  [self addedPoint:newPoint];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
  
  NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
  if(indexPath){
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
  }
}

- (void)addPointWithGps {
  [self.lm startUpdatingLocation];
}


- (void)deleteSelectedPoints {
  [self.route deletePointsAtIndexPaths:[self.tableView indexPathsForSelectedRows]];
  [self updateToolbarState];
}

- (void)changeSelectedPoints {

  NSArray *pointsToChange = [[self.tableView indexPathsForSelectedRows] map:(ib_enum_id_t) ^(NSIndexPath *obj) {
    return [self.fetchedResultsController objectAtIndexPath:[self correctedIndexPath:obj]];
  }];

  MKTPointBulkViewController *controller = [[MKTPointBulkViewController alloc] initWithPoints:pointsToChange];
  UINavigationController *aNavController = [[UINavigationController alloc] initWithRootViewController:controller];

  [[self.tableView indexPathsForSelectedRows] each:^(NSIndexPath* indexPath){
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
  }];
  
  [self updateToolbarState];
  
  if (IS_IPAD()) {
    aNavController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.splitViewController presentModalViewController:aNavController animated:YES];
  }
  else
    [self presentModalViewController:aNavController animated:YES];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
  
  self.tableView.allowsMultipleSelectionDuringEditing = editing;
  [super setEditing:editing animated:animated];
  [self.tableView setEditing:editing animated:animated];

  [self updateToolbar];
}


- (void)showViewControllerForPoint:(MKTPoint *)point{
  
  MKTPointViewController *controller = [[MKTPointViewController alloc] initWithPoint:point];
  
  if(IS_IPAD()){
    
    NSIndexPath *indexPath =[self.fetchedResultsController indexPathForObject:point];
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1];
    
    [self.popoverController dismissPopoverAnimated:NO];
    
    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    CGRect  rect = [self.view convertRect:cell.bounds fromView:cell.contentView];

    if(CGRectGetHeight(rect)==0)
      rect = RECT_WITH_HEIGHT(rect,1);

    if(CGRectGetWidth(rect)==0)
      rect = RECT_WITH_WIDTH(rect,1);

    [self.popoverController presentPopoverFromRect:rect inView:self.view
                          permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    
  }
  else {
    [self.navigationController pushViewController:controller animated:YES];
  }
}

- (void)showWpGenerator{
  if(IS_IPHONE()){
    
    MKTRouteMapViewController* controller = [[MKTRouteMapViewController alloc] initWithRoute:self.route];
    
    controller.forWpGenModal = YES;
    
    UINavigationController *modalNavController = [[UINavigationController alloc]
                                                  initWithRootViewController:controller];
    
    [self.navigationController presentModalViewController:modalNavController
                                                 animated:YES];
  }
}


#pragma mark - CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
  
  if ([newLocation.timestamp timeIntervalSince1970] < [NSDate timeIntervalSinceReferenceDate] - 60)
    return;
  
  [self.lm stopUpdatingLocation];
  
  MKTPoint* newPoint = [self.route addPointAtCoordinate:newLocation.coordinate];
  [self addedPoint:newPoint];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
  
  NSString *errorType = (error.code == kCLErrorDenied) ?
  NSLocalizedString(@"Access Denied", @"Access Denied") :
  NSLocalizedString(@"Unknown Error", @"Unknown Error");
  
  UIAlertView *alert = [[UIAlertView alloc]
                        initWithTitle:NSLocalizedString(@"Error getting Location", @"Error getting Location") message:errorType
                        delegate:self
                        cancelButtonTitle:NSLocalizedString(@"OK", @"Okay") otherButtonTitles:nil];
  [alert show];
  
  self.addWithGpsButton.enabled = IS_GPS_ENABLED();
  self.lm = nil;
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
  NSLog(@"didChangeAuthorizationStatus update toolbar");
  [self updateToolbar];
}

@end


///////////////////////////////////////////////////////////////////////////////////
#pragma mark - 
///////////////////////////////////////////////////////////////////////////////////

@implementation MKTTextFormFieldCell

- (void)didMoveToWindow{
  
}
@end
