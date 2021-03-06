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


#import <QuartzCore/QuartzCore.h>

#import "MKTPoint.h"
#import "WPGenBaseViewController.h"
#import "WPGenConfigViewController.h"
#import "UIViewController+MGSplitViewController.h"

DEFINE_KEY_WITH_VALUE(WPaltitude, altitude);
DEFINE_KEY_WITH_VALUE(WPprefix, prefix);
DEFINE_KEY_WITH_VALUE(WPtoleranceRadius, toleranceRadius);
DEFINE_KEY_WITH_VALUE(WPholdTime, holdTime);
DEFINE_KEY_WITH_VALUE(WPcamAngle, camAngle);
DEFINE_KEY_WITH_VALUE(WPheading, heading);
DEFINE_KEY_WITH_VALUE(WPaltitudeRate, altitudeRate);
DEFINE_KEY_WITH_VALUE(WPspeed, speed);
DEFINE_KEY_WITH_VALUE(WPwpEventChannelValue, wpEventChannelValue);
DEFINE_KEY_WITH_VALUE(WPclearWpList, clearWpList);
DEFINE_KEY_WITH_VALUE(WPnoPointsX, noPointsX);
DEFINE_KEY_WITH_VALUE(WPnoPointsY, noPointsY);
DEFINE_KEY_WITH_VALUE(WPnoPoints, noPoints);
DEFINE_KEY_WITH_VALUE(WPstartangle, startangle);
DEFINE_KEY_WITH_VALUE(WPclockwise, clockwise);
DEFINE_KEY_WITH_VALUE(WPclosed, closed);


@interface WPGenBaseViewController () <UIGestureRecognizerDelegate, UIPopoverControllerDelegate> {
  CGFloat firstX;
  CGFloat firstY;

  CGFloat restX;
  CGFloat restY;
}

@property(retain, nonatomic) IBOutlet UIView *resizeHandle;

@property(retain, nonatomic) UIPopoverController *popOverController;

- (void)resize:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)scale:(UIPinchGestureRecognizer *)gestureRecognizer;
- (void)rotate:(UIRotationGestureRecognizer *)gestureRecognizer;
- (void)move:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)dummyTapped:(UITapGestureRecognizer *)gestureRecognizer;


@end

@implementation WPGenBaseViewController

@synthesize resizeHandle = _resizeHandle;
@synthesize shapeView = _shapeView;
@synthesize mapView = _mapView;
@synthesize wpData;
@synthesize delegate;
@synthesize dataSource = _dataSource;
@synthesize popOverController;
@synthesize parentController;

- (id)initWithShapeView:(UIView *)shapeView forMapView:(MKMapView *)mapView {
  self = [super initWithNibName:@"WPGenBaseViewController" bundle:nil];
  if (self) {
    self.mapView = mapView;
    self.shapeView = shapeView;
    self.wpData = [[NSMutableDictionary alloc] initWithCapacity:8];

    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [self.wpData setValue:[NSNumber numberWithInteger:0] forKey:WPheading];
    [self.wpData setValue:[NSNumber numberWithInteger:[d integerForKey:@"WpDefaultAltitude"]] forKey:WPaltitude];
    [self.wpData setValue:[NSNumber numberWithInteger:[d integerForKey:@"WpDefaultAltitudeRate"]] forKey:WPaltitudeRate];
    [self.wpData setValue:[NSNumber numberWithInteger:[d integerForKey:@"WpDefaultCamAngle"]] forKey:WPcamAngle];
    [self.wpData setValue:[NSNumber numberWithInteger:[d integerForKey:@"WpDefaultSpeed"]] forKey:WPspeed];
    [self.wpData setValue:[NSNumber numberWithInteger:[d integerForKey:@"WpDefaultToleranceRadius"]] forKey:WPtoleranceRadius];
    [self.wpData setValue:[NSNumber numberWithInteger:[d integerForKey:@"WpDefaultHoldTime"]] forKey:WPholdTime];
    [self.wpData setValue:[NSNumber numberWithInteger:0] forKey:WPwpEventChannelValue];
    [self.wpData setValue:[NSNumber numberWithBool:NO] forKey:WPclearWpList];

  }
  return self;
}

- (void)dealloc {
  self.wpData = nil;
  self.resizeHandle = nil;
  self.mapView = nil;
  self.shapeView = nil;
  self.popOverController = nil;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.shapeView.frame = CGRectInset(self.view.bounds, 20, 0);
  self.shapeView.frame = CGRectOffset(self.shapeView.frame, -self.shapeView.frame.origin.x, 0);

  self.shapeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view insertSubview:self.shapeView belowSubview:self.resizeHandle];

  UIPanGestureRecognizer *moveRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
  [moveRecognizer setMinimumNumberOfTouches:1];
  [moveRecognizer setMaximumNumberOfTouches:1];
  [moveRecognizer setDelegate:self];
  [self.view addGestureRecognizer:moveRecognizer];

  UIPanGestureRecognizer *resizeRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(resize:)];
  [resizeRecognizer setMinimumNumberOfTouches:1];
  [resizeRecognizer setMaximumNumberOfTouches:1];
  [resizeRecognizer setDelegate:self];
  [self.resizeHandle addGestureRecognizer:resizeRecognizer];

  UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
  [pinchRecognizer setDelegate:self];
  [self.view addGestureRecognizer:pinchRecognizer];

  UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
  [rotationRecognizer setDelegate:self];
  [self.view addGestureRecognizer:rotationRecognizer];

  UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dummyTapped:)];
  [tapRecognizer setNumberOfTapsRequired:1];
  [tapRecognizer setNumberOfTouchesRequired:2];
  [self.view addGestureRecognizer:tapRecognizer];

  [self performSelector:@selector(myViewDidLoad) withObject:nil afterDelay:0.0];
}

- (void)myViewDidLoad {
  CGSize size = self.view.superview.frame.size;
  [self.view setCenter:CGPointMake(size.width / 2, size.height / 2)];
}

- (void)viewDidUnload {
  self.resizeHandle = nil;
  self.mapView = nil;
  self.popOverController = nil;

  [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (MKTPoint *)pointOfType:(NSInteger)type forCoordinate:(CLLocationCoordinate2D)coordinate {
  MKTPoint *newPoint = [MKTPoint create];
  
  newPoint.coordinate = coordinate;

  newPoint.heading = [self.wpData objectForKey:WPheading];
  newPoint.toleranceRadius = [self.wpData objectForKey:WPtoleranceRadius];
  newPoint.holdTime = [self.wpData objectForKey:WPholdTime];
  newPoint.eventFlag = 0;
  newPoint.prefix = [self.wpData objectForKey:WPprefix];
  newPoint.indexValue = 255;
  newPoint.typeValue = type;
  newPoint.altitude = [self.wpData objectForKey:WPaltitude] ;
  newPoint.eventChannelValue = [self.wpData objectForKey:WPwpEventChannelValue];
  newPoint.altitudeRate = [self.wpData objectForKey:WPaltitudeRate];
  newPoint.speed = [self.wpData objectForKey:WPspeed];
  newPoint.cameraAngle = [self.wpData objectForKey:WPcamAngle];

  return newPoint;
}

#pragma mark - Gesture handling

- (void)resize:(UIPanGestureRecognizer *)gestureRecognizer {

  [self.view bringSubviewToFront:[gestureRecognizer view]];
  CGPoint locationInView = [gestureRecognizer locationInView:self.view];

  CGRect bounds = self.view.bounds;

  if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {

    restX = CGRectGetWidth(bounds) - locationInView.x;
    restY = CGRectGetHeight(bounds) - locationInView.y;
  }

  CGFloat dx = locationInView.x - CGRectGetMidX(bounds);
  CGFloat dy = locationInView.y - CGRectGetMidY(bounds);

  CGFloat newWidth = MAX(100, (dx + restX) * 2);
  CGFloat newHeight = MAX(100, (dy + restY) * 2);

  self.view.bounds = CGRectMake(0, 0, newWidth, newHeight);
  if ([gestureRecognizer state] == UIGestureRecognizerStateEnded ||
          [gestureRecognizer state] == UIGestureRecognizerStateCancelled) {
    [self.shapeView setNeedsLayout];
    [self.shapeView setNeedsDisplay];
  }
}

- (void)move:(UIPanGestureRecognizer *)gestureRecognizer {

  [self.view bringSubviewToFront:[gestureRecognizer view]];
  CGPoint translatedPoint = [gestureRecognizer translationInView:self.view.superview];

  if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
    firstX = self.view.center.x;
    firstY = self.view.center.y;
  }

  translatedPoint = CGPointMake(firstX + translatedPoint.x, firstY + translatedPoint.y);
  [[gestureRecognizer view] setCenter:translatedPoint];
}

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
  if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    UIView *piece = self.view;
    CGPoint locationInView = [gestureRecognizer locationInView:piece];
    CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];

    piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
    piece.center = locationInSuperview;
  }
}

- (void)rotate:(UIRotationGestureRecognizer *)gestureRecognizer {
  [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];

  if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {

    self.view.transform = CGAffineTransformRotate(self.view.transform, [gestureRecognizer rotation]);
    [gestureRecognizer setRotation:0];
  }
  if ([gestureRecognizer state] == UIGestureRecognizerStateEnded ||
          [gestureRecognizer state] == UIGestureRecognizerStateCancelled) {
    [self.shapeView setNeedsLayout];
    [self.shapeView setNeedsDisplay];
  }
}

- (void)scale:(UIPinchGestureRecognizer *)gestureRecognizer {
  [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];

  if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {

    CGRect bounds = self.view.bounds;
    CGFloat newWidth = MAX(100, CGRectGetWidth(bounds) * gestureRecognizer.scale);
    CGFloat newHeight = MAX(100, CGRectGetHeight(bounds) * gestureRecognizer.scale);

    self.view.bounds = CGRectMake(0, 0, newWidth, newHeight);

    [gestureRecognizer setScale:1];
  }
  if ([gestureRecognizer state] == UIGestureRecognizerStateEnded ||
          [gestureRecognizer state] == UIGestureRecognizerStateCancelled) {
    [self.shapeView setNeedsLayout];
    [self.shapeView setNeedsDisplay];
  }
}

- (void)dummyTapped:(UITapGestureRecognizer *)gestureRecognizer {
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
  return ![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
}


- (IBAction)closeView:(id)sender {
  [self.view removeFromSuperview];
  [self.delegate controllerWillClose:self];
}

- (NSArray *)generatePointsList {
  return [NSArray array];
}

- (IBAction)generatePoints:(id)sender {

  NSArray *points = [self generatePointsList];
  BOOL clearList = [[self.wpData objectForKey:WPclearWpList] boolValue];
  [self.delegate controller:self generatedPoints:points clearList:clearList];
}

- (IBAction)showConfig:(id)sender {
  
  WPGenConfigViewController *controller = [[WPGenConfigViewController alloc] initWithFormDataSource:self.dataSource];
  
  if(IB_IS_IPAD()){
    
    if (self.popOverController) {
      [self.popOverController dismissPopoverAnimated:YES];
      self.popOverController = nil;
      return;
    }
    
    self.popOverController = [[UIPopoverController alloc] initWithContentViewController:controller];
    self.popOverController.delegate = self;
    self.popOverController.popoverContentSize = CGSizeMake(320, 500);
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
      [self.popOverController presentPopoverFromBarButtonItem:sender
                                     permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
      
    }
    else if ([sender isKindOfClass:[UIView class]]) {
      [self.popOverController presentPopoverFromRect:((UIView *) sender).frame inView:(UIView *) sender
                            permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
      [self.popOverController presentPopoverFromRect:self.shapeView.frame inView:self.shapeView
                            permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
  }
  else {
    UIViewController* c=self.parentController;
    [c.navigationController pushViewController:controller animated:YES];
  }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
  self.popOverController = nil;
}

@end
