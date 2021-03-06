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

#import <IBAForms/IBAForms.h>
#import "MKParamPotiValueTransformer.h"

@interface IBAFormSection (Creation)

- (IBAStepperFormField*)addStepperFieldForKeyPath:(NSString *)keyPath title:(NSString *)title;
- (IBAStepperFormField*)addStepperFieldForKeyPath:(NSString *)keyPath title:(NSString *)title displayValueTransformer:(NSValueTransformer*)displayValueTransformer;
- (IBATextFormField*)addNumberFieldForKeyPath:(NSString *)keyPath title:(NSString *)title;
- (void)addSwitchFieldForKeyPath:(NSString *)keyPath title:(NSString *)title;
- (void)addSwitchFieldForKeyPath:(NSString *)keyPath title:(NSString *)title style:(IBAFormFieldStyle *)style;
- (void)addTextFieldForKeyPath:(NSString *)keyPath title:(NSString *)title;
- (void)addPotiFieldForKeyPath:(NSString *)keyPath title:(NSString *)title;
- (void)addPotiFieldForKeyPath:(NSString *)keyPath title:(NSString *)title format:(NSString*) format;
- (void)addPotiFieldForKeyPath:(NSString *)keyPath title:(NSString *)title block:(MKParamPotiValueTransformerBlock) block;
- (void)addPotiFieldWithOutForKeyPath:(NSString *)keyPath title:(NSString *)title;

- (void)addChannelsForKeyPath:(NSString *)keyPath title:(NSString *)title;
- (void)addChannelsPlusForKeyPath:(NSString *)keyPath title:(NSString *)title;


@end
