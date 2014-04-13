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
#import "MKParamChannelsDataSource.h"
#import "IBAFormSection+Create.h"

#import "MKParamMainController.h"

#import "StringToNumberTransformer.h"
#import "SettingsFieldStyle.h"
#import "SettingsButtonStyle.h"

#import "ChannelsViewController.h"
#import "MKTParamChannelValueTransformer.h"

@implementation MKParamChannelsDataSource

- (id)initWithModel:(id)aModel {
  self = [super initWithModel:aModel];
  if (self) {
    NSInteger revision = ((IKParamSet *) aModel).Revision.integerValue;

    [self initReceiverSection:revision];
    
    BOOL expertMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"MKParamsExpertMode"];
    if(expertMode)
      [self initMotorSection:revision];

    //------------------------------------------------------------------------------------------------------------------------
    IBAFormSection *paramSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
    paramSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

    ChannelsViewController *channelsTest = [[ChannelsViewController alloc] initWithStyle:UITableViewStylePlain];
    IBAButtonFormField *button = [[IBAButtonFormField alloc] initWithTitle:NSLocalizedString(@"Channels test", @"MKParam Channels button") icon:nil detailViewController:channelsTest];
    button.formFieldStyle = [[SettingsButtonIndicatorStyle alloc] init];
    [paramSection addFormField:button];

    paramSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
    paramSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

    [paramSection addChannelsForKeyPath:@"Kanalbelegung_02" title:NSLocalizedString(@"Gas", @"MKParam Channels")];
    [paramSection addChannelsForKeyPath:@"Kanalbelegung_03" title:NSLocalizedString(@"Yaw", @"MKParam Channels")];
    [paramSection addChannelsForKeyPath:@"Kanalbelegung_00" title:NSLocalizedString(@"Nick", @"MKParam Channels")];
    [paramSection addChannelsForKeyPath:@"Kanalbelegung_01" title:NSLocalizedString(@"Roll", @"MKParam Channels")];
    [paramSection addChannelsPlusForKeyPath:@"Kanalbelegung_04" title:NSLocalizedString(@"Poti 1", @"MKParam Channels")];
    [paramSection addChannelsPlusForKeyPath:@"Kanalbelegung_05" title:NSLocalizedString(@"Poti 2", @"MKParam Channels")];
    [paramSection addChannelsPlusForKeyPath:@"Kanalbelegung_06" title:NSLocalizedString(@"Poti 3", @"MKParam Channels")];
    [paramSection addChannelsPlusForKeyPath:@"Kanalbelegung_07" title:NSLocalizedString(@"Poti 4", @"MKParam Channels")];
    [paramSection addChannelsPlusForKeyPath:@"Kanalbelegung_08" title:NSLocalizedString(@"Poti 5", @"MKParam Channels")];
    [paramSection addChannelsPlusForKeyPath:@"Kanalbelegung_09" title:NSLocalizedString(@"Poti 6", @"MKParam Channels")];
    [paramSection addChannelsPlusForKeyPath:@"Kanalbelegung_10" title:NSLocalizedString(@"Poti 7", @"MKParam Channels")];
    [paramSection addChannelsPlusForKeyPath:@"Kanalbelegung_11" title:NSLocalizedString(@"Poti 8", @"MKParam Channels")];
  }

  return self;
}

- (void)initReceiverSection:(NSInteger)revision {
  IBAFormSection *paramSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
  paramSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

  NSArray *pickListOptions = [IBAPickListFormOption pickListOptionsForStrings:[NSArray arrayWithObjects:
      NSLocalizedString(@"Multisignal(PPM)", @"MKParam Channels"),
      NSLocalizedString(@"Spectrum", @"MKParam Channels"),
      NSLocalizedString(@"Spectrum (HighRes)", @"MKParam Channels"),
      NSLocalizedString(@"Spectrum (LowRes)", @"MKParam Channels"),
      NSLocalizedString(@"Jeti Sattelite", @"MKParam Channels"),
      NSLocalizedString(@"ACT DSL", @"MKParam Channels"),
      NSLocalizedString(@"Graupner HoTT", @"MKParam Channels"),
      NSLocalizedString(@"Futaba S.BUS", @"MKParam Channels"),
      NSLocalizedString(@"User", @"MKParam Channels"),
      nil]];

  IBASingleIndexTransformer *transformer = [[IBASingleIndexTransformer alloc] initWithPickListOptions:pickListOptions];

  [paramSection addFormField:[[IBAPickListFormField alloc] initWithKeyPath:@"Receiver"
                                                                     title:NSLocalizedString(@"Receiver", @"MKParam Channels") valueTransformer:transformer
                                                             selectionMode:IBAPickListSelectionModeSingle
                                                                   options:pickListOptions]];

  [paramSection addSwitchFieldForKeyPath:@"ExtraConfig_SENSITIVE_RC"
                                   title:NSLocalizedString(@"Sensitive receiver signal validation", @"MKParam Channels")
                                   style:[SettingsFieldStyleSwitch style]];

  if (revision >= 92) {
    [paramSection addSwitchFieldForKeyPath:@"GlobalConfig3_CFG3_SPEAK_ALL"
                                     title:NSLocalizedString(@"Telemetry: Speak all events", @"MKParam Channels")
                                     style:[SettingsFieldStyleSwitch style]];
  }

}

- (void)initMotorSection:(NSInteger)revision {
  IBAFormSection *paramSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
  paramSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

  [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
    builder.keyPath = @"MotorSafetySwitch";
    builder.title = NSLocalizedString(@"Motor safety swich", @"MKParam Channels");
    builder.minimumValue = 0;
    builder.maximumValue = 30;
    builder.displayValueTransformer = [[MKTParamChannelValueTransformer alloc] initForAltitude];
    builder.formFieldStyle = [SettingsFieldStyleStepper style];
  }]];

  if (revision >= 91) {
    [paramSection addSwitchFieldForKeyPath:@"GlobalConfig3_CFG3_MOTOR_SWITCH_MODE"
                                     title:NSLocalizedString(@"Motor start/stop -> gas 0 && motor switch on/off", @"MKParam Channels")
                                     style:[SettingsFieldStyleSwitch style]];
  }


}

- (void)setModelValue:(id)value forKeyPath:(NSString *)keyPath {
  [super setModelValue:value forKeyPath:keyPath];

  NSLog(@"%@", [self.model description]);
}

@end
