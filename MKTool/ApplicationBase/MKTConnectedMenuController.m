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


#import "MKTConnectedMenuController.h"
#import "MKTTableSection.h"
#import "MKConnectionController.h"
#import "MKTConnection.h"

#import "MKTCommonColors.h"

#import "MKDataConstants.h"
#import "IKDeviceVersion.h"

#import "SettingsSelectionViewController.h"

#import "InnerBand.h"

#import "DDLog.h"
#import "MBProgressHUD.h"

#import "CustomBadge.h"

#import "OsdTabBarController.h"

typedef enum {
  MKConnectionStateDisconnected,
  MKConnectionStateConnecting,
  MKConnectionStateConnected
} MKConnectionState;

///////////////////////////////////////////////////////////////////////////////
#pragma mark - DDRegisteredDynamicLogging
static int ddLogLevel = LOG_LEVEL_WARN;

@interface MKTConnectedMenuController (DDRegisteredDynamicLogging) <DDRegisteredDynamicLogging>
@end

@implementation MKTConnectedMenuController (DDRegisteredDynamicLogging)
+ (int)ddLogLevel {
  return ddLogLevel;
}

+ (void)ddSetLogLevel:(int)logLevel {
  ddLogLevel = logLevel;
}
@end
///////////////////////////////////////////////////////////////////////////////


@interface MKTConnectedMenuController () {

  NSMutableArray *_sections;
  NSMutableArray *_sectionsConnected;
  MKTConnection *_conneciton;
  MKConnectionState _connectionState;

}

- (void)connectionRequestDidFail:(NSNotification *)aNotification;
- (void)connectionRequestDidSucceed:(NSNotification *)aNotification;
- (void)disconnected:(NSNotification *)aNotification;

@end

@implementation MKTConnectedMenuController

- (id)initWIthConnection:(MKTConnection *)connection {
  self = [super initWithStyle:UITableViewStyleGrouped];
  if (self) {
    _conneciton = connection;
    _connectionState = MKConnectionStateDisconnected;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.navigationItem.title = _conneciton.name;

  UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Disconnect", @"Disonnect button") style:UIBarButtonItemStyleBordered target:self
                                                          action:@selector(disconnect)];

  self.navigationItem.leftBarButtonItem = item;


  _sections = [NSMutableArray arrayWithCapacity:1];
  [_sections addObject:[self createLoadingSection]];

  _sectionsConnected = [NSMutableArray arrayWithCapacity:2];
  [_sectionsConnected addObject:[self createFunctionsSection]];
  [_sectionsConnected addObject:[self createDevicesSection]];

}

- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self
         selector:@selector(connectionRequestDidSucceed:)
             name:MKConnectedNotification
           object:nil];

  [nc addObserver:self
         selector:@selector(disconnected:)
             name:MKDisconnectedNotification
           object:nil];

  [nc addObserver:self
         selector:@selector(connectionRequestDidFail:)
             name:MKDisconnectErrorNotification
           object:nil];

  [nc addObserver:self
         selector:@selector(versionResponse:)
             name:MKFoundDeviceNotification
           object:nil];


}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  if (![[MKConnectionController sharedMKConnectionController] isRunning]) {

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.labelText = NSLocalizedString(@"Connecting…", @"Connected Menu Loading");

    self.tableView.userInteractionEnabled = NO;

    [[MKConnectionController sharedMKConnectionController] start:_conneciton];
  }
  else {
    [[MKConnectionController sharedMKConnectionController] activateNaviCtrl];
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  [MBProgressHUD hideHUDForView:self.view.window animated:YES];

  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

#pragma mark - Actions

- (void)disconnect {
  [[MKConnectionController sharedMKConnectionController] stop];
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Sections creation

- (MKTTableSection *)createLoadingSection {

  MKTTableSection *section = [[MKTTableSection alloc] initWithExpandabel:NO];

  MKTTableItem *item = [[MKTTableItem alloc] initWithTitle:NSLocalizedString(@"Connecting…", @"Connected Menu Loading")];

  UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  spinner.frame = CGRectMake(0, 0, 40, 40);
  [spinner startAnimating];
  item.accessoryView = spinner;

  [section.items addObject:item];

  return section;
}

//---------------------------------------------------------------------------------------------

- (MKTTableSection *)createFunctionsSection {

  MKTTableSection *section = [[MKTTableSection alloc] initWithExpandabel:NO];
  MKTTableItem *item;

  item = [[MKTTableItem alloc] initWithTitle:NSLocalizedString(@"OSD", @"Connected Menu OSD") andExecutionBlock:^{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    OsdTabBarController *tbc = [[OsdTabBarController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:tbc];
    
    nc.navigationBar.barStyle = UIBarStyleDefault;
    nc.navigationBar.translucent = YES;
    
    if (IS_IPAD()) 
      [self.splitViewController presentModalViewController:nc animated:YES];
    else
      [self presentModalViewController:nc animated:YES];
    
  }];
  [section.items addObject:item];

  item = [[MKTTableItem alloc] initWithTitle:NSLocalizedString(@"Settings", @"Connected Menu Settings") andExecutionBlock:^{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];

    SettingsSelectionViewController *controller = [[SettingsSelectionViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
  }];
  [section.items addObject:item];

  return section;
}

//---------------------------------------------------------------------------------------------
#pragma Device information

- (void)updateItem:(MKTTableItem *)item forAddress:(IKMkAddress)theAddress {

  CustomBadge *badge = [CustomBadge customBadgeWithString:@"UNK"];
  badge.badgeInsetColor = [MKTCommonColors functionOffColor];
  item.accessoryView = badge;
  item.selectionStyle = UITableViewCellSelectionStyleNone;
  if ([[MKConnectionController sharedMKConnectionController] isRunning]) {
    IKDeviceVersion *v = [[MKConnectionController sharedMKConnectionController] versionForAddress:theAddress];
    if (v) {
      item.title = v.versionString;
      badge.badgeText = v.hasError ? @"ERR" : @"OK";
      badge.badgeInsetColor = v.hasError ? [MKTCommonColors errorColor] : [MKTCommonColors okColor];
      item.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
  }
}

- (void)showDeviceStateForAddress:(IKMkAddress)theAddress {
  if ([[MKConnectionController sharedMKConnectionController] isRunning]) {
    IKDeviceVersion *v = [[MKConnectionController sharedMKConnectionController] versionForAddress:theAddress];
    if (v) {
      NSString *msg;

      if ([v hasError])
        msg = [[v errorDescriptions] componentsJoinedByString:@"\n"];
      else
        msg = NSLocalizedString(@"No Errors", @"");

      UIAlertView *alert = [[UIAlertView alloc]
              initWithTitle:v.versionString
                    message:msg
                   delegate:self
          cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
      [alert show];
    }
  }
}

- (MKTTableSection *)createDevicesSection {

  MKTTableSection *section = [[MKTTableSection alloc] initWithExpandabel:NO];
  MKTTableItem *item;

  item = [[MKTTableItem alloc] initWithTitle:NSLocalizedString(@"NaviCtrl", @"Connected Menu Devices") andExecutionBlock:^{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self showDeviceStateForAddress:kIKMkAddressNC];
  }];

  [self updateItem:item forAddress:kIKMkAddressNC];
  [section.items addObject:item];

  item = [[MKTTableItem alloc] initWithTitle:NSLocalizedString(@"FlightCtrl", @"Connected Menu Devices") andExecutionBlock:^{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self showDeviceStateForAddress:kIKMkAddressFC];
  }];
  [self updateItem:item forAddress:kIKMkAddressFC];
  [section.items addObject:item];

  item = [[MKTTableItem alloc] initWithTitle:NSLocalizedString(@"MK3Mag", @"Connected Menu Devices") andExecutionBlock:^{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self showDeviceStateForAddress:kIKMkAddressMK3MAg];
  }];
  [self updateItem:item forAddress:kIKMkAddressMK3MAg];
  [section.items addObject:item];

  return section;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return _connectionState == MKConnectionStateConnected ? _sectionsConnected.count : _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (_connectionState == MKConnectionStateConnected) {
    MKTTableSection *s = [_sectionsConnected objectAtIndex:section];
    return s.items.count;
  }

  MKTTableSection *s = [_sections objectAtIndex:section];
  return s.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
  }

  MKTTableSection *section = _connectionState == MKConnectionStateConnected ? [_sectionsConnected objectAtIndex:indexPath.section] : [_sections objectAtIndex:indexPath.section];
  MKTTableItem *item = [section.items objectAtIndex:indexPath.row];

  cell.textLabel.text = item.title;
  cell.detailTextLabel.text = item.detail;
  cell.accessoryView = item.accessoryView;
  cell.accessoryType = item.accessoryType;
  cell.selectionStyle = item.selectionStyle;

  return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  MKTTableSection *section = _connectionState == MKConnectionStateConnected ? [_sectionsConnected objectAtIndex:indexPath.section] : [_sections objectAtIndex:indexPath.section];
  MKTTableItem *item = [section.items objectAtIndex:indexPath.row];
  [item execute];
}

#pragma mark - Notifications

- (void)connectionRequestDidFail:(NSNotification *)aNotification {
  NSError *err = [[aNotification userInfo] objectForKey:@"error"];

  DDLogInfo(@"Connection failed. Error %@", err);

  [MBProgressHUD hideHUDForView:self.view.window animated:YES];

  _connectionState = MKConnectionStateDisconnected;
  [UIApplication sharedApplication].idleTimerDisabled = NO;
  [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)connectionRequestDidSucceed:(NSNotification *)aNotification {

  [[MKConnectionController sharedMKConnectionController] activateNaviCtrl];

  self.tableView.userInteractionEnabled = YES;
  _connectionState = MKConnectionStateConnected;

  [_sectionsConnected replaceObjectAtIndex:1 withObject:[self createDevicesSection]];

  [self.tableView reloadData];

  [UIApplication sharedApplication].idleTimerDisabled = NO;

  [MBProgressHUD hideHUDForView:self.view.window animated:YES];
}

- (void)disconnected:(NSNotification *)aNotification {
  [MBProgressHUD hideHUDForView:self.view.window animated:YES];

  _connectionState = MKConnectionStateDisconnected;
  [UIApplication sharedApplication].idleTimerDisabled = NO;
  [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)versionResponse:(NSNotification *)aNotification; {
  IKDeviceVersion *version = [[aNotification userInfo] objectForKey:kIKDataKeyVersion];
  [MBProgressHUD HUDForView:self.view.window].labelText = [NSString stringWithFormat:NSLocalizedString(@"Found %@", @"HUD device"), version.deviceName];
}

@end
