// ///////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2010, Frank Blumenberg
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
#import <Foundation/Foundation.h>

typedef enum {
  MKTRouteDropboxSyncOverrideOlder,
  MKTRouteDropboxSyncOverrideLocal,
  MKTRouteDropboxSyncOverrideRemote
} MKTRouteDropboxSyncOption;


@class MKTRoute;
@class DBFileInfo;

@interface MKTSyncItem : NSObject

+ (id)itemWith:(MKTRoute*)route andData:(DBFileInfo*)data;

@property(strong) MKTRoute* route;
@property(strong) DBFileInfo* metaData;

@end

@interface MKTRouteSyncModel : NSObject

- (id)initWithRoutes:(NSArray*)routes metaData:(NSArray*)metaData;
- (void) prepareForSynchWithOption:(MKTRouteDropboxSyncOption)option;

@property(strong) NSArray* routes;
@property(strong) NSArray* metaData;

@property(readonly) NSMutableArray* itemsForUpload;
@property(readonly) NSMutableArray* itemsForDownload;
@property(readonly) NSMutableArray* itemsForDelete;

@end
