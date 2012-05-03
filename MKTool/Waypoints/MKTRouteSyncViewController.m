//
//  MKTRouteSyncViewController.m
//  MKTool
//
//  Created by Frank Blumenberg on 03.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MKTRouteSyncViewController.h"
#import "YKUIButtonStyles.h"


@interface IBButton (Setting)
-(void)glossButtonWithTitle:(NSString*)title color:(UIColor*)color;
-(void)softButtonWithTitle:(NSString*)title color:(UIColor*)color;
-(void)flatButtonWithTitle:(NSString*)title color:(UIColor*)color;
@end

@interface MKTRouteSyncViewController ()

- (IBAction)dismiss:(id)sender;


@end

@implementation MKTRouteSyncViewController

@synthesize b1;

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
  
  [b1 softButtonWithTitle:@"TEST" color:[UIColor redColor]];
    // Do any additional setup after loading the view from its nib.
  
  IBButton* b3 = [IBButton glossButtonWithTitle:@"Test 2" color:[UIColor blueColor]];
  
  [self.view addSubview:b3];
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

- (IBAction)dismiss:(id)sender{
  [self dismissModalViewControllerAnimated:YES];
}

@end


@implementation IBButton (Setting)
-(void)glossButtonWithTitle:(NSString*)title color:(UIColor*)color{
	[self setTitle:title forState:UIControlStateNormal];
	self.type = IBButtonTypeGlossy;
	self.color = color;
	self.shineColor = [color colorBrighterByPercent:65.0];
	self.cornerRadius = 10;
	self.borderSize = 1;
	self.borderColor = [color colorDarkerByPercent:15.0];
	self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
	self.titleLabel.shadowOffset = CGSizeMake (-1.0, -0.0);
}

-(void)softButtonWithTitle:(NSString*)title color:(UIColor*)color{
	[self setTitle:title forState:UIControlStateNormal];
	self.type = IBButtonTypeSoft;
	self.color = color;
	self.shineColor = [color colorBrighterByPercent:50.0];
	self.cornerRadius = 10;
	self.borderSize = 1;
	self.borderColor = [color colorDarkerByPercent:15.0];
	self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
	self.titleLabel.shadowOffset = CGSizeMake (-1.0, -0.0);
}

-(void)flatButtonWithTitle:(NSString*)title color:(UIColor*)color{
	[self setTitle:title forState:UIControlStateNormal];
	self.type = IBButtonTypeFlat;
	self.color = color;
	self.cornerRadius = 10;
	self.borderSize =	1;
	self.borderColor = [color colorDarkerByPercent:15.0];
	self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
	self.titleLabel.shadowOffset = CGSizeMake (-1.0, -0.0);
}
@end
