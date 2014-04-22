// ///////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013, Frank Blumenberg
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

#import "MKTGpxSessionViewController.h"
#import "MKTGpxSession.h"
#import "MKTGpxRecord.h"
#import "MKTGpxDropboxController.h"
#import "IKNaviData.h"
#import "NSArray+BlocksKit.h"
#import "UIActionSheet+BlocksKit.h"
#import "InnerBand.h"
#import "MBProgressHUD.h"

@interface MKTGpxSessionViewController ()<MKMapViewDelegate,MKTGpxDropboxControllerDelegate>
@property(strong)  UIBarButtonItem *spacer;
@property(strong)  UIBarButtonItem *deleteItem;
@property(strong)  UIBarButtonItem *action;
@property(strong) MKTGpxDropboxController* dropboxController;
@end

@implementation MKTGpxSessionViewController

- (id)initWithSession:(MKTGpxSession*)session {
  self = [super initWithNibName:@"MKTGpxSessionViewController" bundle:nil];
  if (self) {
    self.session = session;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.dropboxController = [MKTGpxDropboxController new];
  self.dropboxController.delegate = self;
  
  self.title = [NSDateFormatter localizedStringFromDate:self.session.startTime dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
  self.startTime.text = [NSDateFormatter localizedStringFromDate:self.session.startTime dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
  self.endTime.text = [NSDateFormatter localizedStringFromDate:self.session.endTime dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
  self.recordsCount.text = [NSString stringWithFormat:@"%d", [self.session.records count]];
  
  self.mapView.delegate = self;
  
  self.spacer = [[UIBarButtonItem alloc]
                 initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                 target:nil action:nil] ;
  
  //  UIBarButtonItem *mail;
  //  mail = [[UIBarButtonItem alloc]
  //           initWithImage:[UIImage imageNamed:@"icon-mail1.png"]
  //           style:UIBarButtonItemStylePlain
  //           target:self
  //           action:@selector(sendSessionAsEmail)];
  
  self.deleteItem = [[UIBarButtonItem alloc]
                     initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                     target:self
                     action:@selector(deleteSession)];
  
  self.action = [[UIBarButtonItem alloc]
                 initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                 target:self
                 action:@selector(sendSession)];
  
  [self setToolbarItems:@[self.action, self.spacer, self.deleteItem]];
  self.navigationController.toolbarHidden = NO;
}

- (void) viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  
  if (IB_IS_IPAD())
    self.navigationItem.hidesBackButton = YES;
  
  self.mapView.mapType = MKMapTypeHybrid;
  
  if(self.session.regionData){
    MKCoordinateRegion region = [self.mapView regionThatFits:self.session.region];
    [self.mapView setRegion:region animated:YES];
  }
}


- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self performSelector:@selector(showRoute) withObject:self afterDelay:0.5];
}


- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
  
  self.mapView.delegate = nil;
  
  [self setStartTime:nil];
  [self setEndTime:nil];
  [self setRecordsCount:nil];
  [self setMapView:nil];
  [super viewDidUnload];
}


- (void) showRoute{
  
  NSArray *sortedRecords = [self.session orderedRecords];
  
  __block CLLocationCoordinate2D* coordinates = malloc(sortedRecords.count * sizeof(CLLocationCoordinate2D));
  [self.mapView removeOverlays:self.mapView.overlays];
  
  [sortedRecords enumerateObjectsUsingBlock:^(MKTGpxRecord *r, NSUInteger i, BOOL *stop) {
    IKGPSPos* gpsPos = r.gpsPos;
    coordinates[i] = gpsPos.coordinate;
  }];
  
  if(sortedRecords.count){
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = coordinates[0];
    [self.mapView addAnnotation:point];
    [self.mapView addOverlay:[MKPolyline polylineWithCoordinates:coordinates count:sortedRecords.count]];
  }
  free(coordinates);
  
  MKMapRect flyTo = MKMapRectNull;
  
  for (id <MKOverlay> overlay in self.mapView.overlays) {
    if (MKMapRectIsNull(flyTo)) {
      flyTo = [overlay boundingMapRect];
    } else {
      flyTo = MKMapRectUnion(flyTo, [overlay boundingMapRect]);
    }
  }
  
  flyTo = [self.mapView mapRectThatFits:flyTo];
  
  // Position the map so that all overlays and annotations are visible on screen.
  [self.mapView setVisibleMapRect:flyTo animated:YES];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
  
  if ([overlay isKindOfClass:[MKPolyline class]]) {
    
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor blueColor];
    polylineView.lineWidth = 1.5;
    return polylineView;
  }
  
  return nil;
}

- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
  MKPinAnnotationView* view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
  view.pinColor = MKPinAnnotationColorRed;
  return view;
}

-(void)deleteSession{
  
  UIActionSheet *deleteQuerySheet = [UIActionSheet bk_actionSheetWithTitle:nil];
  [deleteQuerySheet bk_setDestructiveButtonWithTitle:NSLocalizedString(@"Delete", @"Delete Button") handler:^{
    [self.session destroy];
    [self.navigationController popToRootViewControllerAnimated:YES];
  }];
  [deleteQuerySheet bk_setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel Button") handler:^{}];
  [deleteQuerySheet showInView:self.view];
  
  [deleteQuerySheet showFromBarButtonItem:self.deleteItem animated:YES];
}

///////////////////////////////////////////////////////////////////////////////////
#pragma mark - Synchronizing
///////////////////////////////////////////////////////////////////////////////////

-(void)sendSession{
  
  [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
  [self.dropboxController connectAndPrepareFromController:self];
}

- (void)sendSessionComplete{
  [MBProgressHUD hideHUDForView:self.view.window animated:YES];
}

- (void)dropboxReady:(MKTGpxDropboxController*)controller{
  [self.dropboxController syncronizeSession:self.session fromController:self];
}

- (void)controller:(MKTGpxDropboxController*)crontroller dropboxInitFailedWithError:(NSError*)error{
  [self sendSessionComplete];
}

- (void)controller:(MKTGpxDropboxController*)crontroller syncFailedWithError:(NSError*)error{
  [self sendSessionComplete];
}

- (void)controllerSyncCompleted:(MKTGpxDropboxController*)crontroller{
  [self sendSessionComplete];
}

- (void)controllerPausedInit:(MKTGpxDropboxController*)crontroller{
  [MBProgressHUD hideHUDForView:self.view.window animated:YES];
}
- (void)controllerRestartedInit:(MKTGpxDropboxController*)crontroller{
  [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
}


@end
