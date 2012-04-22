//
//  YKURLRequest.h
//  YelpKit
//
//  Created by Gabriel Handford on 4/14/09.
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

#import "YKError.h"
#import "YKURL.h"
#import "YKCompressor.h"
#import "YKURLCache.h"


// Supported HTTP methods
typedef enum {
  YKHTTPMethodNone = 0,
  YKHTTPMethodGet,
  YKHTTPMethodPostMultipart,
  YKHTTPMethodPostMultipartCompressed,
  YKHTTPMethodPostForm,
  YKHTTPMethodHead,
} YKHTTPMethod;

// Deprecated; TODO(gabe): Remove after search/replace
typedef enum {
  YPHTTPMethodGet = 1,
  YPHTTPMethodPostMultipart,
  YPHTTPMethodPostMultipartCompressed,
  YPHTTPMethodPostForm,
  YPHTTPMethodHead,
} YPHTTPMethod;

typedef enum {
  YKURLRequestCachePolicyDisabled = 0, // Default
  YKURLRequestCachePolicyEnabled,
  YKURLRequestCachePolicyIfModifiedSince, // Currently not implemented
} YKURLRequestCachePolicy;

extern NSString *const kYKURLRequestDefaultContentType;
extern const double kYKURLRequestExpiresAgeMax;

@class YKURLRequest;

/*!
 URL request.
 
 To disable cache through user defaults, set NSUserDefaults#boolForKey:@"YKURLRequestCacheDisabled".
 */
@interface YKURLRequest : NSObject {
  
  id __delegate; // weak; Retained while connection is active; Prefixed with __ so subclasses aren't encouraged to access directly
  SEL _finishSelector;
  SEL _failSelector;
  SEL _cancelSelector;
  
  YKURL *_URL;
  YPHTTPMethod _method;
  
  NSTimeInterval _timeout;
  
  NSMutableURLRequest *_request;
  NSURLConnection *_connection; 
  NSMutableData *_downloadedData;
  NSURLResponse *_response;
  
  BOOL _started;
  BOOL _stopped;
  BOOL _cancelled;
  BOOL _cacheHit;
  BOOL _inCache;
  
  NSRunLoop *_runLoop;
  
  // For caching
  NSTimeInterval _expiresAge; // Max age for cached item; Defaults to 0 (expires immediately)
  YKURLRequestCachePolicy _cachePolicy; // Defaults to YKURLRequestCachePolicyEnabled (see _expiresAge interval)
  NSString *_cacheName; // Namespace for cache  
  
  // For mocking
  NSData *_mockResponse;
  NSTimeInterval _mockResponseDelayInterval;
  
  // If errored 
  YKError *_error;  

  // For metrics (intervals from reference date)
  NSTimeInterval _start;
  NSTimeInterval _startData;
  
  NSTimeInterval _responseInterval; // Time to receive the response (header)
  NSTimeInterval _dataInterval; // Time for receiving data  
  NSTimeInterval _totalInterval; // Total time for request
  NSTimeInterval _sentInterval; // From start to end of sent data
  
  NSUInteger _bytesWritten;
  
  NSTimer *_timer;
  
  BOOL _detachOnThread; //! Experimental!
  
  // Response data
  NSData *_responseData;
  
}

@property (readonly, nonatomic) NSURLConnection *connection;
@property (readonly, nonatomic) NSMutableURLRequest *request;
@property (readonly, nonatomic) NSURLResponse *response;
@property (retain, nonatomic) id delegate;
@property (assign, nonatomic) NSTimeInterval expiresAge;
@property (assign, nonatomic) NSTimeInterval timeout;
@property (readonly, nonatomic) NSMutableData *downloadedData;
@property (readonly, nonatomic, getter=isCacheHit) BOOL cacheHit; // YES if there was a cache hit for request
@property (readonly, nonatomic, getter=isInCache) BOOL inCache; // YES if this request was cached (after valid response)
@property (readonly, nonatomic, getter=isStopped) BOOL stopped; // YES if request has cancelled or finished
@property (readonly, nonatomic) BOOL started;

@property (readonly, nonatomic) SEL finishSelector;
@property (readonly, nonatomic) SEL failSelector;
@property (readonly, nonatomic) SEL cancelSelector;

@property (readonly, nonatomic) YKError *error;

@property (readonly, nonatomic) YKURL *URL;

//! For request to be cacheable it must have _expiresAge > 0 and cacheable is YES
@property (assign, nonatomic) YKURLRequestCachePolicy cachePolicy;
@property (assign, nonatomic) NSString *cacheName;

@property (retain, nonatomic) NSData *mockResponse;
@property (assign, nonatomic) NSTimeInterval mockResponseDelayInterval;

@property (readonly, nonatomic) NSTimeInterval start; // When request started
@property (readonly, nonatomic) NSTimeInterval dataInterval;
@property (readonly, nonatomic) NSTimeInterval totalInterval;
@property (readonly, nonatomic) NSTimeInterval sentInterval;
@property (readonly, nonatomic) NSTimeInterval responseInterval;
@property (readonly, nonatomic) NSUInteger bytesWritten;

@property (assign, nonatomic) BOOL detachOnThread;

@property (readonly, retain, nonatomic) NSData *responseData;

@property (retain, nonatomic) NSRunLoop *runLoop;

/*!
 Request the URL.
 The delegate is retained for the duration of the connection.
 
 The delegate must provide and implement the finished and failed selectors.
 
 @param URL URL
 @param headers Headers to include in request
 @param delegate Delegate
 @param finishSelector Finished selector, with a signature like:
  @code
  - (void)requestDidFinish:(YKURLRequest *)request;
  @endcode 
 @param failSelector Failure selector, with a signature like:
  @code
  - (void)request:(YKURLRequest *)request failedWithError:(YKError *)error;
  @endcode
 @param cancelSelector Cancel selector, with a signature like:
  @code
  - (void)requestDidCancel:(YKURLRequest *)request;
  @endcode
 @result NO if we were unable to make the request with the parameters
 
 Server errors (status >= 300) are reported as the code of the error object.
 */
- (BOOL)requestWithURL:(YKURL *)URL headers:(NSDictionary *)headers delegate:(id)delegate finishSelector:(SEL)finishSelector failSelector:(SEL)failSelector cancelSelector:(SEL)cancelSelector;

- (BOOL)requestWithURL:(YKURL *)URL method:(YPHTTPMethod)method headers:(NSDictionary *)headers postParams:(NSDictionary *)postParams keyEnumerator:(NSEnumerator *)keyEnumerator delegate:(id)delegate finishSelector:(SEL)finishSelector failSelector:(SEL)failSelector cancelSelector:(SEL)cancelSelector secure:(BOOL)secure;

/*!
 Cancel request. Will issued a cancelled notification to the delegate
 */
- (void)cancel;

/*!
 Close request. Releases connection and delegate.
 */
- (void)close;

- (void)setHTTPBodyFormData:(NSDictionary *)form;

/*!
 Set the HTTP multipart data.

 @param multipart Dictionary where key is name and value can be NSNumber, NSString, NSData or YKURLRequestDataPart
 @param keyEnumerator The ordering of the multipart data
 @param compress If YES, will apply the compressor
 */
- (void)setHTTPBodyMultipart:(NSDictionary *)multipart keyEnumerator:(NSEnumerator *)keyEnumerator compress:(BOOL)compress;

/*!
 Set whether to ignore auth errors. Useful for testing in debug environments with self signed certs.
 @param authProtectionDisabled Whether to disable protection
 */
+ (void)setAuthProtectionDisabled:(BOOL)authProtectionDisabled;

/*!
 Set the HTTP body data.

 @param data Data
 @param compress If specified, will apply the compressor
 */
- (void)setHTTPBody:(NSData *)data compress:(BOOL)compress;

+ (NSData *)HTTPBodyForMultipart:(NSDictionary *)multipart;

+ (NSData *)HTTPBodyForMultipart:(NSDictionary *)multipart keyEnumerator:(NSEnumerator *)keyEnumerator;

/*!
 @result the compressor used for request compression.
 */
+ (id<YKCompressor>)compressor;

/*!
 Set the compressor used for request compression.
 A compressor for gzip with GTM would look like:
 
     #import "GTMNSData+zlib.h"

     @implementation YPGZipCompressor
     
     + (YPGZipCompressor *)compressor {
      return [[[YPGZipCompressor alloc] init] autorelease];
     }
     
     - (NSData *)compressData:(NSData *)data {
      return [NSData gtm_dataByGzippingData:data];
     }
     
     - (NSString *)contentEncoding {
      return @"gzip";
     } 
     @end

 @param compressor Compressor to use
 */
+ (void)setCompressor:(id<YKCompressor>)compressor;

/*!
 Connection class (for mocking).

 @result Connection class
 */
+ (Class)connectionClass;

/*!
 Override connection class.

 @param theClass Class to use for connection
 */
+ (void)setConnectionClass:(Class)theClass;

/*!
 To disable the cache globally. (For testing.)
 */
+ (void)setCacheEnabled:(BOOL)cacheEnabled;

/*!
 Response status code (If HTTP response, the HTTP response code.)
 */
- (NSInteger)responseStatusCode;

/*!
 Response headers.
 */
- (NSDictionary *)responseHeaderFields;

/*!
 Date from response header, if any.
 */
- (NSDate *)responseDate;

/*!
 Get downloaded data as string (UTF-8).
 */
- (NSString *)downloadedDataAsString;

/*!
 Should load from cache.
 */
- (BOOL)shouldAttemptLoadFromCache;

/*!
 Should store in cache.

 @result YES if cache policy enabled 
 */
- (BOOL)shouldStoreInCache;

/*!
 The shared cache used by this request.
 */
- (YKURLCache *)cache;

/*!
 Description of request metrics.
 */
- (NSString *)metricsDescription;


- (void)willRequestURL:(YKURL *)URL;
- (void)didLoadData:(NSData *)data withResponse:(NSURLResponse *)response cacheKey:(NSString *)cacheKey;
- (BOOL)shouldCacheData:(NSData *)data forKey:(id)key;

// Notifies of didError OR didFinish OR didCancel
- (void)didError:(YKError *)error;
- (void)didFinishWithData:(NSData *)data cacheKey:(NSString *)cacheKey;
- (void)didCancel;


@end


#define YKURLRequestRelease(__REQUEST__) \
do { \
__REQUEST__.delegate = nil; \
[__REQUEST__ cancel]; \
[__REQUEST__ release]; \
__REQUEST__ = nil; \
} while (0);


@interface YKURLRequestDataPart : NSObject {
  NSString *_contentType;
  NSData *_data;
}

@property (retain, nonatomic) NSString *contentType;
@property (retain, nonatomic) NSData *data;

+ (YKURLRequestDataPart *)text:(NSString *)text;

@end
