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

#import <IBAForms/IBAForms.h>
#import <CoreLocation/CoreLocation.h>

#import "InnerBand.h"
#import "MKTRouteListViewController.h"
#import "MKTPointViewController.h"
#import "MKTPointBulkViewController.h"
#import "MKTPoint.h"

#import "UIViewController+MGSplitViewController.h"

#import "SettingsFieldStyle.h"

///////////////////////////////////////////////////////////////////////////////////
#pragma mark -
///////////////////////////////////////////////////////////////////////////////////
@interface MKTRouteListViewDataSource : IBAFormDataSource
@end

///////////////////////////////////////////////////////////////////////////////////
#pragma mark -
///////////////////////////////////////////////////////////////////////////////////
@interface MKTRouteListViewController () <UITableViewDataSource, NSFetchedResultsControllerDelegate, CLLocationManagerDelegate> {

  BOOL userDrivenDataModelChange;
  NSUInteger pointsSection;
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

- (void)showViewControllerForPoint:(MKTPoint *)point scrollToBottom:(BOOL)scroll;

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

//@synthesize surrogateParent;
@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - Initializing

- (id)initWithRoute:(MKTRoute *)route {
  return [self initWithRoute:route delegate:nil];
}

- (id)initWithRoute:(MKTRoute *)route delegate:(id <MKTRouteViewControllerDelegate>)delegate {

  MKTRouteListViewDataSource *dataSource = [[MKTRouteListViewDataSource alloc] initWithModel:route];

  if ((self = [super initWithNibName:nil bundle:nil formDataSource:dataSource])) {
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

  UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

  UITableView *formTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStyleGrouped];
  [formTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
  [self setTableView:formTableView];

  [view addSubview:formTableView];
  [self setView:view];
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

  pointsSection = [self.formDataSource numberOfSectionsInTableView:self.tableView];
  self.tableView.dataSource = self;
  //  self.tableView.allowsSelectionDuringEditing = NO;
  //self.tableView.allowsMultipleSelectionDuringEditing = YES;
}

- (void)viewDidUnload {
  [super viewDidUnload];
  self.route = nil;
  self.fetchedResultsController = nil;
  NSLog(@"viewDidUnload");
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

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  self.tableView.allowsMultipleSelectionDuringEditing = NO;
  [super setEditing:NO animated:NO];
  [self.tableView setEditing:NO animated:NO];
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
  }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
///////////////////////////////////////////////////////////////////////////////////////////////////

- (NSIndexPath *)correctedIndexPath:(NSIndexPath *)indexPath {
  return [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - 1];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

  NSInteger n = [self.formDataSource numberOfSectionsInTableView:tableView] + 1;
  return n;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section != pointsSection)
    return [self.formDataSource tableView:tableView numberOfRowsInSection:section];

  id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];

  NSLog(@"%@", sectionInfo);

  return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section != pointsSection)
    return [self.formDataSource tableView:theTableView cellForRowAtIndexPath:indexPath];

  static NSString *CellIdentifier = @"IKPointListCell";

  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
  }

  [self configureCell:cell atIndexPath:indexPath];

  return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(IBAFormFieldCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

  if (indexPath.section != pointsSection)
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

  if (indexPath.section != pointsSection)
    return [super tableView:aTableView heightForRowAtIndexPath:indexPath];

  return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if (section != pointsSection)
    return [self.formDataSource tableView:tableView titleForHeaderInSection:section];

  return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
  if (section != pointsSection)
    return [self.formDataSource tableView:tableView titleForFooterInSection:section];

  return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  if (section != pointsSection)
    return [self.formDataSource viewForFooterInSection:section];

  return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  if (section != pointsSection)
    return [self.formDataSource viewForHeaderInSection:section];

  return nil;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self updateToolbarState];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (!tableView.isEditing) {
    if (indexPath.section != pointsSection)
      [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    else {
      [tableView deselectRowAtIndexPath:indexPath animated:YES];

      MKTPoint *p = [self.fetchedResultsController objectAtIndexPath:[self correctedIndexPath:indexPath]];
      [self showViewControllerForPoint:p scrollToBottom:NO];
    }
  }
  [self updateToolbarState];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return (indexPath.section == pointsSection);
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
  return (indexPath.section == pointsSection);
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

  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %d m - %d s - %.0f m/s - %@",
                                                         point.name, point.altitudeValue, point.holdTimeValue,
                                                         (point.speedValue * 0.1), [point formatHeading]];

  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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

- (void)addPoint {
  MKTPoint* newPoint = [self.route addPointAtCenter];
  
  NSIndexPath *indexPath =[self.fetchedResultsController indexPathForObject:newPoint];
  indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1];
  [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
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


- (void)showViewControllerForPoint:(MKTPoint *)point scrollToBottom:(BOOL)scroll{
  
  MKTPointViewController *controller = [[MKTPointViewController alloc] initWithPoint:point];
  
  if(IS_IPAD()){
    
    NSIndexPath *indexPath =[self.fetchedResultsController indexPathForObject:point];
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1];
    
//    if(scroll)
//      [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];

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


#pragma mark - CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
  
  if ([newLocation.timestamp timeIntervalSince1970] < [NSDate timeIntervalSinceReferenceDate] - 60)
    return;
  
  [self.lm stopUpdatingLocation];
  
  MKTPoint* newPoint = [self.route addPointAtCoordinate:newLocation.coordinate];
  NSIndexPath *indexPath =[self.fetchedResultsController indexPathForObject:newPoint];
  indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1];
  [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
  
  NSString *errorType = (error.code == kCLErrorDenied) ?
  NSLocalizedString(@"Access Denied", @"Access Denied") :
  NSLocalizedString(@"Unknown Error", @"Unknown Error");
  
  UIAlertView *alert = [[UIAlertView alloc]
                        initWithTitle:NSLocalizedString(@"Error getting Location", @"Error getting Location") message:errorType
                        delegate:self
                        cancelButtonTitle:NSLocalizedString(@"Okay", @"Okay") otherButtonTitles:nil];
  [alert show];
  
  self.addWithGpsButton.enabled = IS_GPS_ENABLED();
  self.lm = nil;
}


@end


///////////////////////////////////////////////////////////////////////////////////
#pragma mark - 
///////////////////////////////////////////////////////////////////////////////////

@implementation MKTRouteListViewDataSource

- (id)initWithModel:(id)aModel {
  if ((self = [super initWithModel:aModel])) {

    IBATextFormField *numberField;

    IBAFormSection *positionSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
    positionSection.formFieldStyle = [[SettingsFieldStyleText alloc] init];
    //------------------------------------------------------------------------------------------------------------------------
    numberField = [[IBATextFormField alloc] initWithKeyPath:@"name"
                                                      title:NSLocalizedString(@"Name", @"WP Route name") valueTransformer:nil];

    [positionSection addFormField:numberField];
  }
  return self;
}

@end
