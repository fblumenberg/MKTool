//
//  YKURL.h
//  YelpKit
//
//  Created by Gabriel Handford on 11/4/09.
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
 URL.
 */
@interface YKURL : NSObject {
  NSString *_URLString;
  BOOL _cacheDisabled;
}

/*!
 Hint for whether this resource should be cached
 */
@property (assign, nonatomic, getter=isCacheDisabled) BOOL cacheDisabled;

/*!
 Create YKURL from string.
 
 @param URLString The URL as a string
 */
- (id)initWithURLString:(NSString *)URLString;

/*!
 Create YKURL from string.
 
 @param URLString The URL as a string
 */
+ (YKURL *)URLString:(NSString *)URLString;

/*!
 Create YKURL from string.
 
 @param URLString The URL as a string
 @param cacheEnabled Hint for whether this resource should be cached
 */
+ (YKURL *)URLString:(NSString *)URLString cacheEnabled:(BOOL)cacheEnabled;

/*!
 Cacheable URL string. Defaults to URLString.
 Subclasses may override to support custom implementation that ignores certain query params, for example.
 
 @result URL string to use as a key in a cache
 */
- (NSString *)cacheableURLString;

/*!
 URL String.
 
 @result The URL as a string.
 */
- (NSString *)URLString;

@end
