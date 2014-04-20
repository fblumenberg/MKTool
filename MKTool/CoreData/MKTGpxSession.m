// ///////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2012, Frank Blumenberg
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

#import <MapKit/MapKit.h>
#import "InnerBand.h"
#import "YKCLUtils.h"

#import "MKTGpxSession.h"
#import "MKTGpxRecord.h"

#import "IKNaviData.h"
#import "GHNSDate+Formatters.h"

@implementation MKTGpxSession

@synthesize fileName = _fileName;

- (void)awakeFromFetch{
  _fileName = [[self.startTime gh_formatISO8601] stringByAppendingPathExtension:@"gpx"];
}

- (void)awakeFromInsert{
  self.startTime = [NSDate date];
  _fileName = [self.startTime gh_formatISO8601];
}

- (MKCoordinateRegion)region {
  
  MKCoordinateRegion region;
  [self.regionData getBytes:&region length:sizeof(region)];

  return region;
}

- (void)setRegion:(MKCoordinateRegion)region {
  
  NSData *data = [NSData dataWithBytes:&region length:sizeof(region)];
  self.regionData = data;
}


-(void) calculateCoordinateRegionForRecords {
  MKMapRect r = MKMapRectNull;
  
  for (MKTGpxRecord* record in self.records) {
    IKGPSPos* gpsPos=record.gpsPos;
    MKMapPoint p = MKMapPointForCoordinate(gpsPos.coordinate);
    r = MKMapRectUnion(r, MKMapRectMake(p.x, p.y, 0, 0));
  }

  self.region = MKCoordinateRegionForMapRect(r);
}


- (CLLocationCoordinate2D)centerCoordinate{
  
  if ([self.records count] > 1) {
    CLLocationDegrees latMin = 360.0;
    CLLocationDegrees latMax = -360.0;
    CLLocationDegrees longMin = 360.0;
    CLLocationDegrees longMax = -360.0;
    
    for (MKTGpxRecord *r in self.records) {
      IKGPSPos* p  = r.gpsPos;
      latMax = MAX(latMax, p.coordinate.latitude);
      latMin = MIN(latMin, p.coordinate.latitude);
      longMax = MAX(longMax, p.coordinate.longitude);
      longMin = MIN(longMin, p.coordinate.longitude);
    }
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latMin + (latMax - latMin) / 2.0, longMin + (longMax - longMin) / 2.0);
    return coordinate;
  }
  
  else if ([self.records count] == 1) {
    MKTGpxRecord *r = [self.records anyObject];
    IKGPSPos* p  = r.gpsPos;
    return p.coordinate;
  }
  
  return YKCLLocationCoordinate2DNull;
}

- (NSArray *)orderedRecords {
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"session=%@", self];
  return [MKTGpxRecord allForPredicate:predicate orderBy:@"timestamp" ascending:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
///////////////////////////////////////////////////////////////////////////////////////////////////

+ (NSFetchedResultsController *)fetchedResultsController {
  
  IBCoreDataStore *store = [IBCoreDataStore mainStore];
  
  // Create the fetch request for the entity.
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  
  fetchRequest.entity = [MKTGpxSession entityInManagedObjectContext:store.context];
  fetchRequest.fetchBatchSize = 20;
  
  // Edit the sort key as appropriate.
  NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:YES]];
  fetchRequest.sortDescriptors = sortDescriptors;
  
  // Edit the section name key path and cache name if appropriate.
  // nil for section name key path means "no sections".
  NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                              managedObjectContext:store.context
                                                                                                sectionNameKeyPath:nil cacheName:@"MKTGpxSession"];
  return aFetchedResultsController;
}
@end


