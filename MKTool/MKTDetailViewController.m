//
//  MKTDetailViewController.m
//  MKTool
//
//  Created by Frank Blumenberg on 19.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MKTDetailViewController.h"
#import "UIViewController+MGSplitViewController.h"

@interface MKTDetailViewController () <UINavigationControllerDelegate>
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation MKTDetailViewController

@synthesize detailItem = _detailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize masterPopoverController = _masterPopoverController;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
  if (_detailItem != newDetailItem) {
    _detailItem = newDetailItem;
    
    // Update the view.
    [self configureView];
  }
  
  if (self.masterPopoverController != nil) {
    [self.masterPopoverController dismissPopoverAnimated:YES];
  }        
}

- (void)configureView
{
  // Update the user interface for the detail item.
  
  if (self.detailItem) {
    self.detailDescriptionLabel.text = [self.detailItem description];
  }
  
  
}

- (void)testView
{
  MGSplitViewController* sc = [self splitViewController];
  
  [sc toggleMasterView:self];
  
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  [self configureView];
  
  UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithTitle:@"TEST" 
                                                                style:UIBarButtonItemStyleBordered 
                                                               target:self 
                                                               action:@selector(testView)];
  
  [self.navigationItem setRightBarButtonItem:rightItem animated:YES];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  self.detailDescriptionLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  } else {
    return YES;
  }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = NSLocalizedString(@"Detail", @"Detail");
  }
  return self;
}


- (UIColor *)randomColor {
  CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
  CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
  CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  
  return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

- (UIViewController*)randomViewController {
  UIViewController *viewController = [[UIViewController alloc] init];
  viewController.view.backgroundColor = [self randomColor];
  return viewController;
}

- (IBAction)showNext:(id)sender{
  UIViewController *randomViewController = [self randomViewController];
  self.navigationController.delegate = self;
  
  [[self splitViewController] toggleMasterView:self];
  [[self detailViewController] pushViewController:randomViewController animated:YES];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
//  [[self splitViewController] toggleMasterView:self];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
  barButtonItem.title = NSLocalizedString(@"Master", @"Master");
  [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
  self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
  // Called when the view is shown again in the split view, invalidating the button and popover controller.
  [self.navigationItem setLeftBarButtonItem:nil animated:YES];
  self.masterPopoverController = nil;
}

@end
