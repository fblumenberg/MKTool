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
#import <Crashlytics/Crashlytics.h>


#import "SettingsFieldStyle.h"
#import "SettingsButtonStyle.h"

#import "MKBLEDiscoveryViewController.h"

@interface MKTConnectionViewDataSource (BLE) <MKBLEDiscoveryDelegate>

@property(strong) NSString *ipAddress;
@property(assign) NSUInteger ipPort;

@end

#ifdef CYDIA
#import "BTDevice.h"
#import "BTDiscoveryViewController.h"

@interface MKTConnectionViewDataSource (BTDiscovery) <BTDiscoveryDelegate>

@end

#endif

@implementation MKTConnectionViewDataSource {
  IBAFormField *address;
  IBAFormField *ipAddressField;
  IBAFormField *ipPortField;
  IBAFormField *connectionData;
  IBAFormField *discoveryBleButton;
  IBAFormField *discoveryButton;
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

  address = [[IBATextFormField alloc] initWithKeyPath:@"address" title:NSLocalizedString(@"Address", @"Host address")];
  [hostSection addFormField:address];

  ipAddressField = [[IBATextFormField alloc] initWithKeyPath:@"ipAddress" title:NSLocalizedString(@"Address", @"Host address")];
  [hostSection addFormField:ipAddressField];

  ipPortField = [[IBATextFormField alloc] initWithKeyPath:@"ipPort" title:NSLocalizedString(@"Port", @"Host IP Port")];
  [hostSection addFormField:ipPortField];

  connectionData = [[IBATextFormField alloc] initWithKeyPath:@"connectionData" title:NSLocalizedString(@"Pin", @"Host pin")];
  [hostSection addFormField:connectionData];


  IBAFormSection *buttonSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
  buttonSection.formFieldStyle = [[SettingsButtonStyle alloc] init];

  discoveryBleButton = [[IBAButtonFormField alloc] initWithTitle:NSLocalizedString(@"Scan Bluetooth LE", @"BT search BLE button") icon:nil executionBlock:^{
    [self showDiscoveryBleView];
  }];
  [buttonSection addFormField:discoveryBleButton];


#ifdef CYDIA
  buttonSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
  buttonSection.formFieldStyle = [[SettingsButtonStyle alloc] init];
  
  discoveryButton = [[IBAButtonFormField alloc] initWithTitle:NSLocalizedString(@"Search Bluetooth", @"BT search button") icon:nil executionBlock:^{
    [self showDiscoveryView];
  }];
  [buttonSection addFormField:discoveryButton];
  
#endif

  NSString *connectionClass = [self modelValueForKeyPath:@"connectionClass"];
  [self updateVisibility:connectionClass];
}

- (void)updateVisibility:(NSString *)connectionClass {

  NSDictionary *data = @{
      @"MKSimConnection"       : @[],
      @"MKBleConnection"       : @[address, discoveryBleButton],
      @"MKIpConnection"        : @[ipAddressField, ipPortField],
#ifdef CYDIA
      @"MKBluetoothConnection" : @[address, discoveryButton, connectionData],
      @"MKSerialConnection"    : @[address]
#endif
  };

  NSArray *visible = data[connectionClass];

  [self setFormField:address hidden:![visible containsObject:address]];
  [self setFormField:ipAddressField hidden:![visible containsObject:ipAddressField]];
  [self setFormField:ipPortField hidden:![visible containsObject:ipPortField]];
  [self setFormField:connectionData hidden:![visible containsObject:connectionData]];
  [self setFormField:discoveryBleButton hidden:![visible containsObject:discoveryBleButton]];
  [self setFormField:discoveryButton hidden:![visible containsObject:discoveryButton]];
  [self setFormField:address hidden:![visible containsObject:address]];

}

- (id)modelValueForKeyPath:(NSString *)keyPath {
  if ([keyPath isEqualToString:@"ipAddress"] || [keyPath isEqualToString:@"ipPort"]) {
    return [self valueForKeyPath:keyPath];
  }

  return [super modelValueForKeyPath:keyPath];
}

- (void)setModelValue:(id)value forKeyPath:(NSString *)keyPath {
  if ([keyPath isEqualToString:@"ipAddress"] || [keyPath isEqualToString:@"ipPort"]) {
    [self setValue:value forKeyPath:keyPath];
  }
  else
    [super setModelValue:value forKeyPath:keyPath];

  if ([keyPath isEqualToString:@"connectionClass"]) {

    if ([value isEqualToString:@"MKSerialConnection"]) {
      [self.model setValue:@"/dev/tty.iap" forKey:@"address"];
    }

    [self updateVisibility:value];
  }
}


- (NSArray *)adressItemsIP{
  NSString* modelAdress =[self.model valueForKeyPath:@"address"];
  NSArray *hostItems = [modelAdress componentsSeparatedByString:@":"];
  if ([hostItems count] != 2) {
    return @[modelAdress,@"2000"];
  }
  return hostItems;
}

- (NSString *)ipAddress {
  NSArray *hostItems = [self adressItemsIP];
  return hostItems[0];
}

- (void)setIpAddress:(NSString *)ipAddress {
  NSArray *hostItems = [self adressItemsIP];
  [self.model setValue: [NSString stringWithFormat:@"%@:%@",ipAddress,hostItems[1]] forKeyPath:@"address"];
}

- (NSUInteger)ipPort {
  NSArray *hostItems = [self adressItemsIP];
  return [hostItems[1] intValue];
}

- (void)setIpPort:(NSUInteger)ipPort {
  NSArray *hostItems = [self adressItemsIP];
  [self.model setValue: [NSString stringWithFormat:@"%@:%d",hostItems[0],ipPort] forKeyPath:@"address"];
}


- (void)showDiscoveryBleView {

  MKBLEDiscoveryViewController *controller = [[MKBLEDiscoveryViewController alloc] init];

  UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];


  navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
  controller.delegate = self;
  [rootViewController presentModalViewController:navController animated:YES];
}

- (void)discoveryView:(MKBLEDiscoveryViewController *)discoveryView didSelectDeviceWithIdentifier:(NSString *)uuid
                 name:(NSString *)name {

  [self.model setValue:name forKey:@"name"];
  [self.model setValue:uuid forKey:@"address"];
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
