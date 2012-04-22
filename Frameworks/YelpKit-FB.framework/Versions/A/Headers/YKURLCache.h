//
//  YKURLCache.h
//  YelpIPhone
//
//  Created by Gabriel Handford on 6/24/10.
//  Copyright 2010 Yelp. All rights reserved.
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

//
// Based on TTURLCache:
//
// Copyright 2009-2010 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

/*!
 A general purpose URL cache for caching data in memory and on disk.
 
 Based on TTURLCache from Three20 library.
 */
@interface YKURLCache : NSObject {  
  NSString *_name;
  NSString *_cachePath;  
  NSTimeInterval _invalidationAge;
  BOOL _disableDiskCache;
  
  // Image cache
  NSMutableDictionary *_imageCache;
  NSMutableArray *_imageSortedList;
  NSInteger _totalPixelCount;
  NSUInteger _maxPixelCount;  
}

/*!
 Disables the disk cache. Disables ETag support as well.
 */
@property (nonatomic) BOOL disableDiskCache;

/*!
 Gets the path to the directory of the disk cache.
 */
@property (nonatomic, copy) NSString *cachePath;

/*!
 Gets the path to the directory of the disk cache for ETags.
 */
@property (nonatomic, readonly) NSString *ETagCachePath;

/*!
  The amount of time to set back the modification timestamp on files when invalidating them.
 */
@property (nonatomic) NSTimeInterval invalidationAge;

/*!
 The maximum number of pixels to keep in memory for cached images.

 Setting this to zero will allow an unlimited number of images to be cached. The default is 262,144.
 */
@property (nonatomic) NSUInteger maxPixelCount;

/*!
 Gets a shared cache identified with a unique name.

 @param name Name
 */
+ (YKURLCache *)cacheWithName:(NSString *)name;

/*!
 Get shared cache.
 */
+ (YKURLCache *)sharedCache;

/*!
 Create cache.

 @param name Name
 */
- (id)initWithName:(NSString *)name;

/*!
 Total memory for the device.
 */
+ (NSUInteger)totalMemory;

/*!
 Gets the key that would be used to cache a URL response.
 
 @param URLString URL as a string
 */
- (NSString *)keyForURLString:(NSString *)URLString;

/*!
 Gets the path in the cache where a URL may be stored.
 
 @param URLString URL as a string
 */
- (NSString *)cachePathForURLString:(NSString *)URLString;

/*!
 Gets the path in the cache where a key may be stored.
 
 @param key Key
 */
- (NSString *)cachePathForKey:(NSString *)key;

/*!
 Etag cache files are stored in the following way:
 File name: <key>
 File data: <ETag value>
 
 @param key Key
 @result The ETag cache path for the given key.
 */
- (NSString *)ETagCachePathForKey:(NSString *)key;

/*!
 Determines if there is a cache entry for a URL.
 */
- (BOOL)hasDataForURLString:(NSString *)URLString;

/*!
 Determines if there is a cache entry for a key.
 */
- (BOOL)hasDataForKey:(NSString *)key expires:(NSTimeInterval)expirationAge;

/*!
 Gets the data for a URL from the cache if it exists.
 
 @param URLString URL as a string
 @result nil if the URL is not cached.
 */
- (NSData *)dataForURLString:(NSString *)URLString;

/*!
 Gets the data for a URL from the cache if it exists and is newer than a minimum timestamp.
 
 @param URLString URL as a string
 @param expires How long until resource expires
 @param timestamp If not nil will be set to the timestamp of the data
 @result nil if hthe URL is not cached or if the cache entry is older than the minimum.
 */
- (NSData *)dataForURLString:(NSString *)URLString expires:(NSTimeInterval)expirationAge timestamp:(NSDate**)timestamp;

- (NSData *)dataForKey:(NSString *)key expires:(NSTimeInterval)expirationAge timestamp:(NSDate**)timestamp;

/*!
 Get an ETag value for a given cache key.
 */
- (NSString *)ETagForKey:(NSString *)key;

/*!
 Stores a data on disk.
 */
- (void)storeData:(NSData *)data forURLString:(NSString *)URLString;

- (void)storeData:(NSData *)data forKey:(NSString *)key;

/*!
 Stores an ETag value in the ETag cache.
 */
- (void)storeETag:(NSString *)ETag forKey:(NSString *)key;

/*!
 Soves the data currently stored under one URL to another URL.
 
 This is handy when you are caching data at a temporary URL while the permanent URL is being
 retrieved from a server.  Once you know the permanent URL you can use this to move the data.
 */
- (void)moveDataForURLString:(NSString *)oldURLString toURLString:(NSString *)newURLString;

- (void)moveDataFromPath:(NSString *)path toURLString:(NSString *)newURLString;

/*!
 Removes the data for a URL from the memory cache and optionally from the disk cache.
 */
- (void)removeURLString:(NSString *)URLString fromDisk:(BOOL)fromDisk;

- (void)removeKey:(NSString *)key;

/*!
 Erases the memory cache and optionally the disk cache.
 */
- (void)removeAll:(BOOL)fromDisk;

/*!
 Invalidates the file in the disk cache so that its modified timestamp is the current
 time minus the default cache expiration age.
 
 This ensures that the next time the URL is requested from the cache it will be loaded
 from the network if the default cache expiration age is used.
 */
- (void)invalidateURLString:(NSString *)URL;

- (void)invalidateKey:(NSString *)key;

/*!
 Invalidates all files in the disk cache according to rules explained in `invalidateURL`.
 */
- (void)invalidateAll;

#pragma mark Image Cache

/**
   Stores an image in the memory cache.
 */
- (BOOL)cacheImage:(UIImage *)image forURLString:(NSString *)URLString;

- (UIImage *)cachedImageForURLString:(NSString *)URLString expires:(NSTimeInterval)expires;

@end