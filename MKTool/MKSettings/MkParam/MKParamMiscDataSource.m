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
#import "MKParamMiscDataSource.h"
#import "MKTParamChannelValueTransformer.h"
#import "IBAFormSection+Create.h"

#import "MKParamMainController.h"

#import "StringToNumberTransformer.h"
#import "SettingsFieldStyle.h"
#import "SettingsButtonStyle.h"
#import "StepperValueTransformer.h"
#import "MKTParamChannelValueTransformer.h"

@interface MKParamMiscDataSource ()

@property(nonatomic,retain) IBATextFormField* fieldNotGas;
- (void)updateFieldNotGas;
@end

@implementation MKParamMiscDataSource

@synthesize fieldNotGas;

- (id)initWithModel:(id)aModel {
  self = [super initWithModel:aModel];
  if (self) {

    NSInteger revision = ((IKParamSet *) aModel).Revision.integerValue;

    IBAFormFieldStyle *switchStyle = [[SettingsFieldStyleSwitch alloc] init];

    IBAFormSection *paramSection = nil;
    //------------------------------------------------------------------------------------------------------------------------
    paramSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
    paramSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

    [paramSection addNumberFieldForKeyPath:@"Gas_Min" title:NSLocalizedString(@"Min. Gas", @"MKParam Misc")];
    [paramSection addNumberFieldForKeyPath:@"Gas_Max" title:NSLocalizedString(@"Max. Gas", @"MKParam Misc")];

    //------------------------------------------------------------------------------------------------------------------------
    paramSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
    paramSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

    [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
      builder.keyPath = @"UnterspannungsWarnung";
      builder.title = NSLocalizedString(@"Low voltage level", @"MKParam Misc");
      builder.minimumValue = 0;
      builder.maximumValue = 50;
      builder.displayValueTransformer = [VoltageTransformer instance];
      builder.formFieldStyle = [SettingsFieldStyleStepper style];
    }]];
    
    if (revision >= 88){
      [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
        builder.keyPath = @"AutoLandingVoltage";
        builder.title = NSLocalizedString(@"Autolanding voltage level", @"MKParam Misc");
        builder.minimumValue = 0;
        builder.maximumValue = 50;
        builder.displayValueTransformer = [VoltageTransformer instance];
        builder.formFieldStyle = [SettingsFieldStyleStepper style];
      }]];

      [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
        builder.keyPath = @"ComingHomeVoltage";
        builder.title = NSLocalizedString(@"CH voltage level", @"MKParam Misc");
        builder.minimumValue = 0;
        builder.maximumValue = 50;
        builder.displayValueTransformer = [VoltageTransformer instance];
        builder.formFieldStyle = [SettingsFieldStyleStepper style];
      }]];

    }
    

    NSArray *pickListOptions = [IBAPickListFormOption pickListOptionsForStrings:[NSArray arrayWithObjects:
            NSLocalizedString(@"3.0 V", @"MKParam Misc"),
            NSLocalizedString(@"3.3 V", @"MKParam Misc"),
            nil]];

    IBASingleIndexTransformer *transformer = [[IBASingleIndexTransformer alloc] initWithPickListOptions:pickListOptions];

    [paramSection addFormField:[[IBAPickListFormField alloc] initWithKeyPath:@"ExtraConfig_3_3V_REFERENCE"
                                                                        title:NSLocalizedString(@"Voltage reference", @"MKParam Misc") valueTransformer:transformer
                                                                selectionMode:IBAPickListSelectionModeSingle
                                                                      options:pickListOptions]];

    //------------------------------------------------------------------------------------------------------------------------
    paramSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
    paramSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

    if (revision >= 95){
      IBAStepperFormField* stepperField = [[IBAStepperFormField alloc] initWithKeyPath:@"CareFreeChannel"
                                                                                 title:NSLocalizedString(@"Carefree", @"MKParam Misc")];
      
      stepperField.displayValueTransformer=[MKTParamChannelValueTransformer instance];
      stepperField.minimumValue = 0;
      stepperField.maximumValue = 32;
      [paramSection addFormField:stepperField];

    }
    else
      [paramSection addPotiFieldForKeyPath:@"CareFreeChannel" title:NSLocalizedString(@"Carefree control", @"MKParam Misc")];
    
    if (revision >= 88)
    [paramSection addSwitchFieldForKeyPath:@"ExtraConfig_LEARNABLE_CAREFREE" title:NSLocalizedString(@"Teachable Carefree", @"MKParam Misc") style:switchStyle];

    //------------------------------------------------------------------------------------------------------------------------
    paramSection = [self addSectionWithHeaderTitle:NSLocalizedString(@"Sender signal lost", @"MKParam Misc") footerTitle:nil];
    paramSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

    [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
      builder.keyPath = @"NotGasZeit";
      builder.title = NSLocalizedString(@"Emergency time (0.1s)", @"MKParam Misc");
      builder.minimumValue = 0;
      builder.maximumValue = 255;
      builder.displayValueTransformer = [TenthSecondTransformer instance];
      builder.formFieldStyle = [SettingsFieldStyleStepper style];
    }]];

    self.fieldNotGas = [paramSection addNumberFieldForKeyPath:@"NotGas" title:NSLocalizedString(@"Emergency-Gas", @"MKParam Misc")];
    [self updateFieldNotGas];
    
    //------------------------------------------------------------------------------------------------------------------------
    paramSection = [self addSectionWithHeaderTitle:NSLocalizedString(@"Failsafe", @"MKParam Misc") footerTitle:nil];
    paramSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

    if (revision >= 88)
      [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
        builder.keyPath = @"FailSafeTime";
        builder.title = NSLocalizedString(@"Comming Home time (s)", @"MKParam Misc");
        builder.minimumValue = 0;
        builder.maximumValue = 247;
        builder.displayValueTransformer = [SecondTransformer instance];
        builder.formFieldStyle = [SettingsFieldStyleStepper style];
      }]];

    if (revision >= 90){
      [paramSection addSwitchFieldForKeyPath:@"GlobalConfig3_CFG3_VARIO_FAILSAFE" title:NSLocalizedString(@"Use vario for altitude", @"MKParam Misc") style:switchStyle];

      [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
        builder.keyPath = @"FailsafeChannel";
        builder.title = NSLocalizedString(@"Channel", @"MKParam Misc");
        builder.minimumValue = 0;
        builder.maximumValue = 16;
        builder.displayValueTransformer = [MKTParamChannelValueTransformer instance];
        builder.formFieldStyle = [SettingsFieldStyleStepper style];
      }]];

    }


    //------------------------------------------------------------------------------------------------------------------------
    paramSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
    paramSection.formFieldStyle = [[SettingsFieldStyle alloc] init];
    if (revision >= 88)
    [paramSection addSwitchFieldForKeyPath:@"ExtraConfig_NO_RCOFF_BEEPING" title:NSLocalizedString(@"No Beep w.o. active sender", @"MKParam Misc") style:switchStyle];

    if (revision >= 88)
    [paramSection addSwitchFieldForKeyPath:@"ExtraConfig_IGNORE_MAG_ERR_AT_STARTUP"
                                     title:NSLocalizedString(@"Ignore magnet error at startup", @"MKParam Misc") style:switchStyle];
    if (revision >= 90){
      [paramSection addSwitchFieldForKeyPath:@"GlobalConfig3_CFG3_NO_SDCARD_NO_START" title:NSLocalizedString(@"No start without SD card", @"MKParam Misc") style:switchStyle];
    }

    if (revision >= 91){
      [paramSection addSwitchFieldForKeyPath:@"GlobalConfig3_CFG3_MOTOR_SWITCH_MODE" title:NSLocalizedString(@"No start without GPS fix", @"MKParam Misc") style:switchStyle];
    }

    //------------------------------------------------------------------------------------------------------------------------
    paramSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
    paramSection.formFieldStyle = [[SettingsFieldStyle alloc] init];
    [paramSection addSwitchFieldForKeyPath:@"GlobalConfig_HEADING_HOLD" title:NSLocalizedString(@"Heading Hold", @"MKParam Misc") style:switchStyle];


  }

  return self;
}

- (void)dealloc{
  self.fieldNotGas=nil;
}


- (void)updateFieldNotGas{
  if( [[self.model GlobalConfig3_CFG3_VARIO_FAILSAFE] boolValue] ){
    self.fieldNotGas.title = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"Emergency-Gas", @"MKParam Misc"),@" [%]"];
  }
  else {
    self.fieldNotGas.title = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"Emergency-Gas", @"MKParam Misc"),@""];
  }

  [self.fieldNotGas updateCellContents];
}

- (void)setModelValue:(id)value forKeyPath:(NSString *)keyPath {
  [super setModelValue:value forKeyPath:keyPath];

  if([keyPath isEqualToString:@"GlobalConfig3_CFG3_VARIO_FAILSAFE"]){
    [self updateFieldNotGas];
    NSLog(@"%@",value);
  }
    
}

@end
