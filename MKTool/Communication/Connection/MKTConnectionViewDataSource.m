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
#import "IBAFormSection+Create.h"
#import "MKTConnectionViewDataSource.h"
#import "StringToNumberTransformer.h"
#import "MKTConnectionTypeTransformer.h"

#import "SettingsFieldStyle.h"


@implementation MKTConnectionViewDataSource

- (id)initWithModel:(id)aModel {
  if ((self = [super initWithModel:aModel])) {

    IBAFormSection *hostSection = [self addSectionWithHeaderTitle:nil footerTitle:NSLocalizedString(@"WLAN - Hostname:Port", @"MKTConnection footer")];
    hostSection.formFieldStyle = [[SettingsFieldStyleText alloc] init];

    [self updateHostSection];
  }
  return self;
}

- (void)updateHostSection {

  IBAFormSection *hostSection = [self.sections objectAtIndex:0];

  [hostSection.formFields removeAllObjects];

  //------------------------------------------------------------------------------------------------------------------------
  [hostSection addFormField:[[IBATextFormField alloc] initWithKeyPath:@"name" title:NSLocalizedString(@"Name", @"Host name")]];

  MKTConnectionTypeTransformer *hostTransformer = [MKTConnectionTypeTransformer instance];

  [hostSection addFormField:[[IBAPickListFormField alloc] initWithKeyPath:@"connectionClass"
                                                                    title:NSLocalizedString(@"Type", @"Host type") valueTransformer:hostTransformer
                                                            selectionMode:IBAPickListSelectionModeSingle
                                                                  options:hostTransformer.pickListOptions]];

  NSString *connectionClass = [self modelValueForKeyPath:@"connectionClass"];

  if ([connectionClass isEqualToString:@"MKFakeConnection"] == NO)
    [hostSection addFormField:[[IBATextFormField alloc] initWithKeyPath:@"address" title:NSLocalizedString(@"Address", @"Host address")]];

  [hostSection addFormField:[[IBATextFormField alloc] initWithKeyPath:@"connectionData" title:NSLocalizedString(@"Pin", @"Host pin")]];
}

- (void)setModelValue:(id)value forKeyPath:(NSString *)keyPath {
  [super setModelValue:value forKeyPath:keyPath];
}


@end
