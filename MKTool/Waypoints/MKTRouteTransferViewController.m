/////////////////////////////////////////////////////////////////////////////////
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
/////////////////////////////////////////////////////////////////////////////////

#import "MKTRouteTransferViewController.h"
#import <IBAForms/IBAForms.h>

#import "SettingsButtonStyle.h"
#import "MKTRouteTransferController.h"
#import "MBProgressHUD.h"

@interface MKTRouteTransferViewDataSource : IBAFormDataSource

@property(weak) MKTRouteTransferViewController *viewController;

@end


@interface MKTRouteTransferViewController () <MKTRouteTransferControllerDelegate>

- (IBAction)dismiss:(id)sender;

- (void)doUpload:(id)sender;

@property(strong) MKTRouteTransferController *transferController;

@end

@implementation MKTRouteTransferViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  MKTRouteTransferViewDataSource *dataSource = [[MKTRouteTransferViewDataSource alloc] initWithModel:[NSDictionary dictionary]];

  dataSource.viewController = self;

  self = [super initWithNibName:nil bundle:nil formDataSource:dataSource];
  if (self) {

  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel toolbar button") style:UIBarButtonItemStyleBordered
                                                                  target:self action:@selector(dismiss:)];

  [self.navigationItem setRightBarButtonItem:cancelButton animated:NO];

  self.transferController = [[MKTRouteTransferController alloc] initWithDelegate:self];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

#pragma mark -

- (void)loadView {
  [super loadView];

  UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

  UITableView *formTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStyleGrouped];
  [formTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
  [self setTableView:formTableView];

  [view addSubview:formTableView];
  [self setView:view];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (IBAction)dismiss:(id)sender {
  [self dismissModalViewControllerAnimated:YES];
}

/////////////////////////////////////////////////////////////////////////////////////////


- (void)doUpload:(id)sender {
  MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
  hud.labelText = NSLocalizedString(@"Uploading", @"Upload routes HUD");
  hud.progress = 0.0;
  hud.mode = MBProgressHUDModeDeterminate;
}

- (void)routeControllerStartUpload:(MKTRouteTransferController *)controller forIndex:(NSInteger)index of:(NSInteger)count {

  MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view.window];

  hud.progress = (CGFloat) index / (CGFloat) count;
  if (hud.progress == 1.0)
    hud.mode = MBProgressHUDModeIndeterminate;

}

- (void)routeControllerFinishedUpload:(MKTRouteTransferController *)controller forIndex:(NSInteger)index of:(NSInteger)count {

  MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view.window];

  hud.progress = (CGFloat) index / (CGFloat) count;
  if (hud.progress == 1.0)
    hud.mode = MBProgressHUDModeIndeterminate;

}

- (void)routeControllerFinishedUpload:(MKTRouteTransferController *)controller {
  [MBProgressHUD hideHUDForView:self.view.window animated:YES];

}

- (void)routeControllerFailedUpload:(MKTRouteTransferController *)controller WithError:(NSError *)error {
  [MBProgressHUD hideHUDForView:self.view.window animated:YES];

}


@end

/////////////////////////////////////////////////////////////////////////////////////////

@implementation MKTRouteTransferViewDataSource

@synthesize viewController;

- (id)initWithModel:(id)aModel {
  if ((self = [super initWithModel:aModel])) {

    IBAFormSection *positionSection;

    //------------------------------------------------------------------------------------------------------------------------

    positionSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
    positionSection.formFieldStyle = [[SettingsButtonStyleCenter alloc] init];
//    positionSection.footerTitle = NSLocalizedString(@"Stores all local routes in the Dropbox.", @"Backup Button label");
    [positionSection addFormField:[[IBAButtonFormField alloc] initWithTitle:NSLocalizedString(@"Upload", @"Upload Button") icon:nil executionBlock:^{
      [self.viewController doUpload:self];
    }]];
  }
  return self;
}


@end

