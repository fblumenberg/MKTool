//
//  YKImageLoader.h
//  YelpIPhone
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

#import "YKURLRequest.h"
#import "YKError.h"

@class YKImageLoader;
@class YKImageLoaderQueue;

typedef enum {
  YKImageLoaderStatusNone,
  YKImageLoaderStatusLoading,
  YKImageLoaderStatusLoaded,
  YKImageLoaderStatusErrored,
} YKImageLoaderStatus;

@protocol YKImageLoaderDelegate <NSObject>
- (void)imageLoader:(YKImageLoader *)imageLoader didUpdateStatus:(YKImageLoaderStatus)status image:(UIImage *)image;
@optional
- (void)imageLoaderDidStart:(YKImageLoader *)imageLoader;
- (void)imageLoader:(YKImageLoader *)imageLoader didError:(YKError *)error;
- (void)imageLoaderDidCancel:(YKImageLoader *)imageLoader;
@end

/*!
 Image loader.
 
 To disable the cache, set NSUserDefaults#boolForKey:@"YKImageLoaderCacheDisabled".
 */
@interface YKImageLoader : NSObject {  
  
  YKURLRequest *_request; 
  
  YKURL *_URL;
  UIImage *_image;
  UIImage *_defaultImage;
  UIImage *_loadingImage;
  id<YKImageLoaderDelegate> _delegate; // weak
  
  YKImageLoaderQueue *_queue; // weak
}

@property (readonly, retain, nonatomic) YKURL *URL;
@property (readonly, nonatomic) UIImage *image;
@property (retain, nonatomic) UIImage *defaultImage;
@property (readonly, retain, nonatomic) UIImage *loadingImage;
@property (assign, nonatomic) id<YKImageLoaderDelegate> delegate;
@property (assign, nonatomic) YKImageLoaderQueue *queue;

- (id)initWithLoadingImage:(UIImage *)loadingImage defaultImage:(UIImage *)defaultImage delegate:(id<YKImageLoaderDelegate>)delegate;

+ (YKImageLoader *)imageLoaderWithURLString:(NSString *)URLString loadingImage:(UIImage *)loadingImage defaultImage:(UIImage *)defaultImage delegate:(id<YKImageLoaderDelegate>)delegate;

/*!
 Set a global mock image.
 If the mock image is set to something non-nil, all instances of YKImageLoader
 will return the mock image instead of loading the image specified by the URL.
 This is useful for UI verification.

 @param mockImage Image to use as the mock
 */
+ (void)setMockImage:(UIImage *)mockImage;

/*!
 Load URL.
 
 By default this will use the default [YKImageLoaderQueue sharedQueue] loader queue.
 To use a custom loader queue use setURL:queue:.

 @param URL URL
 */
- (void)setURL:(YKURL *)URL;

/*!
 Load URL.
 @param URL URL
 @param queue Loader queue
 */
- (void)setURL:(YKURL *)URL queue:(YKImageLoaderQueue *)queue;

/*!
 Load URL string.
 @param URLString URL string
 */
- (void)setURLString:(NSString *)URLString;

/*!
 Start the request. You shouldn't ever need to call this directly.
 */
- (void)load;

/*!
 Cancel any request.
 */
- (void)cancel;

@end


/*!
 Image loader queue.
 */
@interface YKImageLoaderQueue : NSObject {
  NSMutableArray *_waitingQueue;
  NSMutableArray *_loadingQueue;
  
  NSInteger _maxLoadingCount;
}

+ (YKImageLoaderQueue *)sharedQueue;

/*!
 Enqueue an image loader.
 @param imageLoader Image laoder to enqueue
 */
- (void)enqueue:(YKImageLoader *)imageLoader;

/*!
 Dequeue an image loader.
 @param imageLoader Image laoder to dequeue
 */
- (void)dequeue:(YKImageLoader *)imageLoader;

/*!
 Check the queue.
 */
- (void)check;

/*!
 Called when the image loader finished.
 @param imageLoader Image loader that finished
 */
- (void)imageLoaderDidEnd:(YKImageLoader *)imageLoader;

@end
