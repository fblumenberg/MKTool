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
#import "MKParamCameraDataSource.h"
#import "IBAFormSection+Create.h"

#import "MKParamMainController.h"

#import "StringToNumberTransformer.h"
#import "SettingsFieldStyle.h"
#import "SettingsButtonStyle.h"
#import "StepperValueTransformer.h"

@implementation MKParamCameraDataSource

- (void)initWithParameter:(IKParamSet *)paramSet {

  [self initNickSection:paramSet.Revision.integerValue];
  [self initRollSection:paramSet.Revision.integerValue];
  [self initServoSection:paramSet.Revision.integerValue];
  [self initOrientationSection:paramSet.Revision.integerValue];
  
  [self performSelector:@selector(updateFields) withObject:self afterDelay:0.01];
}

- (void)initRollSection:(NSInteger)revision {
  IBAFormSection *paramSection = [self addSectionWithHeaderTitle:NSLocalizedString(@"Roll", @"MKParam Camera") footerTitle:nil];
  paramSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

  [paramSection addPotiFieldForKeyPath:@"ServoRollControl" title:NSLocalizedString(@"Servo control", @"MKParam Camera")];
  [paramSection addPotiFieldForKeyPath:@"ServoRollComp" title:NSLocalizedString(@"Compensation", @"MKParam Camera")];

  [paramSection addSwitchFieldForKeyPath:@"ServoCompInvert_ROLL"
                                   title:NSLocalizedString(@"Invert direction", @"MKParam Camera")
                                   style:[SettingsFieldStyleSwitch style]];

  [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
    builder.keyPath = @"ServoRollMin";
    builder.title = NSLocalizedString(@"Servo min", @"MKParam Camera");
    builder.minimumValue = 0;
    builder.maximumValue = 247;
    builder.formFieldStyle = [SettingsFieldStyleStepper style];
  }]];

  [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
    builder.keyPath = @"ServoRollMax";
    builder.title = NSLocalizedString(@"Servo max", @"MKParam Camera");
    builder.minimumValue = 0;
    builder.maximumValue = 247;
    builder.formFieldStyle = [SettingsFieldStyleStepper style];
  }]];

  if (revision >= 90) {
    [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
      builder.keyPath = @"ServoFilterRoll";
      builder.title = NSLocalizedString(@"Servo filter", @"MKParam Camera");
      builder.minimumValue = 0;
      builder.maximumValue = 25;
      builder.formFieldStyle = [SettingsFieldStyleStepper style];
      builder.displayValueTransformer = [ZeroOffTransformer instance];
    }]];
  }
}

- (void)initNickSection:(NSInteger)revision {
  IBAFormSection *paramSection = [self addSectionWithHeaderTitle:NSLocalizedString(@"Nick", @"MKParam Camera") footerTitle:nil];
  paramSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

  [paramSection addPotiFieldForKeyPath:@"ServoNickControl" title:NSLocalizedString(@"Servo control", @"MKParam Camera")];
  [paramSection addPotiFieldForKeyPath:@"ServoNickComp" title:NSLocalizedString(@"Compensation", @"MKParam Camera")];

  [paramSection addSwitchFieldForKeyPath:@"GlobalConfig3_CFG3_SERVO_NICK_COMP_OFF"
                                   title:NSLocalizedString(@"Compensation OFF", @"MKParam Camera")
                                   style:[SettingsFieldStyleSwitch style]];


  [paramSection addSwitchFieldForKeyPath:@"ServoCompInvert_NICK"
                                   title:NSLocalizedString(@"Invert direction", @"MKParam Camera")
                                   style:[SettingsFieldStyleSwitch style]];

  if (revision >= 92)
    [paramSection addSwitchFieldForKeyPath:@"ServoCompInvert_RELATIVE"
                                     title:NSLocalizedString(@"Servo relative", @"MKParam Camera")
                                     style:[SettingsFieldStyleSwitch style]];

  [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
    builder.keyPath = @"ServoNickMin";
    builder.title = NSLocalizedString(@"Servo min", @"MKParam Camera");
    builder.minimumValue = 0;
    builder.maximumValue = 247;
    builder.formFieldStyle = [SettingsFieldStyleStepper style];
  }]];

  [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
    builder.keyPath = @"ServoNickMax";
    builder.title = NSLocalizedString(@"Servo max", @"MKParam Camera");
    builder.minimumValue = 0;
    builder.maximumValue = 247;
    builder.formFieldStyle = [SettingsFieldStyleStepper style];
  }]];

  if (revision >= 90) {
    [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
      builder.keyPath = @"ServoFilterNick";
      builder.title = NSLocalizedString(@"Servo filter", @"MKParam Camera");
      builder.minimumValue = 0;
      builder.maximumValue = 25;
      builder.formFieldStyle = [SettingsFieldStyleStepper style];
      builder.displayValueTransformer = [ZeroOffTransformer instance];
    }]];
  }

}

- (void)initServoSection:(NSInteger)revision {
  IBAFormSection *paramSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
  paramSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

  [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
    builder.keyPath = @"ServoNickRefresh";
    builder.title = NSLocalizedString(@"Servo refresh rate", @"MKParam Camera");
    builder.minimumValue = 2;
    builder.maximumValue = 8;
    builder.formFieldStyle = [SettingsFieldStyleStepper style];
  }]];


  [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
    builder.keyPath = @"ServoManualControlSpeed";
    builder.title = NSLocalizedString(@"Manual control speed", @"MKParam Camera");
    builder.minimumValue = 0;
    builder.maximumValue = 247;
    builder.formFieldStyle = [SettingsFieldStyleStepper style];
  }]];

  [paramSection addPotiFieldWithOutForKeyPath:@"Servo3" title:NSLocalizedString(@"Servo 3", @"MKParam Camera")];

  [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
    builder.keyPath = @"Servo3OnValue";
    builder.title = NSLocalizedString(@"Servo3OnValue", @"MKParam Camera");
    builder.hidden=YES;
    builder.minimumValue = 0;
    builder.maximumValue = 247;
    builder.formFieldStyle = [SettingsFieldStyleStepper style];
  }]];

  [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
    builder.keyPath = @"Servo3OffValue";
    builder.title = NSLocalizedString(@"Servo3OffValue", @"MKParam Camera");
    builder.hidden=YES;
    builder.minimumValue = 0;
    builder.maximumValue = 247;
    builder.formFieldStyle = [SettingsFieldStyleStepper style];
  }]];

  [paramSection addPotiFieldWithOutForKeyPath:@"Servo4" title:NSLocalizedString(@"Servo 4", @"MKParam Camera")];

  [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
    builder.keyPath = @"Servo4OnValue";
    builder.title = NSLocalizedString(@"Servo4OnValue", @"MKParam Camera");
    builder.hidden=YES;
    builder.minimumValue = 0;
    builder.maximumValue = 247;
    builder.formFieldStyle = [SettingsFieldStyleStepper style];
  }]];

  [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
    builder.keyPath = @"Servo4OffValue";
    builder.title = NSLocalizedString(@"Servo4OffValue", @"MKParam Camera");
    builder.hidden=YES;
    builder.minimumValue = 0;
    builder.maximumValue = 247;
    builder.formFieldStyle = [SettingsFieldStyleStepper style];
  }]];


  [paramSection addPotiFieldForKeyPath:@"Servo5" title:NSLocalizedString(@"Servo 5", @"MKParam Camera")];
}

- (void)initOrientationSection:(NSInteger)revision {
  IBAFormSection *paramSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
  paramSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

  [paramSection addFormField:[IBAStepperFormField fieldWithBlock:^(IBAFormFieldBuilder *builder) {
    builder.keyPath = @"CamOrientation";
    builder.title = NSLocalizedString(@"CamOrientation", @"MKParam Camera");
    builder.minimumValue = 0;
    builder.maximumValue = 23;
    builder.displayValueTransformer = [OrientationTransformer instance];
    builder.formFieldStyle = [SettingsFieldStyleStepper style];
  }]];
}

- (void)updateFields {

  NSUInteger value3 = [[self modelValueForKeyPath:@"Servo3"] unsignedIntegerValue];
  BOOL hidden3 = (value3 != 246 && value3 != 247);
  NSUInteger value4 = [[self modelValueForKeyPath:@"Servo4"] unsignedIntegerValue];
  BOOL hidden4 = (value4 != 246 && value4 != 247);

  [self setFormFieldForKeyPath:@"Servo3OnValue" hidden:hidden3];
  [self setFormFieldForKeyPath:@"Servo3OffValue" hidden:hidden3];
  [self setFormFieldForKeyPath:@"Servo4OnValue" hidden:hidden4];
  [self setFormFieldForKeyPath:@"Servo4OffValue" hidden:hidden4];
}

- (void)setModelValue:(id)value forKeyPath:(NSString *)keyPath {
  [super setModelValue:value forKeyPath:keyPath];

  if ([keyPath isEqualToString:@"Servo3"] || [keyPath isEqualToString:@"Servo4"]) {
    [self updateFields];
  }

  NSLog(@"%@", [self.model description]);
}

@end
