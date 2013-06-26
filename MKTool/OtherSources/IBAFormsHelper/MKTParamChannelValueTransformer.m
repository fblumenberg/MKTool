// ///////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013, Frank Blumenberg
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

#import "MKTParamChannelValueTransformer.h"

@implementation MKTParamChannelValueTransformer{
  NSDictionary* _converter;
}

+ (id)instance {
  return [[[self class] alloc] init];
}

+ (BOOL)allowsReverseTransformation {
  return NO;
}

+ (Class)transformedValueClass {
  return [NSString class];
}

- (id)init
{
  self = [super init];
  if (self) {
    _converter = @{
                   @0:NSLocalizedString(@"Inactive", @"Channels transformer"),
                   @1:NSLocalizedString(@"Ch. 1", @"Channels transformer"),
                   @2:NSLocalizedString(@"Ch. 2", @"Channels transformer"),
                   @3:NSLocalizedString(@"Ch. 3", @"Channels transformer"),
                   @4:NSLocalizedString(@"Ch. 4", @"Channels transformer"),
                   @5:NSLocalizedString(@"Ch. 5", @"Channels transformer"),
                   @6:NSLocalizedString(@"Ch. 6", @"Channels transformer"),
                   @7:NSLocalizedString(@"Ch. 7", @"Channels transformer"),
                   @8:NSLocalizedString(@"Ch. 8", @"Channels transformer"),
                   @9:NSLocalizedString(@"Ch. 9", @"Channels transformer"),
                   @10:NSLocalizedString(@"Ch. 10", @"Channels transformer"),
                   @11:NSLocalizedString(@"Ch. 11", @"Channels transformer"),
                   @12:NSLocalizedString(@"Ch. 12", @"Channels transformer"),
                   @13:NSLocalizedString(@"Ch. 13", @"Channels transformer"),
                   @14:NSLocalizedString(@"Ch. 14", @"Channels transformer"),
                   @15:NSLocalizedString(@"Ch. 15", @"Channels transformer"),
                   @16:NSLocalizedString(@"Ch. 16", @"Channels transformer"),
                   @17:NSLocalizedString(@"Ser. Ch. 1", @"Channels transformer"),
                   @18:NSLocalizedString(@"Ser. Ch. 2", @"Channels transformer"),
                   @19:NSLocalizedString(@"Ser. Ch. 3", @"Channels transformer"),
                   @20:NSLocalizedString(@"Ser. Ch. 4", @"Channels transformer"),
                   @21:NSLocalizedString(@"Ser. Ch. 5", @"Channels transformer"),
                   @22:NSLocalizedString(@"Ser. Ch. 6", @"Channels transformer"),
                   @23:NSLocalizedString(@"Ser. Ch. 7", @"Channels transformer"),
                   @24:NSLocalizedString(@"Ser. Ch. 8", @"Channels transformer"),
                   @25:NSLocalizedString(@"Ser. Ch. 9", @"Channels transformer"),
                   @26:NSLocalizedString(@"Ser. Ch. 10", @"Channels transformer"),
                   @27:NSLocalizedString(@"Ser. Ch. 11", @"Channels transformer"),
                   @28:NSLocalizedString(@"Ser. Ch. 12", @"Channels transformer"),
                   @29:NSLocalizedString(@"WP-Event", @"Channels transformer"),
                   @30:NSLocalizedString(@"-127", @"Channels transformer"),
                   @31:NSLocalizedString(@"0", @"Channels transformer"),
                   @32:NSLocalizedString(@"128", @"Channels transformer")
                   };
  }
  return self;
}

- (NSString *)transformedValue:(NSNumber *)value {
  
  if ([value integerValue] < 0)
    return NSLocalizedString(@"Ch. ", @"Channels transformer");
  
  return _converter[value];
}

@end
