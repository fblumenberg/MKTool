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

@end

@implementation MKTDetailViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"white_texture.png"]];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  
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
    self.title = nil;
  }
  return self;
}

@end
