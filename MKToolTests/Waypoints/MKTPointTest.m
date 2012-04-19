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
#import "InnerBand.h"

#import "MKTPoint.h"
#import "MKTRoute.h"

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

@end
