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

#import <IBAForms/IBAFormConstants.h>
#import "SettingsFieldStyle.h"



@implementation SettingsFieldStyle
+ (id)style {
  return [[[self class] alloc] init];
}

- (id)init {
  self = [super init];
  if (self) {
    self.labelTextColor = [UIColor blackColor];
    if([UIFont respondsToSelector:@selector(preferredFontForTextStyle:)])
      self.labelFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    else
      self.labelFont = [UIFont boldSystemFontOfSize:18];
    
    self.labelTextAlignment = NSTextAlignmentLeft;
    self.labelFrame = CGRectMake(IBAFormFieldLabelX, 8, 190, IBAFormFieldLabelHeight);
    self.labelAutoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.valueTextAlignment = NSTextAlignmentLeft;
    self.valueTextColor = [UIColor colorWithRed:0.220 green:0.329 blue:0.529 alpha:1.0];
    if([UIFont respondsToSelector:@selector(preferredFontForTextStyle:)])
      self.labelFont = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    else
      self.valueFont = [UIFont boldSystemFontOfSize:16];
    self.valueFrame = CGRectMake(210, 13, 100, IBAFormFieldValueHeight);
    self.valueAutoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.activeColor = [UIColor whiteColor];
    
    //      self.labelBackgroundColor=[UIColor yellowColor];
    //      self.valueBackgroundColor=[UIColor greenColor];
    
  }
  return self;
}

@end


@implementation SettingsFieldStyleText

+ (id)style {
  return [[[self class] alloc] init];
}

- (id)init {
  self = [super init];
  if (self) {
    self.labelFrame = CGRectMake(IBAFormFieldLabelX, 8, 90, IBAFormFieldLabelHeight);

    self.valueFrame = CGRectMake(110, 13, 200, IBAFormFieldValueHeight);
  }
  return self;
}

@end

@implementation SettingsFieldStyleStepper
+ (id)style {
  static dispatch_once_t once;
	static SettingsFieldStyleStepper *shared_style;
	dispatch_once(&once, ^{
		shared_style = [[[self class] alloc] init];
	});
  
	return shared_style;
}

- (id)init {
  self = [super init];
  if (self) {
    self.labelFrame = CGRectMake(IBAFormFieldLabelX, 8, 150, IBAFormFieldLabelHeight);
    self.valueFrame = CGRectMake(210, 13, 100, IBAFormFieldValueHeight);
  }
  return self;
}

@end

@implementation SettingsFieldStyleSwitch
+ (id)style {
  return [[[self class] alloc] init];
}

- (id)init {
  self = [super init];
  if (self) {
    self.labelFrame = CGRectMake(IBAFormFieldLabelX, 8, 210, IBAFormFieldLabelHeight);

    self.valueFrame = CGRectMake(160, 13, 150, IBAFormFieldValueHeight);
  }
  return self;
}

@end
