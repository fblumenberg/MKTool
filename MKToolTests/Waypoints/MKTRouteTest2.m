//
//  WaypointTest.m
//  iKopter
//
//  Created by Frank Blumenberg on 16.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "GHUnit.h"
#import "YKCLUtils.h"
#import "InnerBand.h"

#import "MKTPoint.h"
#import "MKTRoute.h"

@interface MKTRouteTest2 : GHTestCase

- (MKTRoute *)addRouteWithName:(NSString *)name;
- (MKTRoute *)addRouteWithName:(NSString *)name numberOfPoints:(NSInteger)count prefix:(NSString *)prefix;
@end

@implementation MKTRouteTest2

- (void)setUp {
  CoreDataStore *store = [CoreDataStore mainStore];
  [store clearAllData];
}

- (void)testRouteAdding {

  [self addRouteWithName:@"PRE-TEST" numberOfPoints:10 prefix:@"R"];

  CoreDataStore *store = [CoreDataStore mainStore];
  MKTRoute *r = [MKTRoute create];
  r.name = @"Test";

  CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(50.123456, 9.123456);

  for (int i = 1; i < 7; i++) {
    MKTPoint *p = [r addPointAtCoordinate:coordinate];
    p.prefix = @"X";
    p.indexValue = i;
    p.speedValue = i;
  }

  [store save];
    
  GHAssertNotNil(r.lastUpdated,nil);
  
  NSDate* d=r.lastUpdated;
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"route=%@", r];
  NSArray *points = [MKTPoint allForPredicate:predicate];

  GHAssertNotNil(points, nil);
  GHAssertEquals(r.points.count, points.count, nil);

  for (MKTPoint *pt in points) {
    GHAssertEqualStrings(pt.prefix, @"X", nil);
  }
  
  sleep(1);
  
  r.name = @"Test2";
  
  GHAssertEqualObjects(r.lastUpdated, d, nil);
  
  [store save];

  NSComparisonResult res = [r.lastUpdated compare:d];

  GHAssertEquals(res, NSOrderedDescending, nil);
    
}

- (void)testRouteAddingWithGivenDate {
  
  CoreDataStore *store = [CoreDataStore mainStore];
  MKTRoute *r = [MKTRoute create];
  r.name = @"Test";
  
  [store save];
  
  GHAssertNotNil(r.lastUpdated,nil);
  
  NSDate* date = [NSDate dateWithTimeIntervalSinceNow:-3600];
  r.lastUpdated = date;
  r.name = @"Foo";
  [store save];

  GHAssertEqualObjects(r.lastUpdated, date, nil);
  
}

- (void)testRouteFilename {
  
  MKTRoute *r = [MKTRoute create];
  r.name = @"Test";
  
  MKTRoute *r2 = [MKTRoute create];
  r2.name = @"Test";
  
  GHAssertEqualStrings(r.name, r2.name, nil);
  GHAssertNotEqualStrings(r.fileName, r2.fileName,nil);
}

- (void)testAddingPointToRoute {

  [self addRouteWithName:@"PRE-TEST"];

  MKTPoint *p;
  CoreDataStore *store = [CoreDataStore mainStore];

  MKTRoute *r = [MKTRoute create];
  r.name = @"Test";

  [store save];

  CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(50.123456, 9.123456);
  p = [r addPointAtCoordinate:coordinate];
  p.speedValue = 1;

  p = [r addPointAtCoordinate:coordinate];
  p.speedValue = 2;

  p = [r addPointAtCoordinate:coordinate];
  p.speedValue = 3;

  GHAssertEquals(3U, [r count], nil);

  NSArray *results = [[r orderedPoints] map:(ib_enum_id_t) ^(id obj) {
    return [(MKTPoint *) obj speed];
  }];
  NSArray *required = [NSArray arrayWithObjects:BOX_INT(1), BOX_INT(2), BOX_INT(3), nil];
  GHAssertEqualObjects(results, required, nil);
}

- (void)testDeletingPointFromRoute {

  [self addRouteWithName:@"PRE-TEST"];

  MKTPoint *p;
  CoreDataStore *store = [CoreDataStore mainStore];

  MKTRoute *r = [MKTRoute create];
  r.name = @"Test";

  [store save];

  CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(50.123456, 9.123456);
  p = [r addPointAtCoordinate:coordinate];
  p.speedValue = 1;

  p = [r addPointAtCoordinate:coordinate];
  p.speedValue = 2;

  p = [r addPointAtCoordinate:coordinate];
  p.speedValue = 3;

  GHAssertEquals(3U, [r count], nil);

  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
  [r deletePointAtIndexPath:indexPath];

  GHAssertEquals(2U, [r count], nil);

  NSArray *results = [[r orderedPoints] map:(ib_enum_id_t) ^(id obj) {
    return [(MKTPoint *) obj speed];
  }];

  NSArray *required = [NSArray arrayWithObjects:BOX_INT(1), BOX_INT(3), nil];
  GHAssertEqualObjects(results, required, nil);

  int i = 1;
  for (MKTPoint *pt in [r orderedPoints]) {
    GHAssertEquals((int) (pt.indexValue), i++, nil);
  }
}


- (void)testDeletingPointFromRouteHeading {

  [self addRouteWithName:@"PRE-TEST"];

  MKTPoint *p;
  CoreDataStore *store = [CoreDataStore mainStore];

  MKTRoute *r = [MKTRoute create];
  r.name = @"Test";

  [store save];

  CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(50.123456, 9.123456);
  p = [r addPointAtCoordinate:coordinate];
  p.speedValue = 1;
  p.headingValue = -2;

  p = [r addPointAtCoordinate:coordinate];
  p.speedValue = 2;

  p = [r addPointAtCoordinate:coordinate];
  p.speedValue = 3;
  p.headingValue = -1;

  GHAssertEquals(3U, [r count], nil);

  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
  [r deletePointAtIndexPath:indexPath];

  GHAssertEquals(2U, [r count], nil);

  NSArray *results = [[r orderedPoints] map:(ib_enum_id_t) ^(id obj) {
    return [(MKTPoint *) obj heading];
  }];

  NSArray *required = [NSArray arrayWithObjects:BOX_INT(0), BOX_INT(-1), nil];
  GHAssertEqualObjects(results, required, nil);

  int i = 1;
  for (MKTPoint *pt in [r orderedPoints]) {
    GHAssertEquals((int) (pt.indexValue), i++, nil);
  }
}


- (void)testMovingPointInRoute {

  [self addRouteWithName:@"PRE-TEST"];

  MKTPoint *p;
  CoreDataStore *store = [CoreDataStore mainStore];

  MKTRoute *r = [MKTRoute create];
  r.name = @"Test";

  [store save];

  CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(50.123456, 9.123456);
  p = [r addPointAtCoordinate:coordinate];
  p.speedValue = 1;

  p = [r addPointAtCoordinate:coordinate];
  p.speedValue = 2;

  p = [r addPointAtCoordinate:coordinate];
  p.speedValue = 3;

  p = [r addPointAtCoordinate:coordinate];
  p.speedValue = 4;

  GHAssertEquals(4U, [r count], nil);

  NSIndexPath *fromPath = [NSIndexPath indexPathForRow:0 inSection:0];
  NSIndexPath *toPath = [NSIndexPath indexPathForRow:2 inSection:0];

  [r movePointAtIndexPath:fromPath toIndexPath:toPath];

  GHAssertEquals(4U, [r count], nil);

  NSArray *results = [[r orderedPoints] map:(ib_enum_id_t) ^(id obj) {
    return [(MKTPoint *) obj speed];
  }];
  NSArray *required = [NSArray arrayWithObjects:BOX_INT(2), BOX_INT(3), BOX_INT(1), BOX_INT(4), nil];
  GHAssertEqualObjects(results, required, nil);

  int i = 1;
  for (MKTPoint *pt in [r orderedPoints]) {
    GHAssertEquals((int) (pt.indexValue), i++, nil);
  }
}

- (void)testMovingPointInRouteHeading {

  MKTPoint *p;
  CoreDataStore *store = [CoreDataStore mainStore];

  MKTRoute *r = [MKTRoute create];
  r.name = @"Test";

  [store save];

  CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(50.123456, 9.123456);
  p = [r addPointAtCoordinate:coordinate];
  p.speedValue = 1;

  p = [r addPointAtCoordinate:coordinate];
  p.speedValue = 2;
  p.headingValue = -1;

  p = [r addPointAtCoordinate:coordinate];
  p.speedValue = 3;
  p.headingValue = -1;

  p = [r addPointAtCoordinate:coordinate];
  p.speedValue = 4;

  GHAssertEquals(4U, [r count], nil);

  NSIndexPath *fromPath = [NSIndexPath indexPathForRow:0 inSection:0];
  NSIndexPath *toPath = [NSIndexPath indexPathForRow:2 inSection:0];

  [r movePointAtIndexPath:fromPath toIndexPath:toPath];

  GHAssertEquals(4U, [r count], nil);

  NSArray *results = [[r orderedPoints] map:(ib_enum_id_t) ^(id obj) {
    return [(MKTPoint *) obj heading];
  }];
//NSArray* required = [NSArray arrayWithObjects:BOX_INT(2),BOX_INT(3),BOX_INT(1),BOX_INT(4), nil]; 
  NSArray *required = [NSArray arrayWithObjects:BOX_INT(-3), BOX_INT(-3), BOX_INT(0), BOX_INT(0), nil];
  GHAssertEqualObjects(results, required, nil);

  int i = 1;
  for (MKTPoint *pt in [r orderedPoints]) {
    GHAssertEquals((int) (pt.indexValue), i++, nil);
  }
}

- (void)testFetchController {
  MKTRoute *route1 = [self addRouteWithName:@"route1" numberOfPoints:8 prefix:@"A"];
  MKTRoute *route2 = [self addRouteWithName:@"route2" numberOfPoints:5 prefix:@"B"];
  MKTRoute *route3 = [self addRouteWithName:@"route3" numberOfPoints:11 prefix:@"C"];

  CoreDataStore *store = [CoreDataStore mainStore];
  [store save];

  NSFetchedResultsController *ctrl;
  NSError *error = nil;

  ctrl = [MKTPoint fetchedResultsControllerForRoute:route1];
  GHAssertTrue([ctrl performFetch:&error], nil);
  id points = [ctrl fetchedObjects];
  id <NSFetchedResultsSectionInfo> sectionInfo = [ctrl.sections objectAtIndex:0];

  GHAssertEquals([sectionInfo numberOfObjects], 8U, nil);
  for (MKTPoint *pt in points) {
    GHAssertEqualStrings(pt.prefix, @"A", nil);
  }

  ctrl = [MKTPoint fetchedResultsControllerForRoute:route2];
  GHAssertTrue([ctrl performFetch:&error], nil);
  points = [ctrl fetchedObjects];
  sectionInfo = [ctrl.sections objectAtIndex:0];

  GHAssertEquals([sectionInfo numberOfObjects], 5U, nil);
  for (MKTPoint *pt in points) {
    GHAssertEqualStrings(pt.prefix, @"B", nil);
  }

  ctrl = [MKTPoint fetchedResultsControllerForRoute:route3];
  GHAssertTrue([ctrl performFetch:&error], nil);
  points = [ctrl fetchedObjects];
  sectionInfo = [ctrl.sections objectAtIndex:0];

  GHAssertEquals([sectionInfo numberOfObjects], 11U, nil);
  for (MKTPoint *pt in points) {
    GHAssertEqualStrings(pt.prefix, @"C", nil);
  }

}

- (void)testThumbnail {
  CoreDataStore *store = [CoreDataStore mainStore];
  MKTRoute *r = [MKTRoute create];
  r.name = @"Test";
  
  [store save];
  
  UIImage* img1 = [UIImage imageNamed:@"icon-calculate@2x.png"];
  GHAssertNotNil(img1,nil);
  
  r.thumbnail = img1;

  GHAssertNotNil(r.thumbnail,nil);
  
  MKTRoute *r2 = [[MKTRoute allForPredicate:[NSPredicate predicateWithFormat:@"name=%@",r.name]] firstObject];
  
  GHAssertNotNil(r2,nil);
  
  NSData* imgData1 = UIImagePNGRepresentation(img1);
  NSData* imgData2 = UIImagePNGRepresentation(r2.thumbnail);
  
  GHAssertEqualObjects(imgData1, imgData2, nil);
  
}

- (void)testCounting {
  MKTRoute *r = [MKTRoute create];
  r.name = @"TESTCOUNT";
  
  MKTPoint *p;
  CoreDataStore *store = [CoreDataStore mainStore];

  p = [r addPointAtDefault];
  p.typeValue = MKTPointTypeWP;
  p = [r addPointAtDefault];
  p.typeValue = MKTPointTypeWP;
  p = [r addPointAtDefault];
  p.typeValue = MKTPointTypeWP;
  
  p = [r addPointAtDefault];
  p.typeValue = MKTPointTypePOI;
  p = [r addPointAtDefault];
  p.typeValue = MKTPointTypePOI;

  [store save];
  
  MKTRoute *r2 = [[MKTRoute allForPredicate:[NSPredicate predicateWithFormat:@"name=%@",r.name]] firstObject];
  
  GHAssertNotNil(r2,nil);
  
  GHAssertEquals([r2 count], 5U, nil);
  GHAssertEquals([r2 countWP], 3U, nil);
  GHAssertEquals([r2 countPOI], 2U, nil);
  
  
}


- (void)testRouteDistance{
  
  MKTRoute *r = [MKTRoute create];
  r.name = @"Test";
  
  CLLocationDistance d;
  
  d = [r routeDistance];
  GHAssertEquals(d,0.0,nil);
  
  CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(49.12345, 8.12345);
  CLLocationCoordinate2D coordinatePOI = CLLocationCoordinate2DMake(49.12345, 8.12345);
  
  MKTPoint* wp = [r addPointAtCoordinate:coordinate];
  wp.typeValue = MKTPointTypeWP;

  d = [r routeDistance];
  GHAssertEquals(d,0.0,nil);
  
  
  coordinate = YKCLLocationCoordinateMoveDistance(coordinate,100,0);
  d = YKCLLocationCoordinateDistance(wp.coordinate, coordinate, YES);
  GHAssertEqualsWithAccuracy(d,100.0,0.05,nil);

  
  wp = [r addPointAtCoordinate:coordinate];
  wp.typeValue = MKTPointTypeWP;
  
  d = [r routeDistance];
  GHAssertEqualsWithAccuracy(d,100.0,0.05,nil);

  wp = [r addPointAtCoordinate:coordinatePOI];
  wp.typeValue = MKTPointTypePOI;
  
  d = [r routeDistance];
  GHAssertEqualsWithAccuracy(d,100.0,0.05,nil);

  coordinate = YKCLLocationCoordinateMoveDistance(coordinate,100,0);
  wp = [r addPointAtCoordinate:coordinate];
  wp.typeValue = MKTPointTypeWP;
  
  d = [r routeDistance];
  GHAssertEqualsWithAccuracy(d,200.0,0.05,nil);
}


- (void)testRouteDurationFromCoordinate{
  
  CLLocationCoordinate2D coordinateStart = CLLocationCoordinate2DMake(49.12345, 8.12345);

  MKTRoute *r = [MKTRoute create];
  r.name = @"Test";
  
  NSUInteger d;
  NSUInteger dReq=0;
  
  d = [r routeDurationFromCoordinate:coordinateStart];
  GHAssertEquals(d,0U,nil);
  
  CLLocationCoordinate2D coordinate = YKCLLocationCoordinateMoveDistance(coordinateStart,100,0);
  CLLocationCoordinate2D coordinatePOI = CLLocationCoordinate2DMake(49.12345, 8.12345);
  
  MKTPoint* wp = [r addPointAtCoordinate:coordinate];
  wp.typeValue = MKTPointTypeWP;
  wp.speedValue = 10;
  wp.holdTimeValue = 5;
  
  d = [r routeDurationFromCoordinate:YKCLLocationCoordinate2DNull];
  dReq = 5U;
  GHAssertEquals(d,dReq,nil);
  
  d = [r routeDurationFromCoordinate:coordinateStart];
  dReq = (100/10) + 5U;
  GHAssertEquals(d,dReq,nil);
  
  coordinate = YKCLLocationCoordinateMoveDistance(coordinate,100,0);
  wp = [r addPointAtCoordinate:coordinate];
  wp.typeValue = MKTPointTypeWP;
  wp.speedValue = 10;
  wp.holdTimeValue = 5;
  
  d = [r routeDurationFromCoordinate:coordinateStart];
  dReq = (100/10) + 5 + (100/10) + 5;
  GHAssertEquals(d,dReq,nil);
  
  wp = [r addPointAtCoordinate:coordinatePOI];
  wp.typeValue = MKTPointTypePOI;
  
  d = [r routeDurationFromCoordinate:coordinateStart];
  dReq = (100/10) + 5 + (100/10) + 5;
  GHAssertEquals(d,dReq,nil);
  
  coordinate = YKCLLocationCoordinateMoveDistance(coordinate,100,0);
  wp = [r addPointAtCoordinate:coordinate];
  wp.typeValue = MKTPointTypeWP;
  wp.speedValue = 10;
  wp.holdTimeValue = 5;
  
  d = [r routeDurationFromCoordinate:coordinateStart];
  dReq = (100/10) + 5 + (100/10) + 5 + (100/10) + 5;
  GHAssertEquals(d,dReq,nil);
  
}


- (void)testRouteDuration{
  
  MKTRoute *r = [MKTRoute create];
  r.name = @"Test";
  
  NSUInteger d;
  NSUInteger dReq=0;
  
  d = [r routeDuration];
  GHAssertEquals(d,0U,nil);
  
  CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(49.12345, 8.12345);
  CLLocationCoordinate2D coordinatePOI = CLLocationCoordinate2DMake(49.12345, 8.12345);
  
  MKTPoint* wp = [r addPointAtCoordinate:coordinate];
  wp.typeValue = MKTPointTypeWP;
  wp.speedValue = 10;
  wp.holdTimeValue = 5;
  
  d = [r routeDuration];
  dReq = 5U;
  GHAssertEquals(d,dReq,nil);

  coordinate = YKCLLocationCoordinateMoveDistance(coordinate,100,0);
  wp = [r addPointAtCoordinate:coordinate];
  wp.typeValue = MKTPointTypeWP;
  wp.speedValue = 10;
  wp.holdTimeValue = 5;
  
  d = [r routeDuration];
  dReq = 5 + (100/10) + 5;
  GHAssertEquals(d,dReq,nil);
  
  wp = [r addPointAtCoordinate:coordinatePOI];
  wp.typeValue = MKTPointTypePOI;

  d = [r routeDuration];
  dReq = 5 + (100/10) + 5;
  GHAssertEquals(d,dReq,nil);

  coordinate = YKCLLocationCoordinateMoveDistance(coordinate,100,0);
  wp = [r addPointAtCoordinate:coordinate];
  wp.typeValue = MKTPointTypeWP;
  wp.speedValue = 10;
  wp.holdTimeValue = 5;
  
  d = [r routeDuration];
  dReq = 5 + (100/10) + 5 + (100/10) + 5;
  GHAssertEquals(d,dReq,nil);

}


- (MKTRoute *)addRouteWithName:(NSString *)name {
  return [self addRouteWithName:name numberOfPoints:10 prefix:@"T"];
}

- (MKTRoute *)addRouteWithName:(NSString *)name numberOfPoints:(NSInteger)count prefix:(NSString *)prefix {
  MKTPoint *p;
  CoreDataStore *store = [CoreDataStore mainStore];

  MKTRoute *r = [MKTRoute create];
  r.name = name;

  CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(50.123456, 9.123456);

  for (int i = 1; i <= count; i++) {
    p = [r addPointAtCoordinate:coordinate];
    p.prefix = prefix;
    p.indexValue = i;
    p.speedValue = i;
  }

  [store save];

  return r;
}

@end
