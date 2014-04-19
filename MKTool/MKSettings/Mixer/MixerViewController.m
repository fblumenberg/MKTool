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

#import "MixerViewController.h"
#import "MixerTableViewCell.h"

#import "MKConnectionController.h"
#import "NSData+MKCommandEncode.h"

#import "MBProgressHUD.h"

#import <IBAForms/IBAForms.h>
#import "SettingsFieldStyle.h"

#import "IKMixerTable.h"
#import "MKDataConstants.h"

@interface MixerTextFormFieldCell : IBATextFormFieldCell
@end

@interface MixerViewController () {
  NSMutableArray *cells;

  MixerTextFormFieldCell *textCell;
  IKMixerTable *mixer;
}

@end

@implementation MixerViewController

@synthesize loadCell;

#pragma mark - Initialization


- (id)initWithStyle:(UITableViewStyle)style {
  if ((self = [super initWithStyle:style])) {
  }
  return self;
}



#pragma mark - mark View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];


  [self createTextCell];
  [self createMixerCells];


  UIBarButtonItem *renameButton;
  renameButton = [[UIBarButtonItem alloc]
          initWithTitle:NSLocalizedString(@"Save", @"Save toolbar item") style:UIBarButtonItemStyleDone
                 target:self
                 action:@selector(saveMixer:)];


  UIBarButtonItem *spacer;
  spacer = [[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                               target:nil action:nil];

  UIBarButtonItem *reloadButton;
  reloadButton = [[UIBarButtonItem alloc]
          initWithTitle:NSLocalizedString(@"Reload", @"Reload toolbar item") style:UIBarButtonItemStyleBordered
                 target:self
                 action:@selector(reloadMixer:)];

  [self setToolbarItems:[NSArray arrayWithObjects:renameButton, spacer, reloadButton, nil]];

}


- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [self.navigationController setToolbarHidden:NO animated:NO];

  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self
         selector:@selector(readMixerNotification:)
             name:MKReadMixerNotification
           object:nil];

  [nc addObserver:self
         selector:@selector(writeMixerNotification:)
             name:MKWriteMixerNotification
           object:nil];

  [self reloadMixer:self];
}

/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
}
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */
/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

#pragma mark - 

- (void)createMixerCells {

  cells = [NSMutableArray arrayWithCapacity:12];

  for (NSUInteger i = 0; i < 12; i++) {
    [[NSBundle mainBundle] loadNibNamed:@"MixerTableViewCell" owner:self options:nil];
    MixerTableViewCell *cell = loadCell;
    self.loadCell = nil;

    [cells addObject:cell];
  }
}

- (void)createTextCell {
  textCell = [[MixerTextFormFieldCell alloc] initWithFormFieldStyle:[SettingsFieldStyleText new] reuseIdentifier:@"MixerTextFormFieldCell"];

  textCell.textField.textAlignment = NSTextAlignmentLeft;
  textCell.textField.returnKeyType = UIReturnKeyDone;
  textCell.accessoryType = UITableViewCellAccessoryNone;
  textCell.label.text = NSLocalizedString(@"Name", @"Mixer name label");

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Return the number of sections.
  return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

  if (section == 0)
    return 1;

  return cells.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  if (indexPath.section == 0)
    return textCell;

  MixerTableViewCell *cell = [cells objectAtIndex:indexPath.row];
  cell.cellLabel.text = [NSString stringWithFormat:@"Motor %d", [indexPath row] + 1];
  return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  return nil;
}

#pragma mark - Save Mixer

- (void)saveMixer:(id)sender {

  mixer.name = textCell.textField.text;

  [cells enumerateObjectsUsingBlock:^(MixerTableViewCell *cell, NSUInteger i, BOOL *stop) {
    IKMixerMotorData *data = [IKMixerMotorData new];

    data.gas = [cell.cellTextGas.text integerValue];
    data.nick = [cell.cellTextNick.text integerValue];
    data.roll = [cell.cellTextRoll.text integerValue];
    data.yaw = [cell.cellTextYaw.text integerValue];

    [mixer setData:data forMotor:i];
  }];

  NSData *payload = [mixer data];
  NSData *data = [payload dataWithCommand:MKCommandMixerWriteRequest
                               forAddress:kIKMkAddressFC];
  [[MKConnectionController sharedMKConnectionController] sendRequest:data];
}

- (void)writeMixerNotification:(NSNotification *)aNotification {

  MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];

  hud.customView = [[UIImageView alloc] initWithImage:
          [UIImage imageNamed:@"icon-check.png"]];
  hud.mode = MBProgressHUDModeCustomView;
  hud.labelText = NSLocalizedString(@"Mixer saved", @"Mixer saved success");

  [hud hide:YES afterDelay:0.7];
}

#pragma mark - Reload Mixer

- (void)reloadMixer:(id)sender {

  MKConnectionController *cCtrl = [MKConnectionController sharedMKConnectionController];

  NSData *data = [NSData dataWithCommand:MKCommandMixerReadRequest
                              forAddress:kIKMkAddressFC
                        payloadWithBytes:NULL length:0];

  [cCtrl sendRequest:data];
}

- (void)readMixerNotification:(NSNotification *)aNotification {

  mixer = [[aNotification userInfo] objectForKey:kIKMixerTable];

  textCell.textField.text = mixer.name;

  [cells enumerateObjectsUsingBlock:^(MixerTableViewCell *cell, NSUInteger i, BOOL *stop) {
    IKMixerMotorData *data = [mixer dataForMotor:i];
    cell.cellTextGas.text = [NSString stringWithFormat:@"%d", data.gas];
    cell.cellTextNick.text = [NSString stringWithFormat:@"%d", data.nick];
    cell.cellTextRoll.text = [NSString stringWithFormat:@"%d", data.roll];
    cell.cellTextYaw.text = [NSString stringWithFormat:@"%d", data.yaw];
  }];

  [self.tableView reloadData];
}

@end

///////////////////////////////////////////////////////////////////////////////////
#pragma mark - 
///////////////////////////////////////////////////////////////////////////////////

@implementation MixerTextFormFieldCell

- (void)didMoveToWindow {

}
@end
