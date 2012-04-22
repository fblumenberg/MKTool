//
//  YKResource.h
//  YelpKit
//
//  Created by Gabriel Handford on 8/19/09.
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

@interface YKResource : NSObject { }

/*!
 Path to documents directory.
 
 @result Path to documents directory
 */
+ (NSString *)documentsDirectory;

/*!
 Path to documents directory.
 
 @result Path to cache directory
 */
+ (NSString *)cacheDirectory;

/*!
 Checks documents directory for file, and if it doesn't exist, it is copied there from the resource directory.
 
 @param fileName File
 @result Returns path to file in documents directory
 */
+ (NSString *)pathToResourceCopiedInDocuments:(NSString *)fileName;

/*!
 Path to resource copy in documents.
 @param source Source
 @param dest Destination
 @param overwrite If YES, will overwrite existing file
 @result Returns path to file in documents directory, if it doesn't exist in the document directory, it is copied there first.
 */
+ (NSString *)pathToResourceCopiedInDocumentsFrom:(NSString *)source to:(NSString *)dest overwrite:(BOOL)overwrite;

/*!
 Full path to file in documents.
 */
+ (NSString *)pathInDocuments:(NSString *)path;

/*!
 Full path to documents in path with components.
 */
+ (NSString *)pathInDocumentsWithComponents:(NSArray *)components;

/*!
 Full path to file in resource bundle.
 */
+ (NSString *)pathToResource:(NSString *)path;

/*!
 Bundle URL string for path to file in resource bundle.
 @param path Path
 @result Path or nil if it doesn't exist
 */
+ (NSString *)bundleURLStringForResourceIfExists:(NSString *)path;

/*!
 Full path to file in cache.
 */
+ (NSString *)pathToCache:(NSString *)path;

/*! 
 Load object from file.
 */
+ (id)loadObjectFromPath:(NSString *)path defaultValue:(id)defaultValue error:(NSError **)error;

/*!
 Save object to file.

 @param obj Object to save
 @param path Path to save
 @param error Out error
 @result YES if saved OK
 */
+ (BOOL)saveObject:(id)obj toPath:(NSString *)path error:(NSError **)error;

/*!
 Resolve to file path from (bundle) URL.
 */
+ (NSString *)resolvedPathForURL:(NSURL *)URL;

/*!
 Resolve to file URL from (bundle_ URL.
 */
+ (NSURL *)resolvedURLForURL:(NSURL *)URL;

/*!
 Path for bundle URL. If not a bundle URL returns nil;
 */
+ (NSString *)pathForBundleURL:(NSURL *)URL;

/*!
 Check if URL exists.
 
 @result YES if file (or bundle) URL exists.
 */
+ (BOOL)URLExists:(NSURL *)URL;

@end
