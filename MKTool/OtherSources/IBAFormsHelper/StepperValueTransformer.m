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


#import "StepperValueTransformer.h"

@implementation AngleTransformer

+ (id)instance {
  return [[[self class] alloc] init];
}

+ (BOOL)allowsReverseTransformation {
  return NO;
}

+ (Class)transformedValueClass {
  return [NSString class];
}

- (NSString *)transformedValue:(NSNumber *)value {
  
  return [NSString stringWithFormat:@"%@ °",value];
}

@end

@implementation TimeTransformer

+ (id)instance {
  return [[[self class] alloc] init];
}

+ (BOOL)allowsReverseTransformation {
  return NO;
}

+ (Class)transformedValueClass {
  return [NSString class];
}

- (NSString *)transformedValue:(NSNumber *)value {
  
  if ([value integerValue] < 1)
    return NSLocalizedString(@"Inactive", @"RadiusTransformer");
  
  return [NSString stringWithFormat:@"%@ s",value];
}

@end

@implementation SecondTransformer

+ (id)instance {
  return [[[self class] alloc] init];
}

+ (BOOL)allowsReverseTransformation {
  return NO;
}

+ (Class)transformedValueClass {
  return [NSString class];
}

- (NSString *)transformedValue:(NSNumber *)value {
  
  if ([value integerValue] < 1)
    return NSLocalizedString(@"Inactive", @"RadiusTransformer");
  
  return [NSString stringWithFormat:@"%@ s",value];
}

@end

@implementation RadiusTransformer

+ (id)instance {
  return [[[self class] alloc] init];
}

+ (BOOL)allowsReverseTransformation {
  return NO;
}

+ (Class)transformedValueClass {
  return [NSString class];
}

- (NSString *)transformedValue:(NSNumber *)value {

  if ([value integerValue] < 1)
    return NSLocalizedString(@"Inactive", @"RadiusTransformer");

  return [NSString stringWithFormat:@"%d m",[value unsignedIntegerValue]*10 ];
}

@end

@implementation LandingSpeedTransformer

+ (id)instance {
  return [[[self class] alloc] init];
}

+ (BOOL)allowsReverseTransformation {
  return NO;
}

+ (Class)transformedValueClass {
  return [NSString class];
}

- (NSString *)transformedValue:(NSNumber *)value {
  
  return [NSString stringWithFormat:@"%.1f m/s",[value floatValue]/10.0 ];
}

@end

@implementation VoltageTransformer

+ (id)instance {
  return [[[self class] alloc] init];
}

+ (BOOL)allowsReverseTransformation {
  return NO;
}

+ (Class)transformedValueClass {
  return [NSString class];
}

- (NSString *)transformedValue:(NSNumber *)value {
  
  return [NSString stringWithFormat:@"%.1f V",[value floatValue]/10.0 ];
}

@end

@implementation TenthSecondTransformer

+ (id)instance {
  return [[[self class] alloc] init];
}

+ (BOOL)allowsReverseTransformation {
  return NO;
}

+ (Class)transformedValueClass {
  return [NSString class];
}

- (NSString *)transformedValue:(NSNumber *)value {
  
  return [NSString stringWithFormat:@"%.1f s",[value floatValue]/10.0 ];
}

@end


@implementation CHAltitudeTransformer

+ (id)instance {
  return [[[self class] alloc] init];
}

+ (BOOL)allowsReverseTransformation {
  return NO;
}

+ (Class)transformedValueClass {
  return [NSString class];
}

- (NSString *)transformedValue:(NSNumber *)value {

  if ([value integerValue] < 1)
    return NSLocalizedString(@"OFF", @"CHAltitudeTransformer");

  return [NSString stringWithFormat:@"%@ m",value];
}

@end

@implementation OrientationTransformer

+ (id)instance {
  return [[[self class] alloc] init];
}

+ (BOOL)allowsReverseTransformation {
  return NO;
}

+ (Class)transformedValueClass {
  return [NSString class];
}

- (NSString *)transformedValue:(NSNumber *)value {
  
  return [NSString stringWithFormat:@"%d °",[value integerValue]*15];
}

@end

@implementation ZeroOffTransformer

+ (id)instance {
  return [[[self class] alloc] init];
}

+ (BOOL)allowsReverseTransformation {
  return NO;
}

+ (Class)transformedValueClass {
  return [NSString class];
}

- (NSString *)transformedValue:(NSNumber *)value {
  
  if ([value integerValue] < 1)
    return NSLocalizedString(@"OFF", @"CHAltitudeTransformer");
  
  return [NSString stringWithFormat:@"%@",value];
}

@end
