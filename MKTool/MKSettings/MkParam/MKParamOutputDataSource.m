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
#import "MKParamOutputDataSource.h"

#import "MKParamMainController.h"
#import "IBAFormSection+Create.h"
#import "IKOutputFormField.h"

#import "StringToNumberTransformer.h"
#import "SettingsFieldStyle.h"
#import "SettingsButtonStyle.h"

@implementation MKParamOutputDataSource

- (id)initWithModel:(id)aModel {
  self = [super initWithModel:aModel];
  if (self) {
    
    NSInteger revision =((IKParamSet *) aModel).Revision.integerValue;

    IBAFormSection *paramSection = nil;
    //------------------------------------------------------------------------------------------------------------------------
    paramSection = [self addSectionWithHeaderTitle:NSLocalizedString(@"Output 1 (J16 / SV2.1)", @"MKParam Output") footerTitle:nil];
    paramSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

    [paramSection addFormField:[[IKOutputFormField alloc] initWithKeyPath:@"J16Bitmask"
                                                                    title:NSLocalizedString(@"Bitmask", @"MKParam Output")
                                                                 showIdle:YES]];

    [paramSection addPotiFieldForKeyPath:@"J16Timing" title:NSLocalizedString(@"Timing", @"MKParam Output") block:^NSString *(NSInteger value) {
      return [NSString stringWithFormat:@"%ld ms",(long)value*10];
    }];
    
    [paramSection addSwitchFieldForKeyPath:@"BitConfig_MOTOR_BLINK1" title:NSLocalizedString(@"Active after Motor start", @"MKParam Output") style:[SettingsFieldStyleSwitch style]];
    [paramSection addSwitchFieldForKeyPath:@"BitConfig_MOTOR_OFF_LED1" title:NSLocalizedString(@"Motor off, LED level", @"MKParam Output") style:[SettingsFieldStyleSwitch style]];
    
    if (revision >= 92) {
      [paramSection addSwitchFieldForKeyPath:@"GlobalConfig3_CFG3_USE_NC_FOR_OUT1"
                                       title:NSLocalizedString(@"Combine with WP-Event", @"MKParam Output")
                                       style:[SettingsFieldStyleSwitch style]];
      
      [paramSection addPotiFieldForKeyPath:@"AutoPhotoDistance"
                                     title:NSLocalizedString(@"(Distance) AutoTrigger every", @"MKParam Output")
                                    format:@"%d m"];
    }
    
    if(revision >= 100){
      [paramSection addPotiFieldForKeyPath:@"AutoPhotoAtitudes"
                                     title:NSLocalizedString(@"(Height) AutoTrigger every", @"MKParam Output")
                                    format:@"%d m"];
    }

    //------------------------------------------------------------------------------------------------------------------------
    paramSection = [self addSectionWithHeaderTitle:NSLocalizedString(@"Output 2 (J17 / SV2.5)", @"MKParam Output") footerTitle:nil];
    paramSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

    [paramSection addFormField:[[IKOutputFormField alloc] initWithKeyPath:@"J17Bitmask"
                                                                    title:NSLocalizedString(@"Bitmask", @"MKParam Output")
                                                                 showIdle:YES]];
    
    [paramSection addPotiFieldForKeyPath:@"J17Timing" title:NSLocalizedString(@"Timing", @"MKParam Output") block:^NSString *(NSInteger value) {
      return [NSString stringWithFormat:@"%ld ms",(long)value*10];
    }];

    [paramSection addSwitchFieldForKeyPath:@"BitConfig_MOTOR_BLINK2" title:NSLocalizedString(@"Active after Motor start", @"MKParam Output") style:[SettingsFieldStyleSwitch style]];
    [paramSection addSwitchFieldForKeyPath:@"BitConfig_MOTOR_OFF_LED2" title:NSLocalizedString(@"Motor off, LED level", @"MKParam Output") style:[SettingsFieldStyleSwitch style]];


    //------------------------------------------------------------------------------------------------------------------------
    paramSection = [self addSectionWithHeaderTitle:NSLocalizedString(@"Untervoltage warning", @"MKParam Output") footerTitle:nil];
    paramSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

    [paramSection addFormField:[[IKOutputFormField alloc] initWithKeyPath:@"WARN_J16_Bitmask"
                                                                    title:NSLocalizedString(@"Bitmask Output 1", @"MKParam Output")]];
    
    [paramSection addFormField:[[IKOutputFormField alloc] initWithKeyPath:@"WARN_J17_Bitmask"
                                                                    title:NSLocalizedString(@"Bitmask Output 2", @"MKParam Output")]];
}

  return self;
}


- (void)setModelValue:(id)value forKeyPath:(NSString *)keyPath {
  [super setModelValue:value forKeyPath:keyPath];

  NSLog(@"%@", [self.model description]);
}

@end
