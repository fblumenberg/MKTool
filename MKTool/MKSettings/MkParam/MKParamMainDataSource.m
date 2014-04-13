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

#import "BlocksKit/NSArray+BlocksKit.h"

#import "MGSplitViewController.h"
#import "MKParamMainDataSource.h"

#import "MKParamViewController.h"

#import "MKParamAltitudeDataSource.h"
#import "MKParamEasySetupDataSource.h"
#import "MKParamCameraDataSource.h"
#import "MKParamChannelsDataSource.h"
#import "MKParamCompassDataSource.h"
#import "MKParamCouplingDataSource.h"
#import "MKParamGyroDataSource.h"
#import "MKParamLoopingDataSource.h"
#import "MKParamMiscDataSource.h"
#import "MKParamNaviControlDataSource.h"
#import "MKParamOutputDataSource.h"
#import "MKParamStickDataSource.h"
#import "MKParamUserDataSource.h"


#import "StringToNumberTransformer.h"
#import "SettingsFieldStyle.h"
#import "SettingsButtonStyle.h"


@interface MKParamMainDataSource ()

@property(assign) BOOL expertMode;

- (void)showDetailViewForKey:(Class)nsclass withTitle:(NSString *)title;

@end

@implementation MKParamMainDataSource

- (id)initWithModel:(id)aModel {
  self = [super initWithModel:aModel];
  if (self) {

    self.expertMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"MKParamsExpertMode"];


    // Some basic form fields that accept text input
    IBAFormSection *basicFieldSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
    basicFieldSection.formFieldStyle = [[SettingsFieldStyle alloc] init];

    [basicFieldSection addFormField:[[IBATextFormField alloc] initWithKeyPath:@"Name" title:NSLocalizedString(@"Name", @"MKParam Name")]];
    [basicFieldSection addFormField:[[IBABooleanFormField alloc] initWithKeyPath:@"expertMode" title:NSLocalizedString(@"Expert mode", @"MKParam Main")]];

    //------------------------------------------------------------------------------------------------------------------------

    IBAFormSection *buttonsSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
    buttonsSection.formFieldStyle = [[SettingsButtonIndicatorStyle alloc] init];

    [buttonsSection addFormField:[[IBAButtonFormField alloc] initWithTitle:NSLocalizedString(@"Easy Setup", @"MKParam Easy Setup button") icon:nil executionBlock:^{
      [self showDetailViewForKey:[MKParamEasySetupDataSource class]
                       withTitle:NSLocalizedString(@"Easy Setup", @"MKParam Easy Setup button")];
    }]].keyPath = @"easySetup";
    [buttonsSection addFormField:[[IBAButtonFormField alloc] initWithTitle:NSLocalizedString(@"Channels", @"MKParam Channels button") icon:nil executionBlock:^{
      [self showDetailViewForKey:[MKParamChannelsDataSource class]
                       withTitle:NSLocalizedString(@"Channels", @"MKParam Channels button")];
    }]].keyPath = @"channels";
    [buttonsSection addFormField:[[IBAButtonFormField alloc] initWithTitle:NSLocalizedString(@"Compass", @"MKParam Compass button") icon:nil executionBlock:^{
      [self showDetailViewForKey:[MKParamCompassDataSource class]
                       withTitle:NSLocalizedString(@"Compass", @"MKParam Compass button")];
    }]].keyPath = @"compass";
    [buttonsSection addFormField:[[IBAButtonFormField alloc] initWithTitle:NSLocalizedString(@"Navi Control", @"MKParam Navi Control button") icon:nil executionBlock:^{
      [self showDetailViewForKey:[MKParamNaviControlDataSource class]
                       withTitle:NSLocalizedString(@"Navi Control", @"MKParam Navi Control button")];
    }]].keyPath = @"naviCtrl";
    [buttonsSection addFormField:[[IBAButtonFormField alloc] initWithTitle:NSLocalizedString(@"Stick", @"MKParam Stick button") icon:nil executionBlock:^{
      [self showDetailViewForKey:[MKParamStickDataSource class]
                       withTitle:NSLocalizedString(@"Stick", @"MKParam Stick button")];
    }]].keyPath = @"stick";
    [buttonsSection addFormField:[[IBAButtonFormField alloc] initWithTitle:NSLocalizedString(@"Altitude control", @"MKParam Altitude button") icon:nil executionBlock:^{
      [self showDetailViewForKey:[MKParamAltitudeDataSource class]
                       withTitle:NSLocalizedString(@"Altitude control", @"MKParam Altitude button")];
    }]].keyPath = @"altitude";
    [buttonsSection addFormField:[[IBAButtonFormField alloc] initWithTitle:NSLocalizedString(@"Camera", @"MKParam Camera button") icon:nil executionBlock:^{
      [self showDetailViewForKey:[MKParamCameraDataSource class]
                       withTitle:NSLocalizedString(@"Camera", @"MKParam Camera button")];
    }]].keyPath = @"camera";
    [buttonsSection addFormField:[[IBAButtonFormField alloc] initWithTitle:NSLocalizedString(@"Gyro", @"MKParam Gyro button") icon:nil executionBlock:^{
      [self showDetailViewForKey:[MKParamGyroDataSource class]
                       withTitle:NSLocalizedString(@"Gyro", @"MKParam Gyro button")];
    }]].keyPath = @"gyro";
    [buttonsSection addFormField:[[IBAButtonFormField alloc] initWithTitle:NSLocalizedString(@"Coupling", @"MKParam Coupling button") icon:nil executionBlock:^{
      [self showDetailViewForKey:[MKParamCouplingDataSource class]
                       withTitle:NSLocalizedString(@"Coupling", @"MKParam Coupling button")];
    }]].keyPath = @"coupling";
    [buttonsSection addFormField:[[IBAButtonFormField alloc] initWithTitle:NSLocalizedString(@"Looping", @"MKParam Looping button") icon:nil executionBlock:^{
      [self showDetailViewForKey:[MKParamLoopingDataSource class]
                       withTitle:NSLocalizedString(@"Looping", @"MKParam Looping button")];
    }]].keyPath = @"looping";
    [buttonsSection addFormField:[[IBAButtonFormField alloc] initWithTitle:NSLocalizedString(@"Output", @"MKParam Output button") icon:nil executionBlock:^{
      [self showDetailViewForKey:[MKParamOutputDataSource class]
                       withTitle:NSLocalizedString(@"Output", @"MKParam Output button")];
    }]].keyPath = @"output";
    [buttonsSection addFormField:[[IBAButtonFormField alloc] initWithTitle:NSLocalizedString(@"Misc", @"MKParam Misc button") icon:nil executionBlock:^{
      [self showDetailViewForKey:[MKParamMiscDataSource class]
                       withTitle:NSLocalizedString(@"Misc", @"MKParam Misc button")];
    }]].keyPath = @"misc";
    [buttonsSection addFormField:[[IBAButtonFormField alloc] initWithTitle:NSLocalizedString(@"User", @"MKParam User button") icon:nil executionBlock:^{
      [self showDetailViewForKey:[MKParamUserDataSource class]
                       withTitle:NSLocalizedString(@"User", @"MKParam User button")];
    }]].keyPath = @"user";

    [self updateButtons];
  }

  return self;
}

- (void)updateButtons {

  NSArray *fields = @[
      @"easySetup",
      @"channels",
      @"compass",
      @"naviCtrl",
      @"stick",
      @"altitude",
      @"camera",
      @"gyro",
      @"coupling",
      @"looping",
      @"output",
      @"misc",
      @"user"
  ];


  if (self.expertMode) {
    [fields bk_each:^(id obj) {
      IBAFormField *f = [self formFieldForKeyPath:obj];
      f.hidden = NO;
    }];
  }
  else {
    NSArray *fieldsVisible = @[
        @"easySetup",
        @"channels",
        @"camera",
        @"output"
    ];

    [fields bk_each:^(id obj) {
      IBAFormField *f = [self formFieldForKeyPath:obj];
      f.hidden = YES;
    }];

    [fieldsVisible bk_each:^(id obj) {
      IBAFormField *f = [self formFieldForKeyPath:obj];
      f.hidden = NO;
    }];
  }

  [self.delegate updateSection:1 animated:true];

}

- (void)showDetailViewForKey:(Class)nsclass withTitle:(NSString *)title {

  IBAFormDataSource *dataSource = [[nsclass alloc] initWithModel:self.model];

  MKParamViewController *settingsFormController = [[MKParamViewController alloc] initWithNibName:nil bundle:nil formDataSource:dataSource];
  settingsFormController.title = title;

  [[IBAInputManager sharedIBAInputManager] setInputNavigationToolbarEnabled:YES];

  UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];

  if ([rootViewController isKindOfClass:[UINavigationController class]]) {
    [(UINavigationController *) rootViewController pushViewController:settingsFormController animated:YES];
  }
  else if ([rootViewController isKindOfClass:[MGSplitViewController class]]) {

    MGSplitViewController *splitViewController = (MGSplitViewController *) rootViewController;

    UIViewController *controller = splitViewController.detailViewController;
    if ([controller isKindOfClass:[UINavigationController class]]) {
      controller.navigationItem.hidesBackButton = YES;

      [(UINavigationController *) controller popToRootViewControllerAnimated:NO];
      [(UINavigationController *) controller pushViewController:settingsFormController animated:YES];
    }
  }
}

- (id)modelValueForKeyPath:(NSString *)keyPath {
  if ([keyPath isEqualToString:@"expertMode"]) {
    return [self valueForKeyPath:keyPath];
  }

  return [super modelValueForKeyPath:keyPath];
}

- (void)setModelValue:(id)value forKeyPath:(NSString *)keyPath {
  if ([keyPath isEqualToString:@"expertMode"]) {
    [self setValue:value forKeyPath:keyPath];
    [[NSUserDefaults standardUserDefaults] setBool:[value boolValue] forKey:@"MKParamsExpertMode"];
    [self updateButtons];
  }
  else
    [super setModelValue:value forKeyPath:keyPath];

  NSLog(@"%@", [self.model description]);
}

@end
