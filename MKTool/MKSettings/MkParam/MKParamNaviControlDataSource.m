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
#import "MKParamNaviControlDataSource.h"
#import "MKTParamChannelValueTransformer.h"
#import "IBAFormSection+Create.h"

#import "MKParamMainController.h"

#import "StringToNumberTransformer.h"
#import "SettingsFieldStyle.h"
#import "SettingsButtonStyle.h"
#import "StepperValueTransformer.h"

@implementation MKParamNaviControlDataSource

- (id)initWithModel:(id)aModel {
  self = [super initWithModel:aModel];
  if (self) {

    NSInteger revision = ((IKParamSet *) aModel).Revision.integerValue;

    IBAFormFieldStyle *switchStyle = [[SettingsFieldStyleSwitch alloc] init];

    IBAFormSection *paramSection = nil;
    //------------------------------------------------------------------------------------------------------------------------
    paramSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
    paramSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

    [paramSection addSwitchFieldForKeyPath:@"GlobalConfig_GPS_AKTIV" title:NSLocalizedString(@"Enable GPS", @"MKParam NaviCtrl") style:switchStyle];

    //------------------------------------------------------------------------------------------------------------------------
    paramSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
    paramSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

    if (revision >= 95) {
      IBAStepperFormField *stepperField = [[IBAStepperFormField alloc] initWithKeyPath:@"NaviGpsModeChannel"
                                                                                 title:NSLocalizedString(@"GPS Mode", @"MKParam NaviCtrl")];

      stepperField.displayValueTransformer = [[MKTParamChannelValueTransformer alloc] initForGps];
      stepperField.minimumValue = 0;
      stepperField.maximumValue = 32;
      [paramSection addFormField:stepperField];
    }
    else
      [paramSection addPotiFieldForKeyPath:@"NaviGpsModeChannel" title:NSLocalizedString(@"GPS Mode control", @"MKParam NaviCtrl")];

    if (revision >= 88) {
      [paramSection addSwitchFieldForKeyPath:@"ExtraConfig_GPS_AID" title:NSLocalizedString(@"Dynamic PH", @"MKParam NaviCtrl") style:switchStyle];
      if (revision >= 90 && revision < 100) {
        [paramSection addSwitchFieldForKeyPath:@"GlobalConfig3_CFG3_DPH_MAX_RADIUS"
                                         title:NSLocalizedString(@"Use GPS max. raduis for dPH ", @"MKParam NaviCtrl") style:switchStyle];
      }

      [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
        builder.keyPath = @"ComingHomeAltitude";
        builder.title = NSLocalizedString(@"CH Altitude", @"MKParam NaviCtrl");
        builder.minimumValue = 0;
        builder.maximumValue = 255;
        builder.displayValueTransformer = [CHAltitudeTransformer instance];
        builder.formFieldStyle = [SettingsFieldStyleStepper style];
      }]];
    }

    [paramSection addPotiFieldForKeyPath:@"SingleWpSpeed" title:NSLocalizedString(@"Single Wp Speed", @"MKParam NaviCtrl") block:^NSString *(NSInteger value) {
      return [NSString stringWithFormat:@"%.1f m/s",value/10.0 ];
    }];
    

    if(revision < 102){
      [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
        builder.keyPath = @"NaviMaxFlyingRange";
        builder.title = NSLocalizedString(@"GPS max. radius", @"MKParam NaviCtrl");
        builder.minimumValue = 0;
        builder.maximumValue = 245;
        builder.formFieldStyle = [SettingsFieldStyleStepper style];
      }]];
    }
    else{
      [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
        builder.keyPath = @"NaviMaxFlyingRange";
        builder.title = NSLocalizedString(@"Max. Flying Range", @"MKParam NaviCtrl");
        builder.minimumValue = 0;
        builder.maximumValue = 255;
        builder.displayValueTransformer = [RadiusTransformer instance];
        builder.formFieldStyle = [SettingsFieldStyleStepper style];
      }]];
      
      [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
        builder.keyPath = @"NaviDescendRange";
        builder.title = NSLocalizedString(@"Decent Range", @"MKParam NaviCtrl");
        builder.minimumValue = 0;
        builder.maximumValue = 255;
        builder.displayValueTransformer = [RadiusTransformer instance];
        builder.formFieldStyle = [SettingsFieldStyleStepper style];
      }]];
      
    }


    //------------------------------------------------------------------------------------------------------------------------
    paramSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
    paramSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

    [paramSection addPotiFieldForKeyPath:@"NaviGpsGain" title:NSLocalizedString(@"GPS Gain", @"MKParam NaviCtrl") format:@"%d %%"];

    [paramSection addNumberFieldForKeyPath:@"NaviStickThreshold" title:NSLocalizedString(@"GPS stick threshold", @"MKParam NaviCtrl")];
    [paramSection addNumberFieldForKeyPath:@"NaviGpsMinSat" title:NSLocalizedString(@"GPS min. Sat", @"MKParam NaviCtrl")];
    
    [paramSection addNumberFieldForKeyPath:@"NaviGpsP" title:NSLocalizedString(@"GPS-P", @"MKParam NaviCtrl")];
    [paramSection addNumberFieldForKeyPath:@"NaviGpsPLimit" title:NSLocalizedString(@"GPS-P limit", @"MKParam NaviCtrl")];
    [paramSection addNumberFieldForKeyPath:@"NaviGpsI" title:NSLocalizedString(@"GPS-I", @"MKParam NaviCtrl")];
    [paramSection addNumberFieldForKeyPath:@"NaviGpsILimit" title:NSLocalizedString(@"GPS-I limit", @"MKParam NaviCtrl")];
    [paramSection addNumberFieldForKeyPath:@"NaviGpsD" title:NSLocalizedString(@"GPS-D", @"MKParam NaviCtrl")];
    [paramSection addNumberFieldForKeyPath:@"NaviGpsDLimit" title:NSLocalizedString(@"GPS-D limit", @"MKParam NaviCtrl")];

    //------------------------------------------------------------------------------------------------------------------------
    paramSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
    paramSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

    [paramSection addPotiFieldForKeyPath:@"NaviGpsA" title:NSLocalizedString(@"GPS ACC", @"MKParam NaviCtrl")];
    [paramSection addPotiFieldForKeyPath:@"NaviAccCompensation" title:NSLocalizedString(@"GPS ACC comp.", @"MKParam NaviCtrl")];
    [paramSection addPotiFieldForKeyPath:@"NaviWindCorrection" title:NSLocalizedString(@"GPS wind corr.", @"MKParam NaviCtrl") format:@"%d %%"];

    [paramSection addPotiFieldForKeyPath:@"NaviAngleLimitation" title:NSLocalizedString(@"GPS angle limit", @"MKParam NaviCtrl")];
    
    [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
      builder.keyPath = @"NaviPH_LoginTime";
      builder.title = NSLocalizedString(@"PH login time", @"MKParam NaviCtrl");
      builder.minimumValue = 0;
      builder.maximumValue = 247;
      builder.displayValueTransformer = [TimeTransformer instance];
      builder.formFieldStyle = [SettingsFieldStyleStepper style];
    }]];

  }

  return self;
}


- (void)setModelValue:(id)value forKeyPath:(NSString *)keyPath {
  [super setModelValue:value forKeyPath:keyPath];

  NSLog(@"%@", [self.model description]);
}

@end
