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

#import "StringToNumberTransformer.h"

@implementation StringToNumberTransformer

+ (id)instance {
  return [[[self class] alloc] init];
}

+ (BOOL)allowsReverseTransformation {
  return YES;
}

+ (Class)transformedValueClass {
  return [NSNumber class];
}

- (NSNumber *)transformedValue:(NSString *)value {
  return [NSNumber numberWithInteger:[value integerValue]];
}

- (NSString *)reverseTransformedValue:(NSNumber *)value {
  return [value stringValue];
}

@end

@implementation StringToDoubleNumberTransformer

+ (id)instance {
  return [[[self class] alloc] init];
}

- (id)init {
  self = [super init];
  if (self) {
    formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:6];
    [formatter setMinimumFractionDigits:6];
  }
  return self;
}

+ (BOOL)allowsReverseTransformation {
  return YES;
}

+ (Class)transformedValueClass {
  return [NSNumber class];
}

- (NSNumber *)transformedValue:(NSString *)value {
  return [formatter numberFromString:value];
}

- (NSString *)reverseTransformedValue:(NSNumber *)value {
  return [formatter stringFromNumber:value];
}

@end

#pragma mark -

@interface IndexToStringTransformer ()

@property(strong) NSArray* strings;

@end

@implementation IndexToStringTransformer : NSValueTransformer

- (instancetype)initWithArray:(NSArray*)strings
{
  self = [super init];
  if (self) {
    self.strings=strings;
  }
  return self;
}

+ (BOOL)allowsReverseTransformation {
  return YES;
}

+ (Class)transformedValueClass {
  return [NSNumber class];
}

- (NSNumber *)transformedValue:(NSString *)value {
  
  return @([self.strings indexOfObject:value]);
}

- (NSString *)reverseTransformedValue:(NSNumber *)value {

  NSUInteger idx = [value unsignedIntegerValue];
  if(idx > [self.strings count]){
    return nil;
  }
  
  return self.strings[idx];
}

@end;
