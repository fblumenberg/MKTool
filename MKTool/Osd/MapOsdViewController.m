// ///////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2011, Frank Blumenberg
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

#import "MapOsdViewController.h"
#import "MapLocation.h"
#import "HeadingOverlay.h"
#import "HeadingOverlayView.h"
#import "IKPoint.h"
#import <BlocksKit.h>

//#import "MKTPoint.h"
//#import "MKTPointAnnotationView.h"
#import "MKTCircleOverlay.h"

@interface MapOsdViewController ()

- (void)updateViewWithOrientation:(UIInterfaceOrientation)orientation;

@end

@implementation MapOsdViewController

@synthesize mapView = _mapView;
//@synthesize routeController = _routeController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
//    self.routeController = [[[RouteController alloc] initWithDelegate:self] autorelease];
  }
  return self;
}

- (void)dealloc {
  self.mapView = nil;
//  self.routeController = nil;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  needRegionAdjustment = YES;
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [self updateViewWithOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
  [super willRotateToInterfaceOrientation:orientation duration:duration];
  [self updateViewWithOrientation:orientation];
  needRegionAdjustment = YES;
}

- (void)updateViewWithOrientation:(UIInterfaceOrientation)orientation {
  needRegionAdjustment = YES;
  [super updateViewWithOrientation:orientation];
}

#pragma mark - Map View Delegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
  static NSString *placemarkIdentifierDevice = @"Device Map Location Identifier";
  static NSString *placemarkIdentifier = @"Map Location Identifier";
  if ([annotation isKindOfClass:[MapLocation class]]) {
    MKAnnotationView *annotationView;

    if (((MapLocation *) annotation).type == IKMapLocationDevice) {
      annotationView = [theMapView dequeueReusableAnnotationViewWithIdentifier:placemarkIdentifierDevice];
      if (annotationView == nil)
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:placemarkIdentifierDevice];
      else
        annotationView.annotation = annotation;
      ((MKPinAnnotationView *) annotationView).animatesDrop = YES;
      ((MKPinAnnotationView *) annotationView).pinColor = MKPinAnnotationColorPurple;

      annotationView.enabled = YES;
      annotationView.canShowCallout = YES;
    }
    else {
      annotationView = [theMapView dequeueReusableAnnotationViewWithIdentifier:placemarkIdentifier];
      if (annotationView == nil)
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:placemarkIdentifier];
      else
        annotationView.annotation = annotation;

      annotationView.enabled = YES;
      switch (((MapLocation *) annotation).type) {
        case IKMapLocationCurrentPosition:
          annotationView.image = [UIImage imageNamed:@"annotation-current.png"];
          [annotationView setSelected:YES animated:NO];
          break;
        case IKMapLocationHomePosition:
          annotationView.image = [UIImage imageNamed:@"annotation-home.png"];
          break;
        case IKMapLocationTargetPosition:
          annotationView.image = [UIImage imageNamed:@"annotation-target.png"];
          break;
        default:
          break;
      }

      annotationView.centerOffset = CGPointMake(0.0, -16.0);
    }
    return annotationView;
  }
  
  return nil;
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)theMapView withError:(NSError *)error {
//  UIAlertView *alert = [[UIAlertView alloc]
//          initWithTitle:NSLocalizedString(@"Error loading map", @"Error loading map") message:[error localizedDescription]
//               delegate:nil cancelButtonTitle:NSLocalizedString(@"Okay", @"Okay") otherButtonTitles:nil];
//  [alert show];
}

- (void)updateAnnotationForType:(IKMapLocationType)type coordinate:(CLLocationCoordinate2D)coordinate {

  __block BOOL needNewAnnotation = YES;

  [self.mapView.annotations enumerateObjectsUsingBlock:^(id x, NSUInteger index, BOOL *stop) {
    if ([x isKindOfClass:[MapLocation class]]) {
      MapLocation *ml = x;
      if (ml.type == type) {
        ml.coordinate = coordinate;
        needNewAnnotation = NO;
        *stop = YES;
      }
    }
  }];

  if (needNewAnnotation) {
    MapLocation *annotation = [[MapLocation alloc] init];
    annotation.type = type;
    annotation.coordinate = coordinate;
    [self.mapView addAnnotation:annotation];
  }
}

#pragma mark - OsdValueDelegate

- (void)newValue:(OsdValue *)value {
  IKGPSPos *gpsPos;

  gpsPos = [IKGPSPos positionWithMkPos:&(value.data.data->TargetPosition)];
  [self updateAnnotationForType:IKMapLocationTargetPosition coordinate:gpsPos.coordinate];
  gpsPos = [IKGPSPos positionWithMkPos:&(value.data.data->CurrentPosition)];
  [self updateAnnotationForType:IKMapLocationCurrentPosition coordinate:gpsPos.coordinate];
  gpsPos = [IKGPSPos positionWithMkPos:&(value.data.data->HomePosition)];
  [self updateAnnotationForType:IKMapLocationHomePosition coordinate:gpsPos.coordinate];

  if (needRegionAdjustment && gpsPos.status != 0) {
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(gpsPos.coordinate, 500, 500);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:NO];
    needRegionAdjustment = NO;
  }

  //-----------------------------------------------------------------------
  [self updateHeightView:value];
  //-----------------------------------------------------------------------
  [self updateBatteryView:value];
  //-----------------------------------------------------------------------
  [self updateStateView:value];
  //-----------------------------------------------------------------------
  
  
  if([[self currentRouteAnnotations] count]!=[value.routePoints count]){
    [self newRouteDataAvailable:value.routePoints];
  }

}

- (void)noDataAvailable {

}

- (void)newRouteDataAvailable:(NSArray*) points{
  
  NSArray* toRemove = [self currentRouteAnnotations];
  
  [self.mapView removeAnnotations:toRemove];
  
  NSArray* toAdd = [points bk_map:^ id(id obj){
    IKPoint* p = (IKPoint*)obj;
    MapLocation* m = [[MapLocation alloc] init];
    
    m.coordinate = p.coordinate;
    m.type = p.type==POINT_TYPE_WP?IKMapLocationWayPoint:IKMapLocationPOI;
    return m;
  }];
  
  [self.mapView addAnnotations:toAdd];
  
  [self updateRouteOverlay:points];
}

- (NSArray*)currentRouteAnnotations{
  return  [self.mapView.annotations bk_select:^BOOL (id obj) {
    
    if ([obj isKindOfClass:[MapLocation class]])
      return (((MapLocation *) obj).type == IKMapLocationWayPoint || ((MapLocation *) obj).type == IKMapLocationPOI);
    
    return NO;
  }];
}

#pragma mark Overlays

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
  
  if ([overlay isKindOfClass:[MKPolyline class]]) {
    
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:(MKPolyline *) overlay];
    polylineView.strokeColor = [UIColor blueColor];
    polylineView.lineWidth = 1.5;
    return polylineView;
  }
  else if ([overlay isKindOfClass:[HeadingOverlay class]]) {
    
    HeadingOverlayView *circleView = [[HeadingOverlayView alloc] initWithHeadingOverlay:(HeadingOverlay *) overlay];
    circleView.strokeColor = [UIColor yellowColor];
    
    circleView.fillColor = [circleView.strokeColor colorWithAlphaComponent:0.4];
    circleView.lineWidth = 1.5;
    return circleView;
  }
  else if ([overlay isKindOfClass:[MKTCircleOverlay class]]) {
    
    MKTCircleOverlay *circleOverlay = (MKTCircleOverlay *) overlay;
    
    MKCircleView *circleView = [[MKCircleView alloc] initWithCircle:circleOverlay.circle];
    circleView.strokeColor = circleOverlay.strokeColor;
    circleView.fillColor = circleOverlay.fillColor;
    circleView.lineWidth = circleOverlay.lineWidth;
    
    return circleView;
  }
  
  return nil;
}


- (void)updateRouteOverlay:(NSArray*) points {

  CLLocationCoordinate2D coordinates[[points count]];
  
  [self.mapView removeOverlays:self.mapView.overlays];
  
  int i = 0;
  for (IKPoint *p in points) {
    if (p.type == POINT_TYPE_WP) {
      coordinates[i] = p.coordinate;
      
      MKTCircleOverlay *c = [MKTCircleOverlay circleWithCenterCoordinate:p.coordinate radius:p.toleranceRadius];
      
      if (i == 0) {
        c.strokeColor = [UIColor redColor];
        
        if (NO) {
          MKTCircleOverlay *fence = [MKTCircleOverlay circleWithCenterCoordinate:p.coordinate radius:125];
          fence.lineWidth = 1.5;
          fence.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
          [self.mapView addOverlay:fence];
          
          fence = [MKTCircleOverlay circleWithCenterCoordinate:p.coordinate radius:250];
          fence.lineWidth = 1.5;
          fence.strokeColor = [UIColor redColor];
          [self.mapView addOverlay:fence];
        }
      }
      else
        c.strokeColor = [UIColor greenColor];
      
      c.fillColor = [c.strokeColor colorWithAlphaComponent:0.4];
      c.lineWidth = 1.5;
      
      [self.mapView addOverlay:c];
      
      BOOL createOverlay = YES;
      if (p.heading != 0) {
        
        double angle = p.heading;
        if (p.heading < 0) {
          
          int idx = (-p.heading) - 1;
          if (idx >= 0 && idx < points.count) {
            
            IKPoint *poi = [points objectAtIndex:idx];
            
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


@end
