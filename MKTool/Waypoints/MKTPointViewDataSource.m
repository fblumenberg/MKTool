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
#import "MKTPointViewDataSource.h"
#import "StringToNumberTransformer.h"
#import "SettingsFieldStyle.h"
#import "WPCamAngleTransformer.h"

#import "MKTPoint.h"

@interface MKTPointViewDataSource ()

@property(retain) NSArray *refreshProperties;

@end

@implementation MKTPointViewDataSource

@synthesize refreshProperties;

- (id)initWithModel:(id)aModel {
  if ((self = [super initWithModel:aModel])) {

    self.refreshProperties = [NSArray arrayWithObjects:@"latitude", @"longitude", @"type", @"heading", @"toleranceRadius", nil];

    IBATextFormField *numberField;
    IBAStepperFormField *stepperField;

    NSString *headerTitle = [self modelValueForKeyPath:@"name"];

    NSNumber *heading = [aModel valueForKeyPath:@"heading"];
    if ([heading integerValue] < 0) {
      headerTitle = [headerTitle stringByAppendingFormat:NSLocalizedString(@" - Distance to POI %d m", @"Point editor extra header"), (NSUInteger) [((MKTPoint *) aModel) distanceToPoi]];
    }

    IBAFormSection *positionSection = [self addSectionWithHeaderTitle:headerTitle footerTitle:nil];
    positionSection.formFieldStyle = [[SettingsFieldStyle alloc] init];
    //------------------------------------------------------------------------------------------------------------------------
    numberField = [[IBATextFormField alloc] initWithKeyPath:@"latitude"
                                                      title:NSLocalizedString(@"Lat.", @"WP Latitude title") valueTransformer:[StringToDoubleNumberTransformer instance]];

    [positionSection addFormField:numberField];
    numberField.textFormFieldCell.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    //------------------------------------------------------------------------------------------------------------------------
    numberField = [[IBATextFormField alloc] initWithKeyPath:@"longitude"
                                                      title:NSLocalizedString(@"Long.", @"WP Longitude title") valueTransformer:[StringToDoubleNumberTransformer instance]];

    [positionSection addFormField:numberField];
    numberField.textFormFieldCell.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;

    ////////////////////////////////////////////////////////////////////////////////////////////////////

    IBAFormSection *attributeSection = [self addSectionWithHeaderTitle:nil footerTitle:nil];
    attributeSection.formFieldStyle = [[SettingsFieldStyleStepper alloc] init];
    //------------------------------------------------------------------------------------------------------------------------

    NSArray *pickListOptions = [IBAPickListFormOption pickListOptionsForStrings:[NSArray arrayWithObjects:NSLocalizedString(@"Waypoint", nil),
                                                                                                          NSLocalizedString(@"POI", nil), nil]
                                                                           font:[UIFont boldSystemFontOfSize:18]];

    IBASingleIndexTransformer *singleTransformer = [[IBASingleIndexTransformer alloc] initWithPickListOptions:pickListOptions];

    [attributeSection addFormField:[[IBAPickListFormField alloc] initWithKeyPath:@"type"
                                                                           title:NSLocalizedString(@"Type", @"type title") valueTransformer:singleTransformer
                                                                   selectionMode:IBAPickListSelectionModeSingle
                                                                         options:pickListOptions]];
    //------------------------------------------------------------------------------------------------------------------------
    stepperField = [[IBAStepperFormField alloc] initWithKeyPath:@"altitude"
                                                          title:NSLocalizedString(@"Altitude", @"WP Altitude title") valueTransformer:nil];

    stepperField.maximumValue = 500;
    stepperField.minimumValue = 0;

    [attributeSection addFormField:stepperField];
    //------------------------------------------------------------------------------------------------------------------------
    stepperField = [[IBAStepperFormField alloc] initWithKeyPath:@"heading"
                                                          title:NSLocalizedString(@"Heading", @"WP Heading title") valueTransformer:nil];

    stepperField.maximumValue = 360;
    stepperField.minimumValue = -100;

    [attributeSection addFormField:stepperField];
    //------------------------------------------------------------------------------------------------------------------------
    stepperField = [[IBAStepperFormField alloc] initWithKeyPath:@"toleranceRadius"
                                                          title:NSLocalizedString(@"Radius", @"WP toleranceRadius title") valueTransformer:nil];

    stepperField.maximumValue = 100;
    stepperField.minimumValue = 0;

    [attributeSection addFormField:stepperField];
    //------------------------------------------------------------------------------------------------------------------------
    stepperField = [[IBAStepperFormField alloc] initWithKeyPath:@"holdTime"
                                                          title:NSLocalizedString(@"HaltTime", @"WP holdTime title") valueTransformer:nil];

    stepperField.maximumValue = 3600;
    stepperField.minimumValue = 0;

    [attributeSection addFormField:stepperField];
    //------------------------------------------------------------------------------------------------------------------------
    stepperField = [[IBAStepperFormField alloc] initWithKeyPath:@"eventChannelValue"
                                                          title:NSLocalizedString(@"Event", @"WP event title") valueTransformer:nil];

    stepperField.maximumValue = 255;
    stepperField.minimumValue = 0;

    [attributeSection addFormField:stepperField];
    //------------------------------------------------------------------------------------------------------------------------
    stepperField = [[IBAStepperFormField alloc] initWithKeyPath:@"altitudeRate"
                                                          title:NSLocalizedString(@"Climb rate", @"WP event title") valueTransformer:nil];

    stepperField.maximumValue = 255;
    stepperField.minimumValue = 0;

    [attributeSection addFormField:stepperField];
    //------------------------------------------------------------------------------------------------------------------------
    stepperField = [[IBAStepperFormField alloc] initWithKeyPath:@"speed"
                                                          title:NSLocalizedString(@"Speed", @"WP event title") valueTransformer:nil];

    stepperField.maximumValue = 255;
    stepperField.minimumValue = 0;

    [attributeSection addFormField:stepperField];
    //------------------------------------------------------------------------------------------------------------------------
    stepperField = [[IBAStepperFormField alloc] initWithKeyPath:@"cameraAngle"
                                                          title:NSLocalizedString(@"Camera nick angle", @"WP event title") valueTransformer:nil];

    stepperField.displayValueTransformer = [WPCamAngleTransformer instance];
    stepperField.maximumValue = 254;
    stepperField.minimumValue = -1;

    [attributeSection addFormField:stepperField];

  }
  return self;
}

- (void)dealloc {
  self.refreshProperties = nil;
}

- (void)sendChange {
//  [Route sendChangedNotification:self];
}

- (void)setModelValue:(id)value forKeyPath:(NSString *)keyPath {
  [super setModelValue:value forKeyPath:keyPath];

  NSLog(@"%@", [self.model description]);

  if ([self.refreshProperties containsObject:keyPath]) {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(sendChange) withObject:self afterDelay:0.6];
  }
//    [Route sendChangedNotification:self];
}


@end
