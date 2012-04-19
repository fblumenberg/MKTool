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
#import "MKTRoute+Test.h"

@interface MKTRoute_TestTest : GHTestCase

@end

@implementation MKTRoute_TestTest

- (void)setUp {
  CoreDataStore *store = [CoreDataStore mainStore];
  [store clearAllData];
}

- (void)testRouteHasEqualValuesTo {

  MKTRoute *r1 = [MKTRoute addRouteWithName:@"TEST123" numberOfPoints:12 prefix:@"X"];
  MKTRoute *r2 = [MKTRoute addRouteWithName:@"TEST123" numberOfPoints:12 prefix:@"X"];
  
  r2.fileName = r1.fileName;
  
  GHAssertTrue([r1 hasEqualValuesTo:r2],nil);
}

@end
