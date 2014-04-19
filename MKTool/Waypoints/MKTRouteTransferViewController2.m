/////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2014, Frank Blumenberg
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

#import "MKTRouteTransferViewController2.h"
#import "MKTRoute.h"
#import "MKTRouteTransferController.h"

#import "MBProgressHUD.h"

@interface MKTRouteTransferViewController2 ()

@property(assign) NSUInteger firstIndex;
@property(assign) NSUInteger lastIndex;
@property(assign) NSUInteger maxIndex;
@property(strong) NSString* routeName;

@property (weak, nonatomic) IBOutlet UIStepper *stepperFirst;
@property (weak, nonatomic) IBOutlet UIStepper *stepperLast;
@property (weak, nonatomic) IBOutlet UITextField *textFirst;
@property (weak, nonatomic) IBOutlet UITextField *textLast;
@property (weak, nonatomic) IBOutlet UILabel *labelName;

@end

@interface MKTRouteTransferViewController2 () <MKTRouteTransferControllerDelegate,UITextFieldDelegate>

- (IBAction)dismiss:(id)sender;
- (IBAction)valueChanged:(id)sender;
- (IBAction)textChanged:(id)sender;

- (void)doUpload:(id)sender from:(NSUInteger)firstIndex to:(NSUInteger)lastIndex;

@property(strong) MKTRouteTransferController *transferController;
@property(strong) MKTRoute *route;

@end

@implementation MKTRouteTransferViewController2

- (id)initWithRoute:(MKTRoute *)route{
  
  self = [super initWithNibName:@"MKTRouteTransferViewController2" bundle:nil];;
  if (self) {
    self.transferController = [[MKTRouteTransferController alloc] initWithRoute:route delegate:self];
    
    self.routeName = route.name;
    self.firstIndex=1;
    self.lastIndex=[route count];
    self.maxIndex=self.lastIndex;
  }
  return self;
}


- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = NSLocalizedString(@"Route upload", @"Route upload view");
  
  UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(dismiss:)];
  [self.navigationItem setRightBarButtonItem:cancelButton animated:NO];

  self.labelName.text = self.routeName;
  
  self.stepperFirst.maximumValue = self.maxIndex;
  self.stepperFirst.minimumValue = 1;
  
  self.stepperLast.maximumValue = self.maxIndex;
  self.stepperLast.minimumValue = 1;
  self.stepperLast.value = self.maxIndex;
  
  self.textFirst.text = [NSString stringWithFormat:@"%d",(int)self.stepperFirst.value];
  self.textLast.text = [NSString stringWithFormat:@"%d",(int)self.stepperLast.value];
  
}

- (IBAction)valueChanged:(id)sender {
  self.textFirst.text = [NSString stringWithFormat:@"%d",(int)self.stepperFirst.value];
  self.textLast.text = [NSString stringWithFormat:@"%d",(int)self.stepperLast.value];
}

- (IBAction)textChanged:(id)sender{
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
  
  self.stepperFirst.value = [self.textFirst.text intValue];
  self.stepperLast.value = [self.textLast.text intValue];
  
  self.textFirst.text = [NSString stringWithFormat:@"%d",(int)self.stepperFirst.value];
  self.textLast.text = [NSString stringWithFormat:@"%d",(int)self.stepperLast.value];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  
  // allow backspace
  if (!string.length) {
    return YES;
  }
  
  // remove invalid characters from input, if keyboard is numberpad
  if (textField.keyboardType == UIKeyboardTypeNumberPad)
  {
    if ([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound)
    {
      return NO;
    }
  }
  
  return YES;
}

- (IBAction)dismiss:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)uploadSelected:(id)sender {
  [self doUpload:nil from:(int)self.stepperFirst.value to:(int)self.stepperLast.value];
}

- (IBAction)uploadAll:(id)sender {
  [self doUpload:nil from:1 to:self.maxIndex];
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
