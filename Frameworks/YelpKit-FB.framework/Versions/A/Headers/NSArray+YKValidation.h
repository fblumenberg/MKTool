//
//  NSArray+YKValidation.h
//  YelpKit
//
//  Created by John Boiles on 4/19/12.
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
 Methods for reading and validating data from an NSArray. These methods raise YKValidationError if they fail validation. This is useful for safely reading data that has been parsed into NSObjects from format such as JSON or XML.
 */
@interface NSArray (YKValidation)

/*!
 Get object for index. Returns nil if index is NSNull. Raises YKValidationError if index is out of range.

 @param index Index
 @result object
 */
- (id)yk_objectAtIndex:(NSInteger)index;

/*!
 Get NSString for index. Raises YKValidationError if value at index is not an NSString.

 @param index Index
 @result NSString object
 */
- (id)yk_NSStringMaybeNilAtIndex:(NSInteger)index;

/*!
 Get NSString or NSNumber for index. Raises YKValidationError if value at index is not an NSNumber.

 @param index Index
 @result NSString or NSNumber object
 */
- (id)yk_NSStringOrNSNumberMaybeNilAtIndex:(NSInteger)index;

/*!
 Get NSNumber for index. Raises YKValidationError if value at index is not an NSNumber.

 @param index Index
 @result NSNumber object
 */
- (id)yk_NSNumberMaybeNilAtIndex:(NSInteger)index;

/*!
 Get NSArray for index. Raises YKValidationError if value at index is not an NSArray.

 @param index Index
 @result NSArray object
 */
- (id)yk_NSArrayMaybeNilAtIndex:(NSInteger)index;

/*!
 Get NSDictionary for index. Raises YKValidationError if value at index is not an NSDictionary.

 @param index Index
 @result NSDictionary object
 */
- (id)yk_NSDictionaryMaybeNilAtIndex:(NSInteger)index;

@end
