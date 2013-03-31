// ///////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2011, Frank Blumenberg
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

#import <IBAForms/IBAForms.h>
#import "IBAFormSection+Create.h"
#import "MKTConnectionViewDataSource.h"
#import "StringToNumberTransformer.h"
#import "MKTConnectionTypeTransformer.h"

#import "SettingsFieldStyle.h"
#import "SettingsButtonStyle.h"

#ifdef CYDIA
#import "BTDevice.h"
#import "BTDiscoveryViewController.h"

@interface MKTConnectionViewDataSource (BTDiscovery) <BTDiscoveryDelegate>

@end

#endif

@implementation MKTConnectionViewDataSource{
  IBAFormField* address;
  IBAFormField* infoWLAN;
  IBAFormField* connectionData;
  IBAFormField* discoveryButton;
}

- (id)initWithModel:(id)aModel {
  if ((self = [super initWithModel:aModel])) {

    [self updateHostSection];
  }
  return self;
}

- (void)updateHostSection {

  IBAFormSection *hostSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
  hostSection.formFieldStyle = [[SettingsFieldStyleText alloc] init];

  [hostSection.formFields removeAllObjects];

  //------------------------------------------------------------------------------------------------------------------------
  [hostSection addFormField:[[IBATextFormField alloc] initWithKeyPath:@"name" title:NSLocalizedString(@"Name", @"Host name")]];

  MKTConnectionTypeTransformer *hostTransformer = [MKTConnectionTypeTransformer instance];

  [hostSection addFormField:[[IBAPickListFormField alloc] initWithKeyPath:@"connectionClass"
                                                                    title:NSLocalizedString(@"Type", @"Host type") valueTransformer:hostTransformer
                                                            selectionMode:IBAPickListSelectionModeSingle
                                                                  options:hostTransformer.pickListOptions]];

  address=[[IBATextFormField alloc] initWithKeyPath:@"address" title:NSLocalizedString(@"Address", @"Host address")];
  [hostSection addFormField:address];
  
  infoWLAN = [[IBATitleFormField alloc] initWithTitle:NSLocalizedString(@"Hostname:Port", @"Host address")];
  [hostSection addFormField:infoWLAN];

  connectionData = [[IBATextFormField alloc] initWithKeyPath:@"connectionData" title:NSLocalizedString(@"Pin", @"Host pin")];
  [hostSection addFormField:connectionData];

  
#ifdef CYDIA
  IBAFormSection *buttonSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
  buttonSection.formFieldStyle = [[SettingsButtonStyle alloc] init];
  
  discoveryButton = [[IBAButtonFormField alloc] initWithTitle:NSLocalizedString(@"Search Bluetooth", @"BT search button") icon:nil executionBlock:^{
    [self showDiscoveryView];
  }];
  [buttonSection addFormField:discoveryButton];
  
#endif
  
  NSString *connectionClass = [self modelValueForKeyPath:@"connectionClass"];
  [self updateVisibility:connectionClass];
}

- (void)updateVisibility:(NSString*)connectionClass{
  
  if([connectionClass isEqualToString:@"MKSimConnection"]){
    [self setFormField:address hidden:YES];
    [self setFormField:connectionData hidden:YES];
    [self setFormField:infoWLAN hidden:YES];
    [self setFormField:discoveryButton hidden:YES];
  }
  else if ([connectionClass isEqualToString:@"MKBluetoothConnection"]){
    [self setFormField:address hidden:NO];
    [self setFormField:connectionData hidden:NO];
    [self setFormField:infoWLAN hidden:YES];
    [self setFormField:discoveryButton hidden:NO];
  }
  else if ([connectionClass isEqualToString:@"MKIpConnection"]){
    [self setFormField:address hidden:NO];
    [self setFormField:connectionData hidden:YES];
    [self setFormField:infoWLAN hidden:NO];
    [self setFormField:discoveryButton hidden:YES];
  }
  else{
    [self setFormField:address hidden:NO];
    [self setFormField:connectionData hidden:YES];
    [self setFormField:infoWLAN hidden:YES];
    [self setFormField:discoveryButton hidden:YES];
  }
}

- (void)setModelValue:(id)value forKeyPath:(NSString *)keyPath {
  [super setModelValue:value forKeyPath:keyPath];
  if([keyPath isEqualToString:@"connectionClass"]){
    [self updateVisibility:value];
  }
}

#ifdef CYDIA

- (void)showDiscoveryView {
  
  BTDiscoveryViewController *controller = [[BTDiscoveryViewController alloc] init];
  
  UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
  
  
  navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
  controller.delegate = self;
  [rootViewController presentModalViewController:navController animated:YES];
}


- (BOOL)discoveryView:(BTDiscoveryViewController *)discoveryView willSelectDeviceAtIndex:(int)deviceIndex {
  
  BTDevice *device = [discoveryView.bt deviceAtIndex:deviceIndex];
  
  [self.model setValue:[device nameOrAddress] forKey:@"name"];
  [self.model setValue:[device addressString] forKey:@"address"];
  
  [discoveryView.navigationController dismissModalViewControllerAnimated:YES];
  return YES;
}
#endif
@end
