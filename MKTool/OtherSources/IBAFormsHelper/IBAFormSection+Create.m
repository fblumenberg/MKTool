// ///////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2012, Frank Blumenberg
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

#import "IBAFormSection+Create.h"
#import "StringToNumberTransformer.h"
#import "MKParamPotiValueTransformer.h"

@implementation IBAFormSection (Creation)

- (IBAStepperFormField*)addStepperFieldForKeyPath:(NSString *)keyPath title:(NSString *)title {
  return [self addStepperFieldForKeyPath:keyPath title:title displayValueTransformer:nil];
}

- (IBAStepperFormField*)addStepperFieldForKeyPath:(NSString *)keyPath title:(NSString *)title displayValueTransformer:(NSValueTransformer*)displayValueTransformer{
  IBAStepperFormField *stepperField;
  stepperField = [[IBAStepperFormField alloc] initWithKeyPath:keyPath
                                                        title:title
                                             valueTransformer:nil];
  
  stepperField.displayValueTransformer = displayValueTransformer;
  [self addFormField:stepperField];
  return stepperField;
}


- (IBATextFormField*)addNumberFieldForKeyPath:(NSString *)keyPath title:(NSString *)title {

  IBATextFormField *numberField;
  numberField = [[IBATextFormField alloc] initWithKeyPath:keyPath
                                                    title:title
                                         valueTransformer:[StringToNumberTransformer instance]];
  [self addFormField:numberField];
  numberField.textFormFieldCell.textField.keyboardType = UIKeyboardTypeNumberPad;
  return numberField;
}

- (void)addSwitchFieldForKeyPath:(NSString *)keyPath title:(NSString *)title {
  [self addSwitchFieldForKeyPath:keyPath title:title style:nil];
}

- (void)addSwitchFieldForKeyPath:(NSString *)keyPath title:(NSString *)title style:(IBAFormFieldStyle *)style {
  IBABooleanFormField *f = [[IBABooleanFormField alloc] initWithKeyPath:keyPath title:title];
  if (style) {
    f.formFieldStyle = style;
  }
  [self addFormField:f];
}

- (void)addTextFieldForKeyPath:(NSString *)keyPath title:(NSString *)title {

  [self addFormField:[[IBATextFormField alloc] initWithKeyPath:keyPath title:title]];
}

- (void)addPotiFieldWithOutForKeyPath:(NSString *)keyPath title:(NSString *)title {
  
  MKParamPotiValueTransformer *potiTransformer = nil;
  potiTransformer = [MKParamPotiValueTransformer transformerWithOut];
  [self addFormField:[[IBAPickListFormField alloc] initWithKeyPath:keyPath
                                                              title:title
                                                   valueTransformer:potiTransformer
                                                      selectionMode:IBAPickListSelectionModeSingle
                                                            options:potiTransformer.pickListOptions]];
  
}

- (void)addPotiFieldForKeyPath:(NSString *)keyPath title:(NSString *)title {

  MKParamPotiValueTransformer *potiTransformer = nil;
  potiTransformer = [MKParamPotiValueTransformer transformer];
  [self addFormField:[[IBAPickListFormField alloc] initWithKeyPath:keyPath
                                                              title:title
                                                   valueTransformer:potiTransformer
                                                      selectionMode:IBAPickListSelectionModeSingle
                                                            options:potiTransformer.pickListOptions]];

}


- (void)addChannelsForKeyPath:(NSString *)keyPath title:(NSString *)title {

  NSMutableArray *values = [NSMutableArray arrayWithCapacity:12];
  for (int i = 0; i < 16; i++)
    [values addObject:[NSString stringWithFormat:NSLocalizedString(@"RC Channel %d", @"RC-Channel"), i + 1]];

  NSArray *pickListOptions = [IBAPickListFormOption pickListOptionsForStrings:values];

  IBASingleIndexTransformer *transformer = [[IBASingleIndexTransformer alloc] initWithPickListOptions:pickListOptions];

  [self addFormField:[[IBAPickListFormField alloc] initWithKeyPath:keyPath
                                                              title:title
                                                   valueTransformer:transformer
                                                      selectionMode:IBAPickListSelectionModeSingle
                                                            options:pickListOptions]];
}

- (void)addChannelsPlusForKeyPath:(NSString *)keyPath title:(NSString *)title {

  NSMutableArray *values = [NSMutableArray arrayWithCapacity:25];
  [values addObject:NSLocalizedString(@"Off", @"RC-Channel")];
  for (int i = 0; i < 16; i++)
    [values addObject:[NSString stringWithFormat:NSLocalizedString(@"RC Channel %d", @"RC-Channel"), i + 1]];

  for (int i = 0; i < 12; i++)
    [values addObject:[NSString stringWithFormat:NSLocalizedString(@"Serial Channel %d", @"RC-Channel"), i + 1]];

  [values addObject:NSLocalizedString(@"WP Event Channel", @"RC-Channel")];
  [values addObject:NSLocalizedString(@"Maximum", @"RC-Channel")];
  [values addObject:NSLocalizedString(@"Middle", @"RC-Channel")];
  [values addObject:NSLocalizedString(@"Minimum", @"RC-Channel")];

  NSArray *pickListOptions = [IBAPickListFormOption pickListOptionsForStrings:values];

  IBASingleIndexTransformer *transformer = [[IBASingleIndexTransformer alloc] initWithPickListOptions:pickListOptions];

  [self addFormField:[[IBAPickListFormField alloc] initWithKeyPath:keyPath
                                                              title:title
                                                   valueTransformer:transformer
                                                      selectionMode:IBAPickListSelectionModeSingle
                                                            options:pickListOptions]];
}

@end
