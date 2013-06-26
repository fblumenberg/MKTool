// ///////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2010-2012, Frank Blumenberg
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

#import "SettingsSelectionViewController.h"
#import "MKConnectionController.h"

#import "MKParamMainController.h"
#import "MKParamMainDataSource.h"

#import "EngineTestViewController.h"
#import "ChannelsViewController.h"

#import "NSData+MKCommandEncode.h"
#import "NSData+MKPayloadEncode.h"

#import "MKDataConstants.h"

#import "IKParamSet.h"

#import "UIViewController+MGSplitViewController.h"

#import "InnerBand.h"

#import "MixerViewController.h"
#import "MBProgressHUD.h"


static NSUInteger kNumberOfSettings = 5;

@interface SettingsSelectionViewController (Private)

@end

// ///////////////////////////////////////////////////////////////////////////////

@implementation SettingsSelectionViewController

@synthesize settings = _settings;

// ///////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark View lifecycle


- (id)init {

  if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
    self.title = NSLocalizedString(@"Settings", @"Settings controller title");
    self.hidesBottomBarWhenPushed = NO;
  }

  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self
         selector:@selector(readSettingNotification:)
             name:MKReadSettingNotification
           object:nil];

  [nc addObserver:self
         selector:@selector(changeSettingNotification:)
             name:MKChangeSettingNotification
           object:nil];


  NSMutableArray *settings = [[NSMutableArray alloc] init];
  for (unsigned i = 0; i < kNumberOfSettings; i++) {
    [settings addObject:[NSNull null]];
  }
  self.settings = settings;
  
  activeSetting = 0xFF;

}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];

  // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc removeObserver:self];

  self.settings = nil;
}

// ////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[MKConnectionController sharedMKConnectionController] activateFlightCtrl];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self.navigationController setToolbarHidden:YES animated:YES];
  [self reloadAllSettings];
}

- (void)viewWillDisappear:(BOOL)animated {

  if (self.navigationController.topViewController != self) {
    if (IS_IPAD())
      [self.detailViewController popToRootViewControllerAnimated:YES];
  }

  [super viewWillDisappear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}
// ////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -

- (IBAction)reloadAllSettings {
  activeSetting = 0xFF;
  [[MKConnectionController sharedMKConnectionController] requestSettingForIndex:0xFF];
}

- (void)readSettingNotification:(NSNotification *)aNotification {

  [MBProgressHUD hideAllHUDsForView:self.view.superview animated:YES];

  IKParamSet *paramSet = [[aNotification userInfo] objectForKey:kIKDataKeyParamSet];
  NSUInteger index = [[paramSet Index] unsignedIntValue] - 1;

  if (![paramSet isValid]) {
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"Flight-Ctrl wrong Version", @"Setting read error") message:NSLocalizedString(@"Flight-Ctrl is NOT compatible to this App!\nPlease update to the lastest App AND firmware versions.", @"Setting read error msg") delegate:nil cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil];
    [alert show];
    [self.navigationController popViewControllerAnimated:YES];
    return;
  }

  [self.settings replaceObjectAtIndex:index withObject:paramSet];

  if (activeSetting == 0xFF) {
    activeSetting = index;
  }
  else {
    [self showControllerForSetting:paramSet];
  }

  [self.tableView reloadData];
}


//////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0)
    return [self.settings count];

  return 3;
}

//////////////////////////////////////////////////////////////////////////////////////////////

- (UITableViewCell *)cellForSetting:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"SettingsSelectionCell";

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
  }

  NSUInteger row = [indexPath row];
  IKParamSet *setting = [self.settings objectAtIndex:row];

  cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Setting #%d", @"Setting i"), row];
  if ((NSNull *) setting == [NSNull null]) {
  }
  else {
    cell.detailTextLabel.text = [setting Name];
  }
  cell.accessoryView = nil;
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;


  int currActiveSetting = self.tableView.editing ? newActiveSetting : activeSetting;

  if (row == currActiveSetting) {
    UIImage *image = [UIImage imageNamed:@"star.png"];
    cell.imageView.image = image;
  }
  else {
    cell.imageView.image = nil;
  }


  return cell;

}

//////////////////////////////////////////////////////////////////////////////////////////////

- (UITableViewCell *)cellForExtra:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"SettingsMixerCell";

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }

  switch (indexPath.row) {
    case 0:
      cell.textLabel.text = NSLocalizedString(@"Mixer", @"Mixer cell");
      break;
    case 1:
      cell.textLabel.text = NSLocalizedString(@"Engine test", @"Motor test cell");
      break;
    case 2:
      cell.textLabel.text = NSLocalizedString(@"Channels", @"Channels cell");
      break;
  }
  cell.accessoryView = nil;
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  cell.imageView.image = nil;


  return cell;

}

//////////////////////////////////////////////////////////////////////////////////////////////

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  if (indexPath.section == 0)
    return [self cellForSetting:tableView indexPath:indexPath];

  return [self cellForExtra:tableView indexPath:indexPath];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
  return UITableViewCellEditingStyleNone;
}

#pragma mark - Actions

- (void)changeSettingNotification:(NSNotification *)aNotification {

  NSDictionary *d = [aNotification userInfo];

  NSInteger index = [[d objectForKey:kMKDataKeyIndex] integerValue] - 1;

  activeSetting = index;

//  [self cancelEditActiveSetting:self];
}

#pragma mark - Table view delegate

- (void)showControllerForSetting:(IKParamSet*)setting {
    
    MKParamMainDataSource *settingDataSource = [[MKParamMainDataSource alloc] initWithModel:setting];
    MKParamMainController *settingView = [[MKParamMainController alloc] initWithNibName:nil bundle:nil formDataSource:settingDataSource];
    settingView.title = NSLocalizedString(@"MK Setting", @"Settingview title");
    
    [self.navigationController setToolbarHidden:NO animated:NO];
    
    [self.navigationController pushViewController:settingView animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  NSUInteger row = [indexPath row];
  
  if (indexPath.section == 0) {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    IKParamSet *setting = [self.settings objectAtIndex:row];
    if ((NSNull *) setting == [NSNull null]) {
      [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
      [[MKConnectionController sharedMKConnectionController] requestSettingForIndex:row + 1];
    }
    else{
      [self showControllerForSetting:setting];
    }
  }
  else {
    
    if (!IS_IPAD())
      [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *extraView = nil;
    
    switch (indexPath.row) {
      case 0:
        extraView = [[MixerViewController alloc] initWithStyle:UITableViewStyleGrouped];
        break;
      case 1:
        extraView = [[EngineTestViewController alloc] initWithStyle:UITableViewStyleGrouped];
        break;
      case 2:
        extraView = [[ChannelsViewController alloc] initWithStyle:UITableViewStylePlain];
        break;
    }
    
    if (IS_IPAD()) {
      BOOL animated = self.isRootForDetailViewController;
      extraView.navigationItem.hidesBackButton = YES;
      [self.detailViewController popToRootViewControllerAnimated:NO];
      [self.detailViewController pushViewController:extraView animated:animated];
    }
    else
      [self.navigationController pushViewController:extraView animated:YES];
    
    [self.navigationController setToolbarHidden:NO animated:NO];
    
  }
}


@end

