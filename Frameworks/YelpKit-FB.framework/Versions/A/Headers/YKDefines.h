//
//  YKDefines.h
//  YelpKit
//
//  Created by Gabriel Handford on 4/8/09.
//  Copyright 2009 Yelp. All rights reserved.
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
 Generates description from key-value coding.

 For example:
 
     - (NSString *)description {
         return YKDescription(@"foo", @"bar", @"someInteger");
     }

 */
#define YKDescription(...) [NSString stringWithFormat:@"%@; %@", [super description], [[self dictionaryWithValuesForKeys:[NSArray arrayWithObjects:__VA_ARGS__, nil]] description]]
#define YPDebugProps(__OBJ__, ...) [[__OBJ__ dictionaryWithValuesForKeys:[NSArray arrayWithObjects:__VA_ARGS__, nil]] description]

#define YKIntervalToMillis(interval, defaultValue) (interval >= 0 ? (long long)round(interval * 1000) : defaultValue)

#define YKOrNSNull(__OBJ__) (__OBJ__ ? __OBJ__ : (id)[NSNull null])

#define YKAssertMainThread() NSAssert([NSThread isMainThread], @"Should be on main thread");

/*!
 Constants.
 */
#define YKTimeIntervalMinute (60)
#define YKTimeIntervalHour (YKTimeIntervalMinute * 60)
#define YKTimeIntervalDay (YKTimeIntervalHour * 24)
#define YKTimeIntervalWeek (YKTimeIntervalDay * 7)
#define YKTimeIntervalYear (YKTimeIntervalDay * 365.242199)
#define YKTimeIntervalMax (DBL_MAX)


/*!
 Macro defaults.
 */
#undef YKDebug
#define YKDebug(fmt, ...) do {} while(0)
#undef YKException
#define YKException(e) do {} while(0)
#undef YKErr
#define YKErr(fmt, ...) do {} while(0)
#undef YKAssert
#define YKAssert(value, desc, ...) do {} while(0)
#undef YKParameterAssert
#define YKParameterAssert(__CONDITION__) do {} while(0)

/*!
 Logging macros.
 */
#if DEBUG
#undef YKDebug
#define YKDebug(fmt, ...) NSLog((@"%s:%d: " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#undef YKException
#define YKException(__EXCEPTION__) NSLog(@"%@", [NSString stringWithFormat:@"\n\n%@\n", [__EXCEPTION__ description], nil])
#undef YKErr
#define YKErr(fmt, ...) NSLog((@"%s:%d: " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#undef YKAssert
#define YKAssert(value, fmt, ...) do { if (!(value)) {NSString *desc = [NSString stringWithFormat:fmt, ##__VA_ARGS__]; NSLog(@"%@", desc); NSAssert(NO, desc); } } while(0)
#undef YKParameterAssert
#define YKParameterAssert(__CONDITION__) do { NSParameterAssert(__CONDITION__); } while(0)
#endif

#define YKArrayLength(__ARRAY__) ((sizeof __ARRAY__) / (sizeof __ARRAY__[0]))

#define YKIsEqualWithAccuracy(n1, n2, accuracy) (n1 >= (n2-accuracy) && n1 <= (n2+accuracy))

#define YKIsEqualObjects(obj1, obj2) ((obj1 == nil && obj2 == nil) || ([obj1 isEqual:obj2]))

#define YKConstrain(value, min, max) (value) < (min) ? (min) : ((value) > (max) ? (max) : (value))

#ifndef __has_feature      // Optional.
#define __has_feature(x) 0 // Compatibility with non-clang compilers.
#endif

#ifndef NS_RETURNS_RETAINED
#if __has_feature(attribute_ns_returns_retained)
#define NS_RETURNS_RETAINED __attribute__((ns_returns_retained))
#else
#define NS_RETURNS_RETAINED
#endif
#endif

#ifndef NS_RETURNS_NOT_RETAINED
#if __has_feature(attribute_ns_returns_not_retained)
#define NS_RETURNS_NOT_RETAINED __attribute__((ns_returns_not_retained))
#else
#define NS_RETURNS_NOT_RETAINED
#endif
#endif

/*!
 Core Graphics macros, for more concise syntax.
*/
#define CGRectLeft(rect) (rect.origin.x)
#define CGRectRight(rect) (rect.origin.x + rect.size.width)
#define CGRectTop(rect) (rect.origin.y)
#define CGRectBottom(rect) (rect.origin.y + rect.size.height)

/*!
 This is pulled from GData obj-c API
 @see http://code.google.com/p/gdata-objectivec-client/source/browse/trunk/Source/Networking/GDataHTTPFetcher.m
 */
static inline void YKAssertSelectorNilOrImplementedWithArguments(id obj, SEL sel, ...) {
  
  // verify that the object's selector is implemented with the proper
  // number and type of arguments
#if YP_DEBUG
  va_list argList;
  va_start(argList, sel);
  
  if (obj && sel) {
    // check that the selector is implemented
    if (![obj respondsToSelector:sel]) {
      [NSException raise:NSInvalidArgumentException format:@"\"%@\" selector \"%@\" is unimplemented or misnamed", 
       NSStringFromClass([obj class]), 
       NSStringFromSelector(sel)];
    } else {
      const char *expectedArgType;
      unsigned int argCount = 2; // skip self and _cmd
      NSMethodSignature *sig = [obj methodSignatureForSelector:sel];
      
      // check that each expected argument is present and of the correct type
      while ((expectedArgType = va_arg(argList, const char*)) != 0) {
        
        if ([sig numberOfArguments] > argCount) {
          const char *foundArgType = [sig getArgumentTypeAtIndex:argCount];
          
          if(0 != strncmp(foundArgType, expectedArgType, strlen(expectedArgType))) {
            [NSException raise:NSInvalidArgumentException format:@"\"%@\" selector \"%@\" argument %d should be type %s", 
             NSStringFromClass([obj class]), 
             NSStringFromSelector(sel), (argCount - 2), expectedArgType];
          }
        }
        argCount++;
      }
      
      // check that the proper number of arguments are present in the selector
      if (argCount != [sig numberOfArguments]) {
        [NSException raise:NSInvalidArgumentException format:@"\"%@\" selector \"%@\" should have %d arguments",
         NSStringFromClass([obj class]), 
         NSStringFromSelector(sel), (argCount - 2)];
      }
    }
  }
  
  va_end(argList);
#endif
}

