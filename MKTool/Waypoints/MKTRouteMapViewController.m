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

#import <MapKit/MapKit.h>
#import <GHKitIOS/GHNSUserDefaults+Utils.h>

#import "YKMKUtils.h"

#import "MKTRouteMapViewController.h"
#import "MKTPointAnnotationView.h"
#import "MKTPointViewController.h"

#import "InnerBand.h"
#import "BKMacros.h"
#import "FDCurlViewControl.h"

#import "MKTPoint.h"

#import "HeadingOverlay.h"
#import "HeadingOverlayView.h"

#import "WPGenAreaViewController.h"
#import "WPGenCircleViewController.h"
#import "WPGenPanoViewController.h"

DEFINE_KEY(MKTRouteMapViewType);
DEFINE_KEY(MKTRouteMapViewShowPosition);

///////////////////////////////////////////////////////////////////////////////////
#pragma mark -
///////////////////////////////////////////////////////////////////////////////////

@interface MKTRouteMapViewController () <MKMapViewDelegate, FDCurlViewControlDelegate, CLLocationManagerDelegate,
                                         WPGenBaseViewControllerDelegate, NSFetchedResultsControllerDelegate>{
  BOOL userDrivenDataModelChange;
  BOOL waitForLocation;
}

@property(nonatomic,strong) IBOutlet MKMapView *mapView;

@property(nonatomic, strong) FDCurlViewControl *curlBarItem;
@property(nonatomic, strong) UIBarButtonItem *spacer;
@property(nonatomic, strong) UIBarButtonItem *addButton;
@property(nonatomic, strong) UIBarButtonItem *addWithGpsButton;

@property(nonatomic, strong) WPGenBaseViewController *wpgenController;
@property(nonatomic, strong) UISegmentedControl *wpGeneratorSelection;
@property(nonatomic, strong) UIBarButtonItem *wpGenerateItem;
@property(nonatomic, strong) UIBarButtonItem *wpGenButton;

@property(nonatomic, strong) UIBarButtonItem *wpGeneratorSelectionButton;
@property(nonatomic, strong) UIBarButtonItem *wpGenerateConfigItem;

@property(nonatomic, strong) CLLocationManager *lm;

@property(nonatomic,strong) IBOutlet UISegmentedControl *segmentedControl;
@property(nonatomic,strong) IBOutlet UISwitch *showOwnPosition;
@property(nonatomic,strong) IBOutlet UILabel *scaleLabel;

- (void)updateToolbarState;
- (void)updateToolbar;
- (void)initToolbar;

- (IBAction)changeMapViewType;

- (void)showWpGenerator;

- (void)showWpGen:(id)sender;
- (void)generateWayPoints;
- (void)configWayPoints:(id)sender;
- (void)dismiss;

@property(nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property(nonatomic, strong) UIPopoverController* popoverController;

@end

///////////////////////////////////////////////////////////////////////////////////
#pragma mark -
///////////////////////////////////////////////////////////////////////////////////
@implementation MKTRouteMapViewController

@synthesize route=_route;
@synthesize delegate=_delegate;

@synthesize lm;

@synthesize popoverController;
@synthesize mapView = _mapView;
@synthesize curlBarItem;
@synthesize spacer;
@synthesize addButton;
@synthesize addWithGpsButton;
@synthesize segmentedControl;
@synthesize showOwnPosition;
@synthesize scaleLabel;

@synthesize forWpGenModal;
@synthesize wpgenController;
@synthesize wpGenerateItem;
@synthesize wpGenButton;

@synthesize wpGeneratorSelection;
@synthesize wpGeneratorSelectionButton;
@synthesize wpGenerateConfigItem;

@synthesize fetchedResultsController = _fetchedResultsController;

///////////////////////////////////////////////////////////////////////////////////
#pragma mark -

- (id)initWithRoute:(MKTRoute *)route{
  return [self initWithRoute:route delegate:nil];
}

- (id)initWithRoute:(MKTRoute *)route delegate:(id <MKTRouteViewControllerDelegate>)delegate {
  
  self = [super initWithNibName:@"MKTRouteMapViewController" bundle:nil];
  if (self) {
    self.route = route;
    self.delegate = delegate;
    
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self initToolbar];
  
  self.lm = [CLLocationManager new];
  self.lm.delegate = self;
  self.lm.desiredAccuracy = kCLLocationAccuracyBest;

  self.segmentedControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] gh_integerForKey:MKTRouteMapViewType 
                                                                                           withDefault:0];
  
  self.showOwnPosition.on = [[NSUserDefaults standardUserDefaults] gh_boolForKey:MKTRouteMapViewShowPosition 
                                                                        withDefault:NO];
  [self changeMapViewType];
  
  UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
  [self.mapView addGestureRecognizer:longTap];

}

- (void)viewDidUnload
{
  [super viewDidUnload];
  self.route = nil;

  self.mapView = nil;
  self.curlBarItem = nil;
  self.spacer = nil;
  self.addButton = nil;
  self.addWithGpsButton = nil;
  self.segmentedControl = nil;
  self.showOwnPosition = nil;
  self.scaleLabel = nil;
  self.wpgenController = nil;
  self.wpGenerateItem = nil;
  self.wpGeneratorSelection = nil;
  self.wpGeneratorSelectionButton = nil;
  self.wpGenerateConfigItem = nil;
  self.wpGenButton = nil;

  [self.lm stopUpdatingLocation];
  self.lm = nil;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if(IS_IPAD())
    self.navigationItem.hidesBackButton=YES;
  
  [self updateToolbar];
  
  [self updateMapView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

///////////////////////////////////////////////////////////////////////////////////
#pragma mark - Page Curl stuff

- (void)changeMapViewType {
  [self.mapView setMapType:(MKMapType)self.segmentedControl.selectedSegmentIndex];
  self.mapView.showsUserLocation = self.showOwnPosition.on;
  
  [self.curlBarItem curlViewDown];
  
  [[NSUserDefaults standardUserDefaults] setInteger:self.segmentedControl.selectedSegmentIndex forKey:MKTRouteMapViewType];
  [[NSUserDefaults standardUserDefaults] setBool:self.showOwnPosition.on forKey:MKTRouteMapViewShowPosition];
}

- (void)curlViewControlWillCurlViewUp:(FDCurlViewControl *)control{
  self.scaleLabel.hidden=YES;
}
- (void)curlViewControlDidCurlViewDown:(FDCurlViewControl *)control{
  self.scaleLabel.hidden=NO;
}


///////////////////////////////////////////////////////////////////////////////////
#pragma mark - Toolbar Stuff

- (void)initToolbar{
  
  self.spacer = [[UIBarButtonItem alloc]
                 initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                 target:nil action:nil];

  self.curlBarItem = [[FDCurlViewControl alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPageCurl];
  self.curlBarItem.delegate = self;
  [self.curlBarItem setHidesWhenAnimating:NO];
  [self.curlBarItem setTargetView:self.mapView];
  
  UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self.curlBarItem
                                                                              action:@selector(curlViewDown)];
  [self.view addGestureRecognizer:singleTap];
  
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

  
  self.wpGenerateItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Generate", @"Gernerate WP") style:UIBarButtonItemStyleBordered
                                                         target:self action:@selector(generateWayPoints)];
  
  
  self.wpGenerateConfigItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-settings3.png"]
                                                                style:UIBarButtonItemStyleBordered
                                                               target:self action:@selector(configWayPoints:)];
  
  NSArray *segmentItems = [NSArray arrayWithObjects:@"AREA", @"CIRCLE", @"PANO", nil];
  
  self.wpGeneratorSelection = [[UISegmentedControl alloc] initWithItems:segmentItems];
  self.wpGeneratorSelection.segmentedControlStyle = UISegmentedControlStyleBar;
  
  [self.wpGeneratorSelection setImage:[UIImage imageNamed:@"wpgen-area.png"] forSegmentAtIndex:0];
  [self.wpGeneratorSelection setImage:[UIImage imageNamed:@"wpgen-circle.png"] forSegmentAtIndex:1];
  [self.wpGeneratorSelection setImage:[UIImage imageNamed:@"wpgen-pano.png"] forSegmentAtIndex:2];
  
  self.wpGeneratorSelection.momentary = YES;
  
  [self.wpGeneratorSelection addTarget:self
                                action:@selector(showWpGen:)
                      forControlEvents:UIControlEventValueChanged];
  
  self.wpGeneratorSelectionButton = [[UIBarButtonItem alloc]
                    initWithCustomView:self.wpGeneratorSelection];

  self.wpGenButton = [[UIBarButtonItem alloc] initWithTitle:@"WP" 
                                                       style:UIBarButtonItemStyleBordered 
                                                      target:self action:@selector(showWpGenerator)];

  
  if(self.forWpGenModal) {
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                 target:self
                                                                                 action:@selector(dismiss)];
    
    self.navigationItem.leftBarButtonItem = doneButton;
  }

}

- (void)updateToolbar {
  
  NSMutableArray *tbArray = [NSMutableArray array];
  
  [tbArray addObject:self.curlBarItem];
  [tbArray addObject:self.spacer];
  
  if(IS_IPAD() || self.forWpGenModal){

    [tbArray addObject:self.wpGenerateConfigItem];
    [tbArray addObject:self.wpGenerateItem];
    [tbArray addObject:self.wpGeneratorSelectionButton];

  }
  else{
    [tbArray addObject:self.wpGenButton];
    [tbArray addObject:self.addWithGpsButton];
    [tbArray addObject:self.addButton];
  }
  if (self.delegate) {
    
    self.toolbarItems = tbArray;
    NSLog(@"updated MAP toolbar %@",self.toolbarItems);
    [self.delegate controllerDidChangeToolbar:self];
  }
  else {
    [self setToolbarItems:tbArray animated:YES];
    self.navigationController.toolbarHidden = NO;
  }
  
  [self updateToolbarState];
}

- (void)updateToolbarState{
  BOOL wpgen = self.wpgenController != nil;
  self.wpGenerateItem.enabled = wpgen;
  self.wpGenerateConfigItem.enabled = wpgen;
  self.wpGeneratorSelection.enabled = !wpgen;
}


#pragma mark - The actions

- (void)addPoint {
  [self.route addPointAtCenter];

  if(self.route.count==1)
    [self updateMapView];
}

- (void)addPointWithGps {
  [self.lm startUpdatingLocation];
  waitForLocation=YES;
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
  CGPoint p = [gestureRecognizer locationInView:self.mapView];
  
  if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:p toCoordinateFromView:self.mapView];
    [self.route addPointAtCoordinate:coordinate];
  }
}


- (void)showViewControllerForPoint:(MKTPoint *)point forAnnotationView:(MKAnnotationView*)view{
  
  MKTPointViewController *controller = [[MKTPointViewController alloc] initWithPoint:point];

  if(IS_IPAD()){

    [self clearAllSelections];
    [self.popoverController dismissPopoverAnimated:NO];
    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:controller];

    CGRect rect = CGRectMake(CGRectGetMidX(view.bounds) + view.calloutOffset.x - 3, 0, 3, 1);
    [self.popoverController presentPopoverFromRect:rect inView:view
                     permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    [self.mapView deselectAnnotation:[view annotation] animated:NO];
  }
  else {
    [self.navigationController pushViewController:controller animated:YES];
  }
}


- (void) clearAllSelections{
  
  [self.mapView.annotations each:^(id<MKAnnotation> a){
    [self.mapView deselectAnnotation:a animated:YES];
  }];
}


#pragma mark - CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
  
  if (!waitForLocation || ([newLocation.timestamp timeIntervalSince1970] < [NSDate timeIntervalSinceReferenceDate] - 60))
    return;
  
  [self.lm stopUpdatingLocation];
  waitForLocation=NO;
  [self.route addPointAtCoordinate:newLocation.coordinate];
  
  if(self.route.count==1)
    [self updateMapView];
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
  waitForLocation=NO;
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
  [self updateToolbar];
}


#pragma mark - Updating the map view

- (void)updateMapView {
  
  id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
  
  NSUInteger numberOfpoints = [sectionInfo numberOfObjects];

  [self.mapView removeAnnotations:self.mapView.annotations];
  [self.mapView addAnnotations:[sectionInfo objects]];
  [self updateRouteOverlay];
  
  if (numberOfpoints> 1) {
    
    MKCoordinateRegion region = [YKMKUtils regionThatFits:self.mapView.annotations];

    [self.mapView setRegion:region];
//   
//    MKMapRect flyTo = MKMapRectNull;
//    
//    for (id <MKOverlay> overlay in self.mapView.overlays) {
//      if (MKMapRectIsNull(flyTo)) {
//        flyTo = [overlay boundingMapRect];
//      } else {
//        flyTo = MKMapRectUnion(flyTo, [overlay boundingMapRect]);
//      }
//    }
//    
//    for (id <MKAnnotation> annotation in self.mapView.annotations) {
//      MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
//      MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
//      
//      if (MKMapRectIsNull(flyTo)) {
//        flyTo = pointRect;
//      } else {
//        flyTo = MKMapRectUnion(flyTo, pointRect);
//      }
//    }
//    
//    flyTo = [self.mapView mapRectThatFits:flyTo];
//    
//    // Position the map so that all overlays and annotations are visible on screen.
//    [self.mapView setVisibleMapRect:flyTo animated:YES];
  }
  else if (numberOfpoints == 1) {
    MKTPoint *pt = [self.route.points anyObject];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(pt.coordinate, 2000, 2000);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
  }
  else {
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance([MKTRoute defaultCoordinate], 2000, 2000);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - MKMapViewDelegate
///////////////////////////////////////////////////////////////////////////////////////////////////

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {

  if ([annotation isKindOfClass:[MKTPoint class]]) {
    MKTPointAnnotationView *annotationView;
    annotationView = (MKTPointAnnotationView*)[theMapView dequeueReusableAnnotationViewWithIdentifier:[MKTPointAnnotationView viewReuseIdentifier]];
    if (annotationView == nil)
      annotationView = [[MKTPointAnnotationView alloc] initWithPoint:(MKTPoint*)annotation];
    else
      annotationView.point = annotation;

    return annotationView;
  }
    
  return nil;
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)theMapView withError:(NSError *)error {
  UIAlertView *alert = [[UIAlertView alloc]
                        initWithTitle:NSLocalizedString(@"Error loading map", @"Error loading map") message:[error localizedDescription]
                        delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Okay") otherButtonTitles:nil];
  [alert show];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
  if ([view.annotation isKindOfClass:[MKTPoint class]]) {
    MKTPoint *point = (MKTPoint *) view.annotation;
    
    if (view.rightCalloutAccessoryView == control) {
      [self showViewControllerForPoint:point forAnnotationView:view];
    }
    else {
      [self.route deletePoint:point];
    }
  }
}



- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)view
didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState {
  
  
  if (newState == MKAnnotationViewDragStateEnding) {
    [[CoreDataStore mainStore] save];
    [self updateRouteOverlay];
    
//    [self performSelector:@selector(clearAllSelections) withObject:self afterDelay:0.1];

    NSLog(@"MKAnnotationViewDragStateEnding %@",[(MKTPoint*)view.annotation name]);

    userDrivenDataModelChange=NO;
  }
  else if (newState == MKAnnotationViewDragStateStarting) {
    userDrivenDataModelChange=YES;
  }
}

- (void)mapView:(MKMapView *)theMapView regionDidChangeAnimated:(BOOL)animated {
  CGRect frame = scaleLabel.frame;
  
  CGFloat maxLabelWidth = 150;
  CGPoint p1 = CGPointMake(0, CGRectGetMinY(frame));
  CGPoint p2 = CGPointMake(maxLabelWidth, CGRectGetMinY(frame));
  
  CLLocationCoordinate2D lc1 = [theMapView convertPoint:p1 toCoordinateFromView:self.mapView];
  CLLocationCoordinate2D lc2 = [theMapView convertPoint:p2 toCoordinateFromView:self.mapView];
  CLLocation *l1 = [[CLLocation alloc] initWithLatitude:lc1.latitude longitude:lc1.longitude];
  CLLocation *l2 = [[CLLocation alloc] initWithLatitude:lc2.latitude longitude:lc2.longitude];
  CLLocationDistance dist = [l1 distanceFromLocation:l2];
  
  CGFloat labelWidth = maxLabelWidth;
  
  NSInteger widthFactor;
  CGFloat mul;
  for (widthFactor = 6; widthFactor > 0; widthFactor--) {
    mul = powf(10, widthFactor);
    
    labelWidth = (mul * maxLabelWidth) / dist;
    if (labelWidth < maxLabelWidth)
      break;
  }
  
  
  if (labelWidth < (maxLabelWidth / 5)) {
    labelWidth *= 5;
    mul *= 5;
  }
  else if (labelWidth < (maxLabelWidth / 2)) {
    labelWidth *= 2;
    mul *= 2;
  }
  
  
  if (widthFactor > 2) {
    scaleLabel.text = [NSString stringWithFormat:@"%d km", (int) (mul / 1000)];
  }
  else {
    scaleLabel.text = [NSString stringWithFormat:@"%d m", (int) (mul)];
  }
  
  CGFloat rightX = CGRectGetMaxX(frame);
  scaleLabel.frame = CGRectMake(rightX - labelWidth, frame.origin.y, labelWidth, frame.size.height);
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
  
  if ([overlay isKindOfClass:[MKPolyline class]]) {
    
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:(MKPolyline *)overlay];
    polylineView.strokeColor = [UIColor blueColor];
    polylineView.lineWidth = 1.5;
    return polylineView;
  }
  else if ([overlay isKindOfClass:[HeadingOverlay class]]) {
    
    HeadingOverlayView *circleView = [[HeadingOverlayView alloc] initWithHeadingOverlay:(HeadingOverlay *)overlay];
    circleView.strokeColor = [UIColor yellowColor];
    
    circleView.fillColor = [circleView.strokeColor colorWithAlphaComponent:0.4];
    circleView.lineWidth = 1.5;
    return circleView;
  }
  else if ([overlay isKindOfClass:[MKCircle class]]) {
    MKCircleView *circleView = [[MKCircleView alloc] initWithCircle:(MKCircle *)overlay];
    if ([((MKCircle *) overlay).title length] > 0) {
      circleView.strokeColor = [UIColor redColor];
    }
    else {
      circleView.strokeColor = [UIColor greenColor];
    }
    circleView.fillColor = [circleView.strokeColor colorWithAlphaComponent:0.4];
    circleView.lineWidth = 1.5;
    return circleView;
  }
  
  return nil;
}


#pragma mark Overlays

- (void)doUpdateRouteOverlay {
  CLLocationCoordinate2D coordinates[[self.route.points count]];
  
  [self.mapView removeOverlays:self.mapView.overlays];
  
  NSArray* orderedPoints = [self.route orderedPoints];

  int i = 0;
  for (MKTPoint *p in orderedPoints) {
    if (p.typeValue == MKTPointTypeWP) {
      coordinates[i] = p.coordinate;
      
      MKCircle *c = [MKCircle circleWithCenterCoordinate:p.coordinate radius:p.toleranceRadiusValue];
      if (i == 0)
        c.title = @"start";
      
      [self.mapView addOverlay:c];
      
      BOOL createOverlay = YES;
      if (p.headingValue != 0) {
        
        double angle = p.headingValue;
        if (p.headingValue < 0) {
          
          int idx = (-p.headingValue) - 1;
          if (idx >= 0 && idx < orderedPoints.count) {
            
            MKTPoint *poi = [orderedPoints objectAtIndex:idx];
            
            MKMapPoint pPoint = MKMapPointForCoordinate(p.coordinate);
            MKMapPoint poiPoint = MKMapPointForCoordinate(poi.coordinate);
            
            double ank = poiPoint.x - pPoint.x;
            double gek = poiPoint.y - pPoint.y;
            
            angle = (atan(gek / ank) * 180.0) / M_PI;
            if (ank < 0)
              angle += 180.0;
          }
          else {
            createOverlay = NO;
          }
        }
        else {
          angle -= 90.0;
        }
        if (createOverlay) {
          HeadingOverlay *h = [HeadingOverlay headingWithCenterCoordinate:p.coordinate radius:10 angle:angle];
          [self.mapView addOverlay:h];
        }
      }
      
      i++;
      
    }
  }
  
  [self.mapView addOverlay:[MKPolyline polylineWithCoordinates:coordinates count:i]];
}


- (void)updateAnnotations{
  id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];

  [self.mapView removeAnnotations:self.mapView.annotations];
  [self.mapView addAnnotations:[sectionInfo objects]];
  [self doUpdateRouteOverlay];
}

- (void)updateRouteOverlay {
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doUpdateRouteOverlay) object: self];
  [self performSelector:@selector(doUpdateRouteOverlay) withObject:self afterDelay:0.5];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Fetched results controller delegate
///////////////////////////////////////////////////////////////////////////////////////////////////


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {

  if(userDrivenDataModelChange) return;
  
  switch (type) {
      
    case NSFetchedResultsChangeInsert:
      [self.mapView addAnnotation:(id<MKAnnotation>)anObject];
      break;
    
    case NSFetchedResultsChangeDelete:
      [self.mapView removeAnnotation:(id<MKAnnotation>)anObject];
      break;

    case NSFetchedResultsChangeUpdate:
      NSLog(@"NSFetchedResultsChangeUpdate %@",[anObject name]);
      [self.mapView removeAnnotation:(id<MKAnnotation>)anObject];
      [self.mapView addAnnotation:(id<MKAnnotation>)anObject];
      break;
      
    case NSFetchedResultsChangeMove:
      break;
  }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
  if(userDrivenDataModelChange) return;
  [self updateRouteOverlay];
}

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
#pragma mark - Wayponint generation

- (void)showWpGen:(id)sender {
  
  switch (self.wpGeneratorSelection.selectedSegmentIndex) {
    case 0:
      self.wpgenController = [[WPGenAreaViewController alloc] initForMapView:self.mapView];
      break;
      
    case 1:
      self.wpgenController = [[WPGenCircleViewController alloc] initForMapView:self.mapView];
      break;
      
    case 2:
      self.wpgenController = [[WPGenPanoViewController alloc] initForMapView:self.mapView];
      break;
      
    default:
      self.wpgenController = nil;
      break;
  }
  self.wpgenController.delegate = self;
  self.wpgenController.parentController = self;
  
  [self updateToolbarState];
  [self.mapView addSubview:self.wpgenController.view];
  
}

- (void)generateWayPoints {
  [self.wpgenController generatePoints:self];
}

- (void)configWayPoints:(id)sender {
  [self.wpgenController showConfig:sender];
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


- (void)dismiss{
  [self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark - Waypoint Generator Delegate

- (void)controllerWillClose:(WPGenBaseViewController *)controller {
  self.wpgenController = nil;
  [self updateToolbarState];
}

- (void)controller:(WPGenBaseViewController *)controller generatedPoints:(NSArray *)points clearList:(BOOL)clear {
  
  if (clear)
   [self.route removeAllPoints];
  
  [self.route addPointsFromArray:points];
  
//  
//  id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
//  
//  NSUInteger numberOfpoints = [sectionInfo numberOfObjects];
//  
//  [self.mapView removeAnnotations:self.mapView.annotations];
//  [self.mapView addAnnotations:[sectionInfo objects]];
//  [self updateRouteOverlay];
//
//  
//  [self.mapView removeAnnotations:self.mapView.annotations];
//  [self.mapView addAnnotations:route.points];
//  [self updateRouteOverlay];
//  
//  [Route sendChangedNotification:self];
  
  [[CoreDataStore mainStore] save];
  
}

@end
