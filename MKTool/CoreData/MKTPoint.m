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

#import "InnerBand.h"
//#import "YKCLUtils.h"
#import "MKTPoint.h"
#import "MKTRoute.h"


@implementation MKTPoint


- (CLLocationCoordinate2D)coordinate {
  return CLLocationCoordinate2DMake(self.latitudeValue, self.longitudeValue);
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate {
  self.longitudeValue = coordinate.longitude;
  self.latitudeValue = coordinate.latitude;
}

- (NSString *)name {
  return [NSString stringWithFormat:@"%@%d", self.prefix, self.indexValue];
}

- (NSString *)title {
  if (self.typeValue == MKTPointTypeWP) {
    return [NSString stringWithFormat:NSLocalizedString(@"%@ - Waypoint", @"WP Annotation callout"), self.name];
  } else if (self.typeValue == MKTPointTypePOI) {
    return [NSString stringWithFormat:NSLocalizedString(@"%@ - POI", @"POI Annotation callout"), self.name];
  }
  return [NSString stringWithFormat:NSLocalizedString(@"%@ - Invalid", @"INvalid WP Annotation callout"), self.name];
}

- (NSString*)subtitle{
  return nil;
}

- (NSString *)formatHeading {
  int heading = self.headingValue;

  if (heading > 0)
    return [NSString stringWithFormat:@"- %d°", heading];

  if (heading < 0)
    return [NSString stringWithFormat:@"- P%d", -heading];

  return @"";
}


- (CLLocationDistance)distanceToPoi{
  if(self.headingValue>=0)
    return 0.0;
  
  MKTPoint* poi=[self.route pointWithIndexx:-(self.headingValue)];
  return YKCLLocationCoordinateDistance(self.coordinate,poi.coordinate,YES);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - 
///////////////////////////////////////////////////////////////////////////////////////////////////

+ (NSDictionary *)attributesForPoint {
  NSEntityDescription *descr = [MKTPoint entityInManagedObjectContext:[CoreDataStore mainStore].context];
  return descr.attributesByName;
}


+ (NSFetchedResultsController *)fetchedResultsControllerForRoute:(MKTRoute *)r {

  CoreDataStore *store = [CoreDataStore mainStore];

  // Create the fetch request for the entity.
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

  fetchRequest.entity = [MKTPoint entityInManagedObjectContext:store.context];
  fetchRequest.fetchBatchSize = 20;
  fetchRequest.predicate = [NSPredicate predicateWithFormat:@"route=%@", r];

  // Edit the sort key as appropriate.
  NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]];
  fetchRequest.sortDescriptors = sortDescriptors;

  // Edit the section name key path and cache name if appropriate.
  // nil for section name key path means "no sections".
  NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                              managedObjectContext:store.context
                                                                                                sectionNameKeyPath:nil cacheName:@"MKTPoint"];

  [NSFetchedResultsController deleteCacheWithName:aFetchedResultsController.cacheName];

  return aFetchedResultsController;
}


@end
