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

#import "MKTRouteSyncViewController.h"
#import <IBAForms/IBAForms.h>

#import "SettingsButtonStyle.h"
#import "MKTRouteDropboxController.h"
#import "MBProgressHUD.h"

@interface MKTRouteSyncViewDataSource : IBAFormDataSource

@property(weak) MKTRouteSyncViewController* viewController;

@end


@interface MKTRouteSyncViewController () <MKTRouteDropboxControllerDelegate>

- (IBAction)dismiss:(id)sender;

- (void)doRestore:(id)sender;
- (void)doBackup:(id)sender;
- (void)doSynchronize:(id)sender;

@end

@implementation MKTRouteSyncViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  MKTRouteSyncViewDataSource* dataSource = [[MKTRouteSyncViewDataSource alloc] initWithModel:[NSDictionary dictionary]];
  
  dataSource.viewController = self;
  
  self = [super initWithNibName:nil bundle:nil formDataSource:dataSource];
  if (self) {

  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel toolbar button") 
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self action:@selector(dismiss:)];
  
  [self.navigationItem setRightBarButtonItem:cancelButton animated:NO];

  [MKTRouteDropboxController sharedController].delegate = self;
}

- (void)viewDidUnload {
  [super viewDidUnload];
  [MKTRouteDropboxController sharedController].delegate = nil;
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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

- (IBAction)dismiss:(id)sender{
  [self dismissModalViewControllerAnimated:YES];
}

/////////////////////////////////////////////////////////////////////////////////////////


- (void)doRestore:(id)sender {
  MBProgressHUD* hud=[MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
  hud.labelText=NSLocalizedString(@"Syncing", @"DB Sync routes HUD");
  hud.progress = 0.0;
  hud.mode = MBProgressHUDModeDeterminate;
  [[MKTRouteDropboxController sharedController] syncronizeAllRoutesWithOption:MKTRouteDropboxSyncOverrideLocal fromController:self];
}

- (void)doBackup:(id)sender {
  MBProgressHUD* hud=[MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
  hud.labelText=NSLocalizedString(@"Syncing", @"DB Sync routes HUD");
  hud.progress = 0.0;
  hud.mode = MBProgressHUDModeDeterminate;
  [[MKTRouteDropboxController sharedController] syncronizeAllRoutesWithOption:MKTRouteDropboxSyncOverrideRemote fromController:self];
}

- (void)doSynchronize:(id)sender {
  MBProgressHUD* hud=[MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
  hud.labelText=NSLocalizedString(@"Syncing", @"DB Sync routes HUD");
  hud.progress = 0.0;
  hud.mode = MBProgressHUDModeDeterminate;
  [[MKTRouteDropboxController sharedController] syncronizeAllRoutesWithOption:MKTRouteDropboxSyncOverrideOlder fromController:self];
}

- (void)dropboxReady:(MKTRouteDropboxController*)controller{
}

- (void)controller:(MKTRouteDropboxController*)crontroller dropboxInitFailedWithError:(NSError*)error{
  [MBProgressHUD hideHUDForView:self.view.window animated:YES];
  [MKTRouteDropboxController showError:error withTitle:NSLocalizedString(@"Getting the Route data folder failed", @"Getting Data Folder Error Title")];
  [self dismiss:self];
}


- (void)controllerSyncCompleted:(MKTRouteDropboxController*)crontroller{
  [MBProgressHUD hideHUDForView:self.view.window animated:YES];
  [self dismiss:self];
}

- (void)controller:(MKTRouteDropboxController*)crontroller syncFailedWithError:(NSError*)error{
  [MBProgressHUD hideHUDForView:self.view.window animated:YES];
  [MKTRouteDropboxController showError:error withTitle:NSLocalizedString(@"Synchronization failed", @"Routes Restore Error Title")];
  [self dismiss:self];
}

- (void)controller:(MKTRouteDropboxController *)crontroller syncProgress:(CGFloat)progress{
  MBProgressHUD* hud = [MBProgressHUD HUDForView:self.view.window];
  hud.progress = progress;
  if(progress==1.0)
    hud.mode = MBProgressHUDModeIndeterminate;
}

- (void)controllerPausedInit:(MKTRouteDropboxController*)crontroller{
  [MBProgressHUD hideHUDForView:self.view.window animated:YES];
}

- (void)controllerRestartedInit:(MKTRouteDropboxController*)crontroller{
  [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
}

@end

/////////////////////////////////////////////////////////////////////////////////////////

@implementation MKTRouteSyncViewDataSource

@synthesize viewController;

- (id)initWithModel:(id)aModel {
  if ((self = [super initWithModel:aModel])) {
    
    IBAFormSection *positionSection;
    
    positionSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
    positionSection.formFieldStyle = [[SettingsButtonStyleCenter alloc] init];
    positionSection.footerTitle = NSLocalizedString(@"Stores all local routes in the Dropbox.", @"Backup Button label");
    [positionSection addFormField:[[IBAButtonFormField alloc] initWithTitle:NSLocalizedString(@"Backup", @"Backup Button") 
                                                                       icon:nil 
                                                             executionBlock:^{
                                                               [self.viewController doBackup:self];
                                                             }]];
    //------------------------------------------------------------------------------------------------------------------------
    positionSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
    positionSection.formFieldStyle = [[SettingsButtonStyleCenter alloc] init];
    positionSection.footerTitle = NSLocalizedString(@"Loads all routes from the Dropbox and stores them locally, deleting existing.", @"Restore Button label");
    [positionSection addFormField:[[IBAButtonFormField alloc] initWithTitle:NSLocalizedString(@"Restore", @"Restore Button") 
                                                                       icon:nil 
                                                             executionBlock:^{
                                                               [self.viewController doRestore:self];
                                                             }]];
    //------------------------------------------------------------------------------------------------------------------------
    positionSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
    positionSection.formFieldStyle = [[SettingsButtonStyleCenter alloc] init];
    positionSection.footerTitle = NSLocalizedString(@"Synchronizes the local Routes with the remote stores.", @"Synchronize Button label");
    [positionSection addFormField:[[IBAButtonFormField alloc] initWithTitle:NSLocalizedString(@"Synchronize", @"Synchronize Button")
                                                                       icon:nil 
                                                             executionBlock:^{
                                                               [self.viewController doSynchronize:self];
                                                             }]];
    //------------------------------------------------------------------------------------------------------------------------
  }
  return self;
}


@end

