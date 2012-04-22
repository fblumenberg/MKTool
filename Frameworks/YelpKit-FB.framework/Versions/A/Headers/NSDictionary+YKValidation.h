//
//  NSDictionary+YKValidation.h
//  YelpKit
//
//  Created by John Boiles on 4/18/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

/*!
 Methods for reading and validating data from an NSDictionary. These methods raise YKValidationError if they fail validation. This is useful for safely reading data that has been parsed into NSObjects from format such as JSON or XML.
 */
@interface NSDictionary (YKValidation)

/*!
 Get object for key.

 @param key Key
 @result object
 */
- (id)yk_objectMaybeNilForKey:(id)key;

/*!
 Get object for key. This method can log the line and filename of the caller method. It is useful for logging types received at runtime for later validation.

 @param line Line number of the calling method, usually __LINE__.
 @param file File path of the calling method, usually __FILE__.
 @param key Key
 @result NSString object
 */
- (id)yk_objectMaybeNilAtLine:(NSInteger)line inFile:(char *)file forKey:(NSString *)key;

/*!
 Get NSString for key. Raises YKValidationError if value for key is not an NSString.

 @param key Key
 @result NSString object
 */
- (id)yk_NSStringMaybeNilForKey:(id)key;

/*!
 Get NSString or NSNumber for key. Raises YKValidationError if value for key is not an NSString or NSNumber.

 @param key Key
 @result NSString or NSNumber object
 */
- (id)yk_NSStringOrNSNumberMaybeNilForKey:(id)key;

/*!
 Get NSNumber for key. Raises YKValidationError if value for key is not an NSNumber.

 @param key Key
 @result NSNumber object
 */
- (id)yk_NSNumberMaybeNilForKey:(id)key;

/*!
 Get NSArray for key. Raises YKValidationError if value for key is not an NSArray.

 @param key Key
 @result NSArray object
 */
- (id)yk_NSArrayMaybeNilForKey:(id)key;

/*!
 Get NSDictionary for key. Raises YKValidationError if value for key is not an NSDictionary.

 @param key Key
 @result NSDictionary object
 */
- (id)yk_NSDictionaryMaybeNilForKey:(id)key;

/*!
 Get double value for key. Raises YKValidationError if value for key is not an NSNumber or NSString.

 @param key Key
 @param withDefault If value for key is nil or [NSNull null] this default is returned.
 @result Double value
 */
- (double)yk_doubleForKey:(id)key withDefault:(double)withDefault;

/*!
 Get double value for key. Raises YKValidationError if the value for key is not an NSNumber or NSString.

 @param key Key
 @result Double value
 */
- (double)yk_doubleForKey:(id)key;

/*!
 Integer for key. Raises YKValidationError if value for key is not an NSNumber or NSString.

 @param key Key
 @param withDefault If value for key is nil or [NSNull null] this default is returned.
 @result Integer value
 */
- (NSInteger)yk_integerForKey:(id)key withDefault:(NSInteger)withDefault;

/*!
 Integer for key. Raises YKValidationError if value for key is not an NSNumber or NSString.
 If value for key is nil or [NSNull null], 0 is returned.

 @param key Key
 @result Integer value
 */
- (NSInteger)yk_integerForKey:(id)key;

/*!
 Unsigned integer for key. Raises YKValidationError if value for key is not an NSNumber.

 @param key Key
 @param withDefault If value for key is nil or [NSNull null] this default is returned.
 @result Unsigned integer
 */
- (NSUInteger)yk_unsignedIntegerForKey:(id)key withDefault:(NSUInteger)withDefault;

/*!
 Unsigned integer for key. Raises YKValidationError if value for key is not an NSNumber.
 If value for key is nil or [NSNull null], 0 is returned.

 @param key Key
 @result Unsigned integer
 */
- (NSUInteger)yk_unsignedIntegerForKey:(id)key;

/*!
 Number for key with default double value. Raises YKValidationError if value for key is not an NSNumber or NSString.

 @param key Key
 @param withDefaultInteger If value for key is nil or [NSNull null] this default is returned.
 @result Number
 */
- (NSNumber *)yk_numberForKey:(id)key withDefaultInteger:(NSInteger)withDefaultInteger;

/*!
 Number for key with default double value. Raises YKValidationError if value for key is not an NSNumber or NSString.

 @param key Key
 @param withDefaultDouble If value for key is nil or [NSNull null] this default is returned.
 @result Number
 */
- (NSNumber *)yk_numberForKey:(id)key withDefaultDouble:(double)withDefaultDouble;

/*!
 Get BOOL value for key. Raises YKValidationError if value for key is not an NSNumber or NSString.

 @param key Key
 @param withDefault If value for key is nil or [NSNull null] this default is returned.
 @result BOOL value
 */
- (BOOL)yk_boolForKey:(id)key withDefault:(BOOL)withDefault;

/*!
 Get BOOL value for key. Raises YKValidationError if value for key is not an NSNumber or NSString.

 @param key Key
 @result YES if boolValue; If key not found or is NSNull, returns NO.
 */
- (BOOL)yk_boolForKey:(id)key;

/*!
 Get boolean value. Raises YKValidationError if value for key is not an NSNumber or NSString.

 @param key Key
 @param withDefault Default if value is missing or [NSNull null]
 @result Number
 */
- (NSNumber *)yk_boolValueForKey:(id)key withDefault:(BOOL)withDefault;

/*!
 Get boolean value. Raises YKValidationError if value for key is not an NSNumber or NSString.

 @param key Key
 @result Number
 */
- (NSNumber *)yk_boolValueForKey:(id)key;

@end
