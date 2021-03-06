//
//  WaypointTest.m
//  iKopter
//
//  Created by Frank Blumenberg on 16.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "YKCLUtils.h"
#import "GHUnit.h"
#import "InnerBand.h"

#import "MKTPoint.h"
#import "MKTRoute.h"
#import "MKTPoint+MKTPoint_IKPoint.h"

@interface MKTPointTest : GHTestCase

@end

@implementation MKTPointTest

- (void)setUp {
  CoreDataStore *store = [CoreDataStore mainStore];
  [store clearAllData];
}

- (void)testWaypointCoordinate {

  MKTPoint *p = [MKTPoint create];
  p.latitude = BOX_DOUBLE(49.12345);
  p.longitude = BOX_DOUBLE(8.12345);

  CLLocationCoordinate2D coordinate = p.coordinate;

  GHAssertEquals(p.latitudeValue, coordinate.latitude, nil);
  GHAssertEquals(p.longitudeValue, coordinate.longitude, nil);

  coordinate = CLLocationCoordinate2DMake(50.123456, 9.123456);

  p.coordinate = coordinate;

  GHAssertEquals(p.latitudeValue, coordinate.latitude, nil);
  GHAssertEquals(p.longitudeValue, coordinate.longitude, nil);
}


- (void)testWaypointName {

  MKTPoint *p = [MKTPoint create];

  GHAssertNotNil(p.index, nil);
  GHAssertNotNil(p.prefix, nil);

  p.indexValue = 103;
  GHAssertEqualStrings(p.name, @"P103", nil);

  p.prefix = @"X";
  GHAssertEqualStrings(p.name, @"X103", nil);


//	NSArray *widgets;
//	NSError *error = nil;
//	CoreDataStore *store = [CoreDataStore mainStore];
//  
//	widgets = [store allForEntity:@"MKTPoint" error:&error];
//	GHAssertEquals(0U, widgets.count, nil);
//
//  
//  
//  [store save];
//  
//	widgets = [store allForEntity:@"MKTPoint" error:&error];
//	GHAssertEquals(1U, widgets.count, nil);
//  
//  
//  MKTRoute* r = [MKTRoute create];
//  r.name = @"Test";
//  
//  [r addPointsObject: p];
//
//  [store save];
//  
//  
//  MKTRoute* r2 = (MKTRoute*)[store entityByName:@"MKTRoute" error:&error];
//
//  GHAssertEqualStrings(r.name, r2.name, nil);


  //  
//  CLLocationCoordinate2D coordinate=CLLocationCoordinate2DMake(49.860348,8.686227);
//  MKTPoint* p = [[MKTPoint alloc] initWithCoordinate:coordinate];
//  p.heading=101;
//  p.toleranceRadius=102;
//  p.holdTime=103;
//  p.eventFlag=104;
//  p.index=105;
//  p.type=106;
//  p.wpEventChannelValue=107;
//  p.altitudeRate=108;
//  p.speed=109;
//  p.camAngle=111;
//  p.cameraNickControl=YES;
//  p.prefix = @"X";
//
//  GHAssertEqualStrings(@"X105", p.name,nil);
//
//  p.prefix = @"Y";
//  GHAssertEqualStrings(@"Y105", p.name,nil);
//
//  p.index = 125;
//  GHAssertEqualStrings(@"Y125", p.name,nil);
}

- (void)testWaypointAttributes {

  MKTPoint *p = [MKTPoint create];

  NSMutableDictionary *model = [[MKTPoint attributesForPoint] mutableCopy];
  [model enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    [model setValue:[p valueForKey:key] forKey:key];
  }];


}


- (void)testPoiDistance {

  MKTRoute *r = [MKTRoute create];
  r.name = @"Test";

  CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(49.12345, 8.12345);

  MKTPoint *poi = [r addPointAtCoordinate:coordinate];
  poi.typeValue = MKTPointTypePOI;

  CLLocationCoordinate2D coordinate2 = YKCLLocationCoordinateMoveDistance(coordinate, 100, 0);

  MKTPoint *wp = [r addPointAtCoordinate:coordinate2];
  wp.typeValue = MKTPointTypeWP;
  wp.headingValue = -(poi.indexValue);

  CLLocationDistance d = [wp distanceToPoi];

  GHAssertEqualsWithAccuracy(d, 100.0, 0.05, nil);

  wp.headingValue = 0;
  d = [wp distanceToPoi];
  GHAssertEquals(d, 0.0, nil);

  wp.headingValue = 360;
  d = [wp distanceToPoi];
  GHAssertEquals(d, 0.0, nil);
}

- (void)testIKPointPOIConversion {

  MKTRoute *r = [MKTRoute create];
  r.name = @"Test";

  CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(49.12345, 8.12345);

  MKTPoint *poi = [r addPointAtCoordinate:coordinate];
  poi.typeValue = MKTPointTypePOI;

  poi.altitudeValue = 100;

  IKPoint *ikPoi = [poi toIKPoint];

  GHAssertNotNil(ikPoi, nil);

  GHAssertEquals(poi.latitudeValue, ikPoi.coordinate.latitude, nil);
  GHAssertEquals(poi.longitudeValue, ikPoi.coordinate.longitude, nil);

  GHAssertEquals((NSInteger) poi.altitudeValue, ikPoi.altitude, nil);

  GHAssertEquals((NSInteger) poi.altitudeRateValue, ikPoi.altitudeRate, nil);
  GHAssertEquals((NSInteger) poi.cameraAngleValue, ikPoi.camAngle, nil);
  GHAssertEquals((NSInteger) poi.eventChannelValueValue, ikPoi.wpEventChannelValue, nil);

  GHAssertEquals((NSInteger) poi.eventFlagValue, ikPoi.eventFlag, nil);
  GHAssertEquals((NSInteger) poi.headingValue, ikPoi.heading, nil);
  GHAssertEquals((NSInteger) poi.holdTimeValue, ikPoi.holdTime, nil);
  GHAssertEquals((NSInteger) poi.indexValue, ikPoi.index, nil);

  GHAssertEqualStrings(poi.prefix, ikPoi.prefix, nil);
  GHAssertEquals((NSInteger) poi.speedValue, ikPoi.speed, nil);
  GHAssertEquals((NSInteger) poi.typeValue, ikPoi.type, nil);
  GHAssertEquals((NSInteger) poi.toleranceRadiusValue, ikPoi.toleranceRadius, nil);

  GHAssertEqualStrings(poi.name, ikPoi.name, nil);
}

- (void)testIKPointWPConversion {

  MKTRoute *r = [MKTRoute create];
  r.name = @"Test";

  CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(49.12345, 8.12345);

  MKTPoint *poi = [r addPointAtCoordinate:coordinate];
  poi.typeValue = MKTPointTypeWP;

  poi.altitudeValue = 100;

  IKPoint *ikPoi = [poi toIKPoint];

  GHAssertNotNil(ikPoi, nil);

  GHAssertEquals(poi.latitudeValue, ikPoi.coordinate.latitude, nil);
  GHAssertEquals(poi.longitudeValue, ikPoi.coordinate.longitude, nil);

  GHAssertEquals((NSInteger) poi.altitudeValue, ikPoi.altitude, nil);

  GHAssertEquals((NSInteger) poi.altitudeRateValue, ikPoi.altitudeRate, nil);
  GHAssertEquals((NSInteger) poi.cameraAngleValue, ikPoi.camAngle, nil);
  GHAssertEquals((NSInteger) poi.eventChannelValueValue, ikPoi.wpEventChannelValue, nil);

  GHAssertEquals((NSInteger) poi.eventFlagValue, ikPoi.eventFlag, nil);
  GHAssertEquals((NSInteger) poi.headingValue, ikPoi.heading, nil);
  GHAssertEquals((NSInteger) poi.holdTimeValue, ikPoi.holdTime, nil);
  GHAssertEquals((NSInteger) poi.indexValue, ikPoi.index, nil);

  GHAssertEqualStrings(poi.prefix, ikPoi.prefix, nil);
  GHAssertEquals((NSInteger) poi.speedValue, ikPoi.speed, nil);
  GHAssertEquals((NSInteger) poi.typeValue, ikPoi.type, nil);
  GHAssertEquals((NSInteger) poi.toleranceRadiusValue, ikPoi.toleranceRadius, nil);

  GHAssertEqualStrings(poi.name, ikPoi.name, nil);
}


@end
