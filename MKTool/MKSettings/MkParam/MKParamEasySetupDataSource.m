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
#import "MKParamEasySetupDataSource.h"
#import "IBAFormSection+Create.h"

#import "MKParamMainController.h"
#import "MKParamPotiValueTransformer.h"
#import "MKTParamChannelValueTransformer.h"
#import "StringToNumberTransformer.h"
#import "StepperValueTransformer.h"
#import "SettingsFieldStyle.h"
#import "SettingsButtonStyle.h"

@implementation MKParamEasySetupDataSource

- (id)initWithModel:(id)aModel {
  self = [super initWithModel:aModel];
  if (self) {

    NSInteger revision = ((IKParamSet *) aModel).Revision.integerValue;

    //------------------------------------------------------------------------------------------------------------------------
    [self initAltitudeSection:revision];
    [self initGpsSection:revision];
    [self initCarefreeSection:revision];

    //------------------------------------------------------------------------------------------------------------------------

    IBAFormSection *paramSection3 = [self addSectionWithHeaderTitle:nil footerTitle:nil];
    paramSection3.formFieldStyle = [[SettingsFieldStyle alloc] init];
    
    [paramSection3 addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder* builder){
      builder.keyPath=@"OrientationAngle";
      builder.title=NSLocalizedString(@"Orientation", @"MKParam Altitude");
      builder.minimumValue=0;
      builder.maximumValue=23;
      builder.displayValueTransformer = [OrientationTransformer instance];
      builder.formFieldStyle=[SettingsFieldStyleStepper style];
    }]];
  }

  return self;
}

- (void)initAltitudeSection:(NSInteger)revision {
  IBAFormSection *altitudeSection = [self addSectionWithHeaderTitle:NSLocalizedString(@"Altitude control", @"MKParam Altitude button")
                                                        footerTitle:nil];

  altitudeSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

  [altitudeSection addSwitchFieldForKeyPath:@"GlobalConfig_HOEHENREGELUNG"
                                      title:NSLocalizedString(@"Enable", @"MKParam EasySetup Altitude")
                                      style:[SettingsFieldStyleSwitch style]];


  NSArray *modeNames = @[
      NSLocalizedString(@"Vario altitude", @"MKParam Altitude"),
      NSLocalizedString(@"Height limitation", @"MKParam Altitude")
  ];

  IndexToStringTransformer *transformer = [[IndexToStringTransformer alloc] initWithArray:modeNames];

  // IBAReadOnlyTextFormField displays the value the field is bound in a read-only text view. The title is displayed as the field's label.
  [altitudeSection addFormField:[[IBAReadOnlyTextFormField alloc] initWithKeyPath:@"ExtraConfig_HEIGHT_LIMIT"
                                                                            title:NSLocalizedString(@"Control mode", @"MKParam Altitude")
                                                                  valueTransformer:transformer]];


  if (revision >= 95) {
    [altitudeSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder* builder){
      builder.keyPath=@"HoeheChannel";
      builder.title=NSLocalizedString(@"Setpoint", @"MKParam Altitude");
      builder.minimumValue=0;
      builder.maximumValue=31;
      builder.displayValueTransformer = [[MKTParamChannelValueTransformer alloc] initForAltitude];
      builder.formFieldStyle=[SettingsFieldStyleStepper style];
    }]];
  }
  else
    [altitudeSection addPotiFieldForKeyPath:@"HoeheChannel" title:NSLocalizedString(@"Setpoint", @"MKParam Altitude")];

  [altitudeSection addNumberFieldForKeyPath:@"Hoehe_StickNeutralPoint" title:NSLocalizedString(@"Stick neutral point", @"MKParam Altitude")];

  if (revision >= 95) {

    [altitudeSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder* builder){
      builder.keyPath=@"StartLandChannel";
      builder.title=NSLocalizedString(@"StartLandChannel", @"MKParam Altitude");
      builder.minimumValue=0;
      builder.maximumValue=32;
      builder.displayValueTransformer = [MKTParamChannelValueTransformer instance];
      builder.formFieldStyle=[SettingsFieldStyleStepper style];
    }]];
  }
}

- (void)initGpsSection:(NSInteger)revision {

  IBAFormSection *gpsSection = [self addSectionWithHeaderTitle:NSLocalizedString(@"GPS", @"MKParam EasySetup Altitude") footerTitle:nil];
  gpsSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

  [gpsSection addSwitchFieldForKeyPath:@"GlobalConfig_GPS_AKTIV" title:NSLocalizedString(@"Enable", @"MKParam NaviCtrl")];


  if (revision >= 95) {
    [gpsSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder* builder){
      builder.keyPath=@"NaviGpsModeChannel";
      builder.title=NSLocalizedString(@"GPS Mode", @"MKParam NaviCtrl");
      builder.minimumValue=0;
      builder.maximumValue=32;
      builder.displayValueTransformer = [MKTParamChannelValueTransformer instance];
      builder.formFieldStyle=[SettingsFieldStyleStepper style];
    }]];
  }
  else
    [gpsSection addPotiFieldForKeyPath:@"NaviGpsModeChannel" title:NSLocalizedString(@"GPS Mode control", @"MKParam NaviCtrl")];

  if (revision >= 88) {
    [gpsSection addSwitchFieldForKeyPath:@"ExtraConfig_GPS_AID"
                                   title:NSLocalizedString(@"Dynamic PH", @"MKParam NaviCtrl")
                                   style:[SettingsFieldStyleSwitch style]];


    [gpsSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder* builder){
      builder.keyPath=@"ComingHomeAltitude";
      builder.title=NSLocalizedString(@"CH Altitude", @"MKParam NaviCtrl");
      builder.minimumValue=0;
      builder.maximumValue=255;
      builder.displayValueTransformer = [CHAltitudeTransformer instance];
      builder.formFieldStyle=[SettingsFieldStyleStepper style];
    }]];
  }

}

- (void)initCarefreeSection:(NSInteger)revision {
  IBAFormSection *carefreeSection = [self addSectionWithHeaderTitle:NSLocalizedString(@"Carefree control", @"MKParam EasySetup Carefree") footerTitle:nil];
  carefreeSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

  if (revision >= 95) {
    [carefreeSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder* builder){
      builder.keyPath=@"CareFreeChannel";
      builder.title=NSLocalizedString(@"Carefree", @"MKParam NaviCtrl");
      builder.minimumValue=0;
      builder.maximumValue=32;
      builder.displayValueTransformer = [MKTParamChannelValueTransformer instance];
      builder.formFieldStyle=[SettingsFieldStyleStepper style];
    }]];
  }
  else
    [carefreeSection addPotiFieldForKeyPath:@"CareFreeChannel" title:NSLocalizedString(@"Carefree control", @"MKParam Misc")];

  if (revision >= 88)
    [carefreeSection addSwitchFieldForKeyPath:@"ExtraConfig_LEARNABLE_CAREFREE"
                                        title:NSLocalizedString(@"Teachable Carefree", @"MKParam Misc")
                                        style:[SettingsFieldStyleSwitch style]];

}

- (void)setModelValue:(id)value forKeyPath:(NSString *)keyPath {
  [super setModelValue:value forKeyPath:keyPath];

  NSLog(@"%@", [self.model description]);
}

@end
