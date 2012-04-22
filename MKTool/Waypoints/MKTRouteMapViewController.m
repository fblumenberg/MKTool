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

#import "MKTRouteMapViewController.h"

@interface MKTRouteMapViewController ()

@property(nonatomic,strong) IBOutlet MKMapView *mapView;
//@property(retain) FDCurlViewControl *curlBarItem;
@property(nonatomic,strong) IBOutlet UISegmentedControl *segmentedControl;
@property(nonatomic,strong) IBOutlet UILabel *scaleLabel;

@end

@implementation MKTRouteMapViewController

@synthesize route=_route;
@synthesize delegate=_delegate;

@synthesize mapView = _mapView;
//@synthesize curlBarItem;
@synthesize segmentedControl;
@synthesize scaleLabel;

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

#pragma mark - Page Curl stuff

- (void)changeMapViewType {
  [self.mapView setMapType:(MKMapType)self.segmentedControl.selectedSegmentIndex];
  [self.curlBarItem curlViewDown];
  [[NSUserDefaults standardUserDefaults] setInteger:self.segmentedControl.selectedSegmentIndex forKey:@"RouteMapViewType"];
}


@end
