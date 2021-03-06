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

#import "MKTRouteContainerViewController.h"
#import "MKTRouteViewControllerDelegate.h"

#import "MKTRouteListViewController.h"
#import "MKTRouteMapViewController.h"

@interface MKTRouteContainerViewController ()<MKTRouteViewControllerDelegate>{
  UIViewController *_selectedViewController;
  MKTRoute* _route;
}

@property (nonatomic, strong) NSArray *subViewControllers;
@property(retain) UISegmentedControl *segment;
@property(nonatomic, strong) MKTRouteMapViewController* mapController;
@end

@implementation MKTRouteContainerViewController

@synthesize subViewControllers;
@synthesize segment;
@synthesize mapController;

- (id)initWithRoute:(MKTRoute *)route {
  
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
      _route = route;
    }
    return self;
}

- (void)loadView {
  
  MKTRouteListViewController *page1 = [[MKTRouteListViewController alloc] initWithRoute:_route delegate:self];
  
  MKTRouteMapViewController *page2 = [[MKTRouteMapViewController alloc] initWithRoute:_route delegate:self];

  self.mapController = page2;
  
  self.subViewControllers = [NSArray arrayWithObjects:page1,page2, nil];

  _selectedViewController = [subViewControllers objectAtIndex:0];
  
  NSArray *segmentItems = [NSArray arrayWithObjects:@"List", @"Map", nil];
  self.segment = [[UISegmentedControl alloc] initWithItems:segmentItems];
  self.segment.segmentedControlStyle = UISegmentedControlStyleBar;
  
  self.segment.tintColor = [UIColor darkGrayColor];
  [self.segment setImage:[UIImage imageNamed:@"list-mode.png"] forSegmentAtIndex:0];
  [self.segment setWidth:50.0 forSegmentAtIndex:0];
  [self.segment setWidth:50.0 forSegmentAtIndex:1];
  [self.segment setImage:[UIImage imageNamed:@"map-mode.png"] forSegmentAtIndex:1];
  
  
  [self.segment addTarget:self
                   action:@selector(changeView)
         forControlEvents:UIControlEventValueChanged];
  
  self.segment.selectedSegmentIndex = 0;
    
  UIBarButtonItem *segmentButton;
  segmentButton = [[UIBarButtonItem alloc]
                    initWithCustomView:self.segment];

  [self.navigationItem setRightBarButtonItem:segmentButton animated:NO];

  
	// set up the base view
	CGRect frame = [[UIScreen mainScreen] applicationFrame];
	UIView *view = [[UIView alloc] initWithFrame:frame];
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	view.backgroundColor = [UIColor blueColor];
	
	// from here on the container is automatically adjusting to the orientation
	self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  self.navigationController.toolbarHidden = NO;
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (_selectedViewController.parentViewController == self)
	{
		// nowthing to do
		return;
	}
	
	// adjust the frame to fit in the container view
	_selectedViewController.view.frame = self.view.bounds;
	
	// make sure that it resizes on rotation automatically
	_selectedViewController.view.autoresizingMask = self.view.autoresizingMask;
	
	// add as child VC
	[self addChildViewController:_selectedViewController];
	
	// add it to container view, calls willMoveToParentViewController for us
	[self.view addSubview:_selectedViewController.view];
	
	// notify it that move is done
	[_selectedViewController didMoveToParentViewController:self];
}

- (void)viewDidAppear:(BOOL)animated{
  [super viewDidAppear:animated];
  [self setToolbarItems:_selectedViewController.toolbarItems animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)transitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
{
	if (fromViewController == toViewController)
	{
		// cannot transition to same
		return;
	}
	
	// animation setup
	toViewController.view.frame = self.view.bounds;
	toViewController.view.autoresizingMask = self.view.autoresizingMask;
  
	// notify
	[fromViewController willMoveToParentViewController:nil];
	[self addChildViewController:toViewController];
	
	// transition
	[self transitionFromViewController:fromViewController
                    toViewController:toViewController
                            duration:0.2
                             options:UIViewAnimationOptionTransitionCrossDissolve
                          animations:^{
                          }
                          completion:^(BOOL finished) {
                            [toViewController didMoveToParentViewController:self];
                            [fromViewController removeFromParentViewController];
                            [self setToolbarItems:toViewController.toolbarItems animated:YES];
                          }];
}


- (void)changeView {
  UIViewController *newSelectedViewController = [self.subViewControllers objectAtIndex:self.segment.selectedSegmentIndex];
  [self transitionFromViewController:_selectedViewController toViewController:newSelectedViewController];
  _selectedViewController = newSelectedViewController;
}

- (void)controllerDidChangeToolbar:(UIViewController *)controller{
  if(controller == _selectedViewController)
    [self setToolbarItems:_selectedViewController.toolbarItems animated:YES];
}

- (CLLocationCoordinate2D) currentCoordinate{
  return self.mapController.mapView?self.mapController.mapView.centerCoordinate:[MKTRoute defaultCoordinate];
}


@end
