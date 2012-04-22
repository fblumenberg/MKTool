//
//  YKError.h
//  YelpKit
//
//  Created by Gabriel Handford on 2/5/09.
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

// Error domains
extern NSString *const YKErrorDomain;

extern NSString *const YKErrorUnknown;

extern NSString *const YKErrorRequest; // A generic error
extern NSString *const YKErrorAuthChallenge; // We received an unexpected auth challenge
extern NSString *const YKErrorServerResourceNotFound; // Server was reached but returned a 404 error
extern NSString *const YKErrorServerMaintenance; // Server was reached but returned a 503 error
extern NSString *const YKErrorServerResponse; // Server was reached but returned some other error
extern NSString *const YKErrorCannotConnectToHost; // Server not reachable but internet active
extern NSString *const YKErrorNotConnectedToInternet;


/*!
 Generic error class, which stores error code as a unique string (key).
 
 The localized description can be set using the same string key.
 
 Usage might look like:

     // In .h
     extern NSString *const YKErrorBadFoo;
     
     // In .m
     NSString *const YKErrorBadFoo = @"YKErrorBadFoo";
     
     // Creating "bad foo" error
     YKError *error = [YKError errorWithKey:YKErrorBadFoo];
     
     // Somewhere else checking if error is for "bad foo"
     if (error.key == YKErrorBadFoo) { ... } 
     
     // In strings file:
     YKErrorBadFoo = "There was some bad foo";

 */
@interface YKError : NSError {

  NSString *_key;
  
  NSString *_description;
  
  NSString *_unknownDescription; 
  
}

/*!
 The unique string identifier for this error.
 */
@property (readonly, retain, nonatomic) NSString *key;

/*!
 Description for error, to override in userInfo.
 */
@property (retain, nonatomic) NSString *description;

/*!
 Allows us to override default description if localized message not available.
 For example, if there was an error in talk we might set this to: 
 
      "We had trouble getting to Talk.\nPlease try again in a bit."

 */
@property (retain, nonatomic) NSString *unknownDescription;

/*!
 Create error with key.

 The key is also used to look up the localized description.
 The NSError code defaults to -1; and is not mean to be used.
 The domain is set to YKErrorDomain.
 
 The localized description is set via NSLocalizedString(key).
 
 @param key Key should be a unique string and include domain + error.
 @result Error with key
 */
- (id)initWithKey:(NSString *const)key;

/*!
 Create error with key.
 See initWithKey:.
 
 @param key Key should be a unique string and include domain + error.
 @param userInfo User info
 @result Error with key
 */
- (id)initWithKey:(NSString *const)key userInfo:(NSDictionary *)userInfo;

/*!
 Create error with key, with source error.
 See initWithKey:.
 
 @param key Key should be a unique string and include domain + error.
 @param error Source error
 @result Error with key
 */
- (id)initWithKey:(NSString *const)key error:(NSError *)error;

/*!
 See initWithKey:.
 
 @param key Key
 @param userInfo User info
 */
+ (id)errorWithKey:(NSString *const)key userInfo:(NSDictionary *)userInfo;

/*!
 See initWithKey:.
 
 @param key Key
 @param localizedDescription Localized description
 */
+ (id)errorWithKey:(NSString *const)key localizedDescription:(NSString *)localizedDescription;

/*!
 See initWithKey:.
 
 @param key Key
 */
+ (id)errorWithKey:(NSString *const)key;

/*!
 See initWithKey:error:.
 
 @param key Key
 @param error Source error
 */
+ (id)errorWithKey:(NSString *const)key error:(NSError *)error;

/*!
 Create an error with no key (a general error), with only a description.
 @param description
 */
+ (id)errorWithDescription:(NSString *)description;;

/*!
 Get the user info for key.
 */
- (id)userInfoForKey:(NSString *)key;

/*!
 Get the user info for key and subKey.
 @param key Key
 @param subKey Sub key
 */
- (id)userInfoForKey:(NSString *)key subKey:(NSString *)subKey;

/*!
 Set (override) description.
 @param description
 */
- (void)setDescription:(NSString *)description;

/*!
 For subclasses to overide the default implementation for localized description from key.
 @result Localized description for key, by default is NSLocalizedString(key)
 */
- (NSString *)localizedDescriptionForKey;

/*!
 Create YKError from NSError.
 @result Results passed in error if that was already a YKError
 */
+ (YKError *)errorForError:(NSError *)error;

/*!
 Fields that caused the error.
 @result Array of dictionary with name, localized_description keys, or nil
 */
- (NSArray */*of NSDictionary*/)fields;

@end

/*!
 HTTP error, which is a YKError with an HTTP status code.
 */
@interface YKHTTPError : YKError {
  NSInteger _HTTPStatus;
}

/*!
 HTTP status code.
 */
@property (readonly, assign, nonatomic) NSInteger HTTPStatus;

/*!
 Create error with HTTP status.
 @param HTTPStatus HTTP status
 */
+ (YKHTTPError *)errorWithHTTPStatus:(NSInteger)HTTPStatus;

/*!
 YKError key for HTTP status.
 
    503: YKErrorServerMaintenance
    404: YKErrorServerResourceNotFound
    default: YKErrorServerResponse
 
 @param HTTPStatus HTTP status
 @result Key
 */
+ (NSString *const)keyForHTTPStatus:(NSInteger)HTTPStatus;

@end
