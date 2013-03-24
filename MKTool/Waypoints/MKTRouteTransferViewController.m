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
#import "MKTRoute.h"
#import <IBAForms/IBAForms.h>

#import "SettingsButtonStyle.h"
#import "SettingsFieldStyle.h"
#import "MKTRouteTransferController.h"
#import "MBProgressHUD.h"

NSString *const kMKTRouteTransferName = @"kMKTRouteTransferName";
NSString *const kMKTRouteTransferFirst = @"kMKTRouteTransferFirst";
NSString *const kMKTRouteTransferLast = @"kMKTRouteTransferLast";
NSString *const kMKTRouteTransferMax = @"kMKTRouteTransferMax";

@interface MKTRouteTransferViewDataSource : IBAFormDataSource

@property(weak) MKTRouteTransferViewController *viewController;

@property(assign) NSUInteger firstIndex;
@property(assign) NSUInteger lastIndex;
@property(assign) NSUInteger maxIndex;

@end


@interface MKTRouteTransferViewController () <MKTRouteTransferControllerDelegate>

- (IBAction)dismiss:(id)sender;

- (void)doUpload:(id)sender from:(NSUInteger)firstIndex to:(NSUInteger)lastIndex;

@property(strong) MKTRouteTransferController *transferController;
@property(strong) MKTRoute *route;

@end

@implementation MKTRouteTransferViewController

- (id)initWithRoute:(MKTRoute *)route{

  NSNumber* routeMax = @([route count]);
  NSMutableDictionary* model = [@{
                                kMKTRouteTransferName:route.name,
                                kMKTRouteTransferFirst:@1,
                                kMKTRouteTransferLast:routeMax,
                                kMKTRouteTransferMax:routeMax} mutableCopy];
  MKTRouteTransferViewDataSource *dataSource = [[MKTRouteTransferViewDataSource alloc] initWithModel:model];

  self = [super initWithNibName:nil bundle:nil formDataSource:dataSource];
  if (self) {
    dataSource.viewController = self;
    self.transferController = [[MKTRouteTransferController alloc] initWithRoute:route delegate:self];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = NSLocalizedString(@"Route upload", @"Route upload view");
  
  UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                              target:self
                                                                              action:@selector(dismiss:)];

  [self.navigationItem setRightBarButtonItem:cancelButton animated:NO];
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


- (void)doUpload:(id)sender from:(NSUInteger)firstIndex to:(NSUInteger)lastIndex {
  MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
  hud.labelText = NSLocalizedString(@"Uploading", @"Upload routes HUD");
  hud.progress = 0.0;
  hud.mode = MBProgressHUDModeDeterminate;
  
  [self.transferController uploadRouteToNaviCtrlFrom:firstIndex to:lastIndex];
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
  
  MBProgressHUD* hud = [MBProgressHUD HUDForView:self.view.window];
  hud.mode = MBProgressHUDModeText;
  hud.labelText = NSLocalizedString(@"Upload", @"WP Upload");
  hud.detailsLabelText = [[error userInfo] objectForKey:NSLocalizedDescriptionKey];
  [hud hide:YES afterDelay:2.0];
}


@end

/////////////////////////////////////////////////////////////////////////////////////////

@implementation MKTRouteTransferViewDataSource

@synthesize viewController;

- (id)initWithModel:(id)aModel {
  if ((self = [super initWithModel:aModel])) {

    IBAFormSection *positionSection;
    IBAStepperFormField *stepperField;

    positionSection = [self addSectionWithHeaderTitle:[aModel valueForKeyPath:kMKTRouteTransferName] footerTitle:nil];
    positionSection.formFieldStyle = [[SettingsFieldStyleStepper alloc] init];

    stepperField = [[IBAStepperFormField alloc] initWithKeyPath:(NSString*)kMKTRouteTransferFirst
                                                          title:NSLocalizedString(@"First point", @"WP Upload") valueTransformer:nil];
    
    stepperField.maximumValue = [self.model[kMKTRouteTransferMax] doubleValue];
    stepperField.minimumValue = 1;
    [positionSection addFormField:stepperField];

    stepperField = [[IBAStepperFormField alloc] initWithKeyPath:(NSString*)kMKTRouteTransferLast
                                                          title:NSLocalizedString(@"Last point", @"WP Upload") valueTransformer:nil];
    
    stepperField.maximumValue = [self.model[kMKTRouteTransferMax] doubleValue];
    stepperField.minimumValue = 1;
    [positionSection addFormField:stepperField];

    positionSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
    positionSection.formFieldStyle = [[SettingsButtonStyleCenter alloc] init];

    //    positionSection.footerTitle = NSLocalizedString(@"Stores all local routes in the Dropbox.", @"Backup Button label");
    [positionSection addFormField:[[IBAButtonFormField alloc] initWithTitle:NSLocalizedString(@"Upload selected", @"Upload Button") icon:nil executionBlock:^{
      [self.viewController doUpload:self from:[self.model[kMKTRouteTransferFirst] unsignedIntegerValue] to:[self.model[kMKTRouteTransferLast] unsignedIntegerValue]];
    }]];

    //------------------------------------------------------------------------------------------------------------------------

    positionSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
    positionSection.formFieldStyle = [[SettingsButtonStyleCenter alloc] init];
//    positionSection.footerTitle = NSLocalizedString(@"Stores all local routes in the Dropbox.", @"Backup Button label");
    [positionSection addFormField:[[IBAButtonFormField alloc] initWithTitle:NSLocalizedString(@"Upload all", @"Upload Button") icon:nil executionBlock:^{
      [self.viewController doUpload:self from:1 to:[self.model[kMKTRouteTransferMax] unsignedIntegerValue]];
    }]];
  }
  return self;
}


@end

