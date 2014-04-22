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

#import "MKTRouteMasterViewController.h"
#import "MKTRouteMapViewController.h"

#import "UIViewController+MGSplitViewController.h"

#import "InnerBand.h"

@interface MKTRouteMasterViewController () <MKTRouteViewControllerDelegate>{
  MKTRouteMapViewController *mapController;
}
@end

@implementation MKTRouteMasterViewController


- (id)initWithRoute:(MKTRoute *)route
{
    self = [super initWithRoute:route];
    if (self) {
      self.delegate = self;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];

  mapController = [[MKTRouteMapViewController alloc] initWithRoute:self.route];
  [[self detailViewController] pushViewController:mapController animated:YES];
  
  [[IBCoreDataStore mainStore].context.undoManager removeAllActions];
}

- (void)viewWillDisappear:(BOOL)animated{
  [super viewWillDisappear:animated];
  [[self detailViewController] popViewControllerAnimated:YES];
  mapController=nil;
  [[IBCoreDataStore mainStore].context.undoManager removeAllActions];
}

- (void)showViewControllerForPoint:(MKTPoint *)point{
  [mapController clearAllSelections];
  [super showViewControllerForPoint:point];
}

- (void)showPointOnMap:(MKTPoint*)point{
  [mapController showPointOnMap:point];
}

- (void)controllerDidChangeToolbar:(UIViewController *)controller{
  
}

- (CLLocationCoordinate2D) currentCoordinate{
  return mapController.mapView.centerCoordinate;
}


@end
