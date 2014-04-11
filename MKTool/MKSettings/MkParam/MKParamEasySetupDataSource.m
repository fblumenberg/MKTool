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
    
    IBAStepperFormField *stepperField = [[IBAStepperFormField alloc] initWithKeyPath:@"OrientationAngle"
                                                                               title:NSLocalizedString(@"Orientation", @"MKParam Altitude")];
    
    stepperField.displayValueTransformer = [OrientationTransformer instance];
    stepperField.minimumValue = 0;
    stepperField.maximumValue = 23;
    [paramSection3 addFormField:stepperField];
  }

  return self;
}

- (void)initAltitudeSection:(NSInteger)revision {
  IBAFormSection *altitudeSection = [self addSectionWithHeaderTitle:NSLocalizedString(@"Altitude control", @"MKParam Altitude button")
                                                        footerTitle:nil];

  altitudeSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

  [altitudeSection addSwitchFieldForKeyPath:@"GlobalConfig_HOEHENREGELUNG" title:NSLocalizedString(@"Enable", @"MKParam EasySetup Altitude")];


  NSArray *modeNames = @[
      NSLocalizedString(@"Vario altitude", @"MKParam Altitude"),
      NSLocalizedString(@"Height limitation", @"MKParam Altitude")
  ];

  IndexToStringTransformer *transformer = [[IndexToStringTransformer alloc] initWithArray:modeNames];

  // IBAReadOnlyTextFormField displays the value the field is bound in a read-only text view. The title is displayed as the field's label.
  [altitudeSection addFormField:[[IBAReadOnlyTextFormField alloc] initWithKeyPath:@"ExtraConfig_HEIGHT_LIMIT"
                                                                            title:NSLocalizedString(@"Control mode", @"MKParam Altitude") valueTransformer:transformer]];


  if (revision >= 95) {
    IBAStepperFormField *stepperField = [[IBAStepperFormField alloc] initWithKeyPath:@"HoeheChannel"
                                                                               title:NSLocalizedString(@"Setpoint", @"MKParam Altitude")];

    stepperField.displayValueTransformer = [[MKTParamChannelValueTransformer alloc] initForAltitude];
    stepperField.minimumValue = 0;
    stepperField.maximumValue = 31;

    [altitudeSection addFormField:stepperField];
  }
  else
    [altitudeSection addPotiFieldForKeyPath:@"HoeheChannel" title:NSLocalizedString(@"Setpoint", @"MKParam Altitude")];

  [altitudeSection addNumberFieldForKeyPath:@"Hoehe_StickNeutralPoint" title:NSLocalizedString(@"Stick neutral point", @"MKParam Altitude")];

  if (revision >= 95) {

    IBAStepperFormField *stepperField = [[IBAStepperFormField alloc] initWithKeyPath:@"StartLandChannel"
                                                                               title:NSLocalizedString(@"StartLandChannel", @"MKParam Altitude")];

    stepperField.displayValueTransformer = [MKTParamChannelValueTransformer instance];
    stepperField.minimumValue = 0;
    stepperField.maximumValue = 32;
    [altitudeSection addFormField:stepperField];
  }
}

- (void)initGpsSection:(NSInteger)revision {

  IBAFormSection *gpsSection = [self addSectionWithHeaderTitle:NSLocalizedString(@"GPS", @"MKParam EasySetup Altitude") footerTitle:nil];
  gpsSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

  [gpsSection addSwitchFieldForKeyPath:@"GlobalConfig_GPS_AKTIV" title:NSLocalizedString(@"Enable", @"MKParam NaviCtrl")];


  if (revision >= 95) {
    IBAStepperFormField *stepperField = [[IBAStepperFormField alloc] initWithKeyPath:@"NaviGpsModeChannel"
                                                                               title:NSLocalizedString(@"GPS Mode", @"MKParam NaviCtrl")];

    stepperField.displayValueTransformer = [[MKTParamChannelValueTransformer alloc] initForGps];
    stepperField.minimumValue = 0;
    stepperField.maximumValue = 32;
    [gpsSection addFormField:stepperField];
  }
  else
    [gpsSection addPotiFieldForKeyPath:@"NaviGpsModeChannel" title:NSLocalizedString(@"GPS Mode control", @"MKParam NaviCtrl")];

  if (revision >= 88) {
    [gpsSection addSwitchFieldForKeyPath:@"ExtraConfig_GPS_AID" title:NSLocalizedString(@"Dynamic PH", @"MKParam NaviCtrl")];

    IBAStepperFormField *stepperField = [[IBAStepperFormField alloc] initWithKeyPath:@"ComingHomeAltitude"
                                                                               title:NSLocalizedString(@"CH Altitude", @"MKParam NaviCtrl")];

    stepperField.displayValueTransformer = [CHAltitudeTransformer instance];
    stepperField.minimumValue = 0;
    stepperField.maximumValue = 255;
    [gpsSection addFormField:stepperField];
  }

}

- (void)initCarefreeSection:(NSInteger)revision {
  IBAFormSection *carefreeSection = [self addSectionWithHeaderTitle:NSLocalizedString(@"Carefree control", @"MKParam EasySetup Carefree") footerTitle:nil];
  carefreeSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

  if (revision >= 95) {
    IBAStepperFormField *stepperField = [[IBAStepperFormField alloc] initWithKeyPath:@"CareFreeChannel"
                                                                               title:NSLocalizedString(@"Carefree", @"MKParam Misc")];

    stepperField.displayValueTransformer = [MKTParamChannelValueTransformer instance];
    stepperField.minimumValue = 0;
    stepperField.maximumValue = 32;
    [carefreeSection addFormField:stepperField];

  }
  else
    [carefreeSection addPotiFieldForKeyPath:@"CareFreeChannel" title:NSLocalizedString(@"Carefree control", @"MKParam Misc")];

  if (revision >= 88)
    [carefreeSection addSwitchFieldForKeyPath:@"ExtraConfig_LEARNABLE_CAREFREE" title:NSLocalizedString(@"Teachable Carefree", @"MKParam Misc")];

}

- (void)setModelValue:(id)value forKeyPath:(NSString *)keyPath {
  [super setModelValue:value forKeyPath:keyPath];

  NSLog(@"%@", [self.model description]);
}

@end
