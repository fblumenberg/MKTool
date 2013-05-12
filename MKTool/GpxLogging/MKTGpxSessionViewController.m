//
//  MKTGpxSessionViewController.m
//  MKTool
//
//  Created by Frank Blumenberg on 12.05.13.
//
//

#import "MKTGpxSessionViewController.h"
#import "MKTGpxSession.h"
#import "MKTGpxRecord.h"
#import "IKNaviData.h"
#import "NSArray+BlocksKit.h"

@interface MKTGpxSessionViewController ()<MKMapViewDelegate>

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
  
  self.title = [NSDateFormatter localizedStringFromDate:self.session.startTime dateStyle:kCFDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
  self.startTime.text = [NSDateFormatter localizedStringFromDate:self.session.startTime dateStyle:kCFDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
  self.endTime.text = [NSDateFormatter localizedStringFromDate:self.session.endTime dateStyle:kCFDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
  self.recordsCount.text = [NSString stringWithFormat:@"%d", [self.session.records count]];
  
  self.mapView.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];

  self.mapView.mapType = MKMapTypeHybrid;
  
  if(self.session.regionData){
    MKCoordinateRegion region = [self.mapView regionThatFits:self.session.region];
    [self.mapView setRegion:region animated:YES];
  }
}


- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  // here's where you specify the sort
  NSArray *sortedRecords = [self.session orderedRecords];
  
  __block CLLocationCoordinate2D* coordinates = malloc(sortedRecords.count * sizeof(CLLocationCoordinate2D));
  [self.mapView removeOverlays:self.mapView.overlays];
  
  [sortedRecords enumerateObjectsUsingBlock:^(MKTGpxRecord *r, NSUInteger i, BOOL *stop) {
    IKGPSPos* gpsPos = r.gpsPos;
    coordinates[i] = gpsPos.coordinate;
  }];
  
  [self.mapView addOverlay:[MKPolyline polylineWithCoordinates:coordinates count:sortedRecords.count]];
  
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


- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
  
  self.mapView.delegate = nil;
  
  [self setStartTime:nil];
  [self setEndTime:nil];
  [self setRecordsCount:nil];
  [self setMapView:nil];
  [super viewDidUnload];
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

@end
