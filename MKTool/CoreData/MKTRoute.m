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

#import "MKTRoute.h"
#import "MKTPoint.h"

@interface MKTRoute ()

- (void)updatePointsOrder;

@end

@implementation MKTRoute

- (void)awakeFromInsert{
  [super awakeFromInsert];
  // Create universally unique identifier (object)
  CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
  // Get the string representation of CFUUID object.
  NSString *uuidStr = (__bridge NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
  CFRelease(uuidObject);

  [self setPrimitiveFileName:[uuidStr stringByAppendingPathExtension:@"wpl"] ];
}

- (void) willSave{
  [super willSave];
  
  if(self.isUpdated || self.isInserted){
    if([self.changedValues objectForKey:@"lastUpdated"]==nil){
      NSTimeInterval t=(NSTimeInterval)((NSInteger)[[NSDate date] timeIntervalSinceReferenceDate]);
      NSDate* d = [NSDate dateWithTimeIntervalSinceReferenceDate:t];
      [self setPrimitiveLastUpdated:d];
    }
  }
}


+ (CLLocationCoordinate2D)defaultCoordinate {

  double latitude = [[[NSUserDefaults standardUserDefaults] stringForKey:@"WpDefaultCoordLat"] doubleValue];
  double longitude = [[[NSUserDefaults standardUserDefaults] stringForKey:@"WpDefaultCoordLong"] doubleValue];

  return CLLocationCoordinate2DMake(latitude, longitude);
}

- (NSArray *)orderedPoints {

  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"route=%@", self];
  return [MKTPoint allForPredicate:predicate orderBy:@"index" ascending:YES];
}

- (NSUInteger)count {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"route=%@", self];
  return [MKTPoint countForPredicate:predicate];
}

- (void)updatePointsOrder {
  int i = 0;
  for (MKTPoint *p in [self orderedPoints]) {
    p.indexValue = ++i;
  }
}

- (MKTPoint *)addPointAtCoordinate:(CLLocationCoordinate2D)coordinate {

  MKTPoint *p = [MKTPoint create];
  p.coordinate = coordinate;
  p.indexValue = 9999;
  p.headingValue = 0; 
  p.altitudeValue = [[[NSUserDefaults standardUserDefaults] stringForKey:@"WpDefaultAltitude"] integerValue];
  p.toleranceRadiusValue = [[[NSUserDefaults standardUserDefaults] stringForKey:@"WpDefaultToleranceRadius"] integerValue];
  p.holdTimeValue = [[[NSUserDefaults standardUserDefaults] stringForKey:@"WpDefaultHoldTime"] integerValue];
  p.typeValue = MKTPointTypeWP;                
  p.eventChannelValueValue = 0;
  p.altitudeRateValue = [[[NSUserDefaults standardUserDefaults] stringForKey:@"WpDefaultAltitudeRate"] integerValue];
  p.speedValue = [[[NSUserDefaults standardUserDefaults] stringForKey:@"WpDefaultSpeed"] integerValue];
  p.cameraAngleValue = [[[NSUserDefaults standardUserDefaults] stringForKey:@"WpDefaultCamAngle"] integerValue];;
  p.eventFlagValue = 0;          
  p.prefix = [[NSUserDefaults standardUserDefaults] stringForKey:@"WpDefaultPrefix"];

  [self addPointsObject:p];
  [self updatePointsOrder];

  [[CoreDataStore mainStore] save];
  return p;
}

- (MKTPoint *)addPointAtDefault {
  return [self addPointAtCoordinate:[MKTRoute defaultCoordinate]];
}

- (MKTPoint *)addPointAtCenter {

  if ([self.points count] > 1) {
    CLLocationDegrees latMin = 360.0;
    CLLocationDegrees latMax = -360.0;
    CLLocationDegrees longMin = 360.0;
    CLLocationDegrees longMax = -360.0;

    for (MKTPoint *p in self.points) {
      latMax = MAX(latMax, p.coordinate.latitude);
      latMin = MIN(latMin, p.coordinate.latitude);
      longMax = MAX(longMax, p.coordinate.longitude);
      longMin = MIN(longMin, p.coordinate.longitude);
    }

    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latMin + (latMax - latMin) / 2.0, longMin + (longMax - longMin) / 2.0);
    return [self addPointAtCoordinate:coordinate];
  }
  else if ([self.points count] == 1) {
    MKTPoint *p = [self.points anyObject];
    return [self addPointAtCoordinate:p.coordinate];
  }

  return [self addPointAtDefault];
}


- (void)movePointAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
  NSMutableArray *array = [[self orderedPoints] mutableCopy];

  MKTPoint *objectToMove = [array objectAtIndex:fromIndexPath.row];
  [array removeObjectAtIndex:fromIndexPath.row];
  [array insertObject:objectToMove atIndex:toIndexPath.row];


  NSMutableDictionary *headingMap = [NSMutableDictionary dictionaryWithCapacity:[array count]];
  [array enumerateObjectsUsingBlock:^(MKTPoint *p, NSUInteger idx, BOOL *stop) {
    [headingMap setObject:BOX_INT(idx + 1) forKey:p.index];
    p.indexValue = idx + 1;
  }];

  for (MKTPoint *pointToMove in array) {
    if (pointToMove.headingValue < 0) {
      NSNumber *key = BOX_INT(-pointToMove.headingValue);
      pointToMove.headingValue = -[[headingMap objectForKey:key] integerValue];
    }
  }

  [[CoreDataStore mainStore] save];
}

- (void)deletePoint:(MKTPoint*)p{
  
  int oldIndex = p.indexValue;
  [p destroy];
  
  for (MKTPoint *p in [self orderedPoints]) {
    if (p.headingValue < 0 && p.headingValue == -oldIndex) {
      p.headingValue = 0;
    }
  }
  
  [self updatePointsOrder];
  [[CoreDataStore mainStore] save];
}

- (void)deletePointAtIndexPath:(NSIndexPath *)indexPath {
  MKTPoint *p = [[self orderedPoints] objectAtIndex:indexPath.row];
  [self deletePoint:p];
}


- (void)deletePointsAtIndexPaths:(NSArray *)indexPaths {

  NSArray *orderedPoints = [self orderedPoints];
  NSArray *pointsToDelete = [indexPaths map:(ib_enum_id_t) ^(NSIndexPath *obj) {
    return [orderedPoints objectAtIndex:obj.row];
  }];

  for (MKTPoint *p in pointsToDelete) {
    int oldIndex = p.indexValue;
    [p destroy];

    for (MKTPoint *p in [self orderedPoints]) {
      if (p.headingValue < 0 && p.headingValue == -oldIndex) {
        p.headingValue = 0;
      }
    }
  }

  [self updatePointsOrder];
  [[CoreDataStore mainStore] save];
}

- (MKTPoint *)pointWithIndexx:(int)index{
  NSArray* orderedPoints = [self orderedPoints];
  if(index<1 || index >= orderedPoints.count)
    return nil;
  
  return [orderedPoints objectAtIndex:index-1];
}


- (void)addPointsFromArray:(NSArray*)array{
  
  for (MKTPoint* p in array) {
    [self addPointsObject:p];
    [self updatePointsOrder];
  }
}

- (void)removeAllPoints{
  [self removePoints:self.points];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - 
///////////////////////////////////////////////////////////////////////////////////////////////////

+ (NSFetchedResultsController *)fetchedResultsController {

  CoreDataStore *store = [CoreDataStore mainStore];

  // Create the fetch request for the entity.
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

  fetchRequest.entity = [MKTRoute entityInManagedObjectContext:store.context];
  fetchRequest.fetchBatchSize = 20;

  // Edit the sort key as appropriate.
  NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]];
  fetchRequest.sortDescriptors = sortDescriptors;

  // Edit the section name key path and cache name if appropriate.
  // nil for section name key path means "no sections".
  NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                              managedObjectContext:store.context
                                                                                                sectionNameKeyPath:nil cacheName:@"Root"];
  return aFetchedResultsController;
}

+ (NSDictionary *)attributesForRoute {
  NSEntityDescription *descr = [MKTRoute entityInManagedObjectContext:[CoreDataStore mainStore].context];
  return descr.attributesByName;
}

@end
