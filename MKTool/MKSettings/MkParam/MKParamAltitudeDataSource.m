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
#import "MKParamAltitudeDataSource.h"
#import "IBAFormSection+Create.h"

#import "MKParamMainController.h"
#import "MKParamPotiValueTransformer.h"
#import "MKTParamChannelValueTransformer.h"
#import "StringToNumberTransformer.h"
#import "SettingsFieldStyle.h"
#import "SettingsButtonStyle.h"
#import "StepperValueTransformer.h"

@implementation MKParamAltitudeDataSource

- (id)initWithModel:(id)aModel {
  self = [super initWithModel:aModel];
  if (self) {

    NSInteger revision = ((IKParamSet *) aModel).Revision.integerValue;

    //------------------------------------------------------------------------------------------------------------------------
    IBAFormSection *basicFieldSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
    basicFieldSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

    [basicFieldSection addSwitchFieldForKeyPath:@"GlobalConfig_HOEHENREGELUNG" title:NSLocalizedString(@"Enable altitude control", @"MKParam Altitude")];

    //------------------------------------------------------------------------------------------------------------------------
    IBAFormSection *mainSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
    mainSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

    NSArray *pickListOptions = [IBAPickListFormOption pickListOptionsForStrings:[NSArray arrayWithObjects:
        NSLocalizedString(@"Vario altitude", @"MKParam Altitude"),
        NSLocalizedString(@"Height limitation", @"MKParam Altitude"),
        nil]];

    IBASingleIndexTransformer *transformer = [[IBASingleIndexTransformer alloc] initWithPickListOptions:pickListOptions];

    [mainSection addFormField:[[IBAPickListFormField alloc] initWithKeyPath:@"ExtraConfig_HEIGHT_LIMIT"
                                                                      title:NSLocalizedString(@"Control mode", @"MKParam Altitude") valueTransformer:transformer
                                                              selectionMode:IBAPickListSelectionModeSingle
                                                                    options:pickListOptions]];

    [mainSection addSwitchFieldForKeyPath:@"GlobalConfig_HOEHEN_SCHALTER" title:NSLocalizedString(@"Switch for setpoint", @"MKParam Altitude")];
    [mainSection addSwitchFieldForKeyPath:@"GlobalConfig_HOEHEN_SCHALTER" title:NSLocalizedString(@"Acoustic vario", @"MKParam Altitude")];

    //------------------------------------------------------------------------------------------------------------------------
    IBAFormSection *paramSection = [self addSectionWithHeaderTitle:nil footerTitle:NSLocalizedString(@"0 - automatic / 127 - middle position", @"MKParam Altitude")];
    paramSection.formFieldStyle = [[SettingsFieldStyle alloc] init];


    if (revision >= 95) {
      [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
        builder.keyPath = @"HoeheChannel";
        builder.title = NSLocalizedString(@"Setpoint", @"MKParam Altitude");
        builder.minimumValue = 0;
        builder.maximumValue = 31;
        builder.displayValueTransformer = [[MKTParamChannelValueTransformer alloc] initForAltitude];
        builder.formFieldStyle = [SettingsFieldStyleStepper style];
      }]];
    }
    else
      [paramSection addPotiFieldForKeyPath:@"HoeheChannel" title:NSLocalizedString(@"Setpoint", @"MKParam Altitude")];

    [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
      builder.keyPath = @"Hoehe_Verstaerkung";
      builder.title = NSLocalizedString(@"Gain/Rate", @"MKParam Altitude");
      builder.minimumValue = 0;
      builder.maximumValue = 247;
      builder.formFieldStyle = [SettingsFieldStyleStepper style];
    }]];

    [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
      builder.keyPath = @"Hoehe_MinGas";
      builder.title = NSLocalizedString(@"Min. Gas", @"MKParam Altitude");
      builder.minimumValue = 0;
      builder.maximumValue = 247;
      builder.formFieldStyle = [SettingsFieldStyleStepper style];
    }]];

    [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
      builder.keyPath = @"Hoehe_HoverBand";
      builder.title = NSLocalizedString(@"Hover variation", @"MKParam Altitude");
      builder.minimumValue = 0;
      builder.maximumValue = 247;
      builder.formFieldStyle = [SettingsFieldStyleStepper style];
    }]];

    [paramSection addPotiFieldForKeyPath:@"Hoehe_P" title:NSLocalizedString(@"Altitude-P", @"MKParam Altitude")];
    if (revision >= 103){
      [paramSection addPotiFieldForKeyPath:@"Hoehe_TiltCompensation" title:NSLocalizedString(@"Tilt Compensation", @"MKParam Altitude") format:@"%ld %%"];
    }
    else
      [paramSection addPotiFieldForKeyPath:@"Hoehe_GPS_Z" title:NSLocalizedString(@"GPS-Z", @"MKParam Altitude")];
    [paramSection addPotiFieldForKeyPath:@"Luftdruck_D" title:NSLocalizedString(@"Barometric-D", @"MKParam Altitude")];
    [paramSection addPotiFieldForKeyPath:@"Hoehe_ACC_Wirkung" title:NSLocalizedString(@"Z-ACC", @"MKParam Altitude")];

    if (revision >= 88)
      [paramSection addPotiFieldForKeyPath:@"MaxAltitude"
                                     title:NSLocalizedString(@"Max. Altitude", @"MKParam Altitude")
                                     block:^NSString *(NSInteger value) {
                                       if (value == 0) {
                                         return NSLocalizedString(@"Inactive", @"Channels transformer");
                                       }
                                       return [NSString stringWithFormat:@"%ld m", (long)value];
                                     }];


    [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
      builder.keyPath = @"Hoehe_StickNeutralPoint";
      builder.title = NSLocalizedString(@"Stick neutral point", @"MKParam Altitude");
      builder.minimumValue = 0;
      builder.maximumValue = 160;
      builder.formFieldStyle = [SettingsFieldStyleStepper style];
    }]];

    //------------------------------------------------------------------------------------------------------------------------
    if (revision >= 95) {
      IBAFormSection *paramSection3 = [self addSectionWithHeaderTitle:nil footerTitle:nil];
      paramSection3.formFieldStyle = [[SettingsFieldStyle alloc] init];

      [paramSection3 addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
        builder.keyPath = @"StartLandChannel";
        builder.title = NSLocalizedString(@"StartLandChannel", @"MKParam Altitude");
        builder.minimumValue = 0;
        builder.maximumValue = 31;
        builder.displayValueTransformer = [[MKTParamChannelValueTransformer alloc] initForAltitude];
        builder.formFieldStyle = [SettingsFieldStyleStepper style];
      }]];

      [paramSection3 addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
        builder.keyPath = @"LandingSpeed";
        builder.title = NSLocalizedString(@"LandingSpeed", @"MKParam Altitude");
        builder.minimumValue = 0;
        builder.maximumValue = 247;
        builder.displayValueTransformer = [LandingSpeedTransformer instance];
        builder.formFieldStyle = [SettingsFieldStyleStepper style];
      }]];
    }


  }

  return self;
}


- (void)setModelValue:(id)value forKeyPath:(NSString *)keyPath {
  [super setModelValue:value forKeyPath:keyPath];

  NSLog(@"%@", [self.model description]);
}

@end
