//
//  MKTRouteSyncViewController.m
//  MKTool
//
//  Created by Frank Blumenberg on 03.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MKTRouteSyncViewController.h"

@interface MKTRouteSyncViewController ()

@end

@implementation MKTRouteSyncViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
