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
/////////////////////////////////////////////////////////////////////////////////

#import "DropboxSDK/DropboxSDK.h"
#import "InnerBand.h"
#import "NSArray+BlocksKit.h"

#import "MKTRouteSyncModel.h"
#import "MKTRoute.h"

@implementation MKTSyncItem
@synthesize route,metaData;
+ (id)itemWith:(MKTRoute*)route andData:(DBMetadata*)data{
  MKTSyncItem* item =[MKTSyncItem new];
  item.route = route;
  item.metaData = data;
  return item;
}

- (NSString*)description{
  return [NSString stringWithFormat:@"r:%@ %@ m:%@ %@",route.parentRev,route.lastUpdated,metaData.rev,metaData.lastModifiedDate];
}
@end

/////////////////////////////////////////////////////////////////////////////////

@interface MKTRouteSyncModel ()

- (void)prepareSync:(MKTSyncItem *)item option:(MKTRouteDropboxSyncOption)option;

@end

@implementation MKTRouteSyncModel

@synthesize itemsForDownload;
@synthesize itemsForUpload;
@synthesize itemsForDelete;

@synthesize routes=_routes;
@synthesize metaData=_metaData;

- (id)initWithRoutes:(NSArray*)routes metaData:(NSArray*)metaData {
  self = [super init];
  if (self) {
    self.routes = routes;
    self.metaData = metaData;
    
    itemsForDownload = [NSMutableArray array];
    itemsForUpload = [NSMutableArray array];
    itemsForDelete = [NSMutableArray array]; 
  }
  return self;
}

- (void) prepareForSynchWithOption:(MKTRouteDropboxSyncOption)option{
  
  [self.itemsForDownload removeAllObjects];
  [self.itemsForUpload removeAllObjects];
  [self.itemsForDelete removeAllObjects];
  
  NSMutableArray* dataItems=[self.metaData mutableCopy];
  
  NSMutableArray* items = [[self.routes map:^(MKTRoute* r){
    
    DBMetadata* data = [self.metaData match:^(DBMetadata* obj) {
      return [r.fileName isEqualToString:obj.filename];
    }];
    
    if (data)
      [dataItems removeObjectAtIndex:[dataItems indexOfObject:data]];
    
    return [MKTSyncItem itemWith:r andData:data];
  }] mutableCopy];
  
  [dataItems each:^(DBMetadata* d){
    [items pushObject:[MKTSyncItem itemWith:nil andData:d]];
  }];
  
  NSLog(@"items before preparing %@",items);
  
  [items each:^(MKTSyncItem* item){
    [self prepareSync:item option:option];
  }];
  
}

- (void)prepareSync:(MKTSyncItem *)item option:(MKTRouteDropboxSyncOption)option {
  
  if(option==MKTRouteDropboxSyncOverrideRemote){
    if(item.route)
      [self.itemsForUpload pushObject:item];
    else if(item.metaData)
      [self.itemsForDelete pushObject:item];
  }
  else if (option==MKTRouteDropboxSyncOverrideLocal) {
    if(item.metaData)
      [self.itemsForDownload pushObject:item];
    else if(item.route)
      [self.itemsForDelete pushObject:item];
  }
  else {
    if(item.route && item.metaData){
      if( [item.route.parentRev isEqualToString:item.metaData.rev] ) {
        
        if(![item.route.lastUpdated isEqual:item.metaData.lastModifiedDate])
          [self.itemsForUpload pushObject:item];
      }
      else {
        
        // The receiver is later in time than anotherDate, NSOrderedDescending
        if( [item.route.lastUpdated compare:item.metaData.lastModifiedDate]==NSOrderedDescending)
          [self.itemsForUpload pushObject:item];
        else 
          [self.itemsForDownload pushObject:item];
      }
    }
    else {
      if(item.metaData)
        [self.itemsForDownload pushObject:item];
      else if(item.route)
        [self.itemsForUpload pushObject:item];
    }
  }
}

@end
