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

#import "INIParser.h"
#import "MKTRoute.h"
#import "MKTPoint.h"
#import "MKTRoute+WPL.h"

@interface MKTRouteWplTest : GHTestCase{
  NSString *tmpFile;  
}

@end

@implementation MKTRouteWplTest

- (void)setUp {
  
  CoreDataStore *store = [CoreDataStore mainStore];
  [store clearAllData];

  NSString *tmpDirectory = NSTemporaryDirectory();
  tmpFile = [tmpDirectory stringByAppendingPathComponent:@"temp.txt"];
}

- (void)tearDown {
  NSFileManager* fm = [NSFileManager defaultManager];
  
  if([fm fileExistsAtPath:tmpFile])
    [fm removeItemAtPath:tmpFile error:nil];

  CoreDataStore *store = [CoreDataStore mainStore];
  [store clearAllData];
}

- (void)testReadFile {
  
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *bundlePath = [bundle bundlePath];
  NSLog(@"Bundle: %@", bundle);
  
  NSString *someFile = [bundlePath stringByAppendingPathComponent:@"Test.wpl"];
  NSLog(@"File in Bundle: %@", someFile);
  
  MKTRoute* route = [MKTRoute create];
  
  BOOL result = [route loadRouteFromWplFile:someFile];
  GHAssertTrue(result,nil);
  
  NSArray* points = [route orderedPoints];
  GHAssertEquals(points.count, 4U, nil);
  
  NSArray *results = [points map:(ib_enum_id_t) ^(id obj) {
    MKTPoint* p = obj;
    return p.toleranceRadius;
  }];
  
  NSArray *required = [NSArray arrayWithObjects:BOX_INT(123), BOX_INT(456), BOX_INT(789), BOX_INT(432), nil];
  GHAssertEqualObjects(results, required, nil);
}

- (void)testReadInvalidFile {
  
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *bundlePath = [bundle bundlePath];
  NSLog(@"Bundle: %@", bundle);
  
  NSString *someFile = [bundlePath stringByAppendingPathComponent:@"TestInvalid.wpl"];
  NSLog(@"File in Bundle: %@", someFile);
  
  MKTRoute* route = [MKTRoute create];
  
  BOOL result = [route loadRouteFromWplFile:someFile];
  GHAssertFalse(result,nil);
}

- (void)testReadFileNotExist {
  
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *bundlePath = [bundle bundlePath];
  
  NSString *someFile = [bundlePath stringByAppendingPathComponent:@"TestInvalid-not.wpl"];
  NSLog(@"File in Bundle: %@", someFile);
  
  MKTRoute* route = [MKTRoute create];
  
  BOOL result = [route loadRouteFromWplFile:someFile];
  GHAssertFalse(result,nil);
}

- (void)testWriteFile {
  
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *bundlePath = [bundle bundlePath];
  NSLog(@"Bundle: %@", bundle);
  
  NSString *someFile = [bundlePath stringByAppendingPathComponent:@"Test.wpl"];
  NSLog(@"File in Bundle: %@", someFile);
  
  MKTRoute* route = [MKTRoute create];
  
  BOOL result = [route loadRouteFromWplFile:someFile];
  GHAssertTrue(result,nil);
  
  result = [route writeRouteToWplFile:tmpFile];
  GHAssertTrue(result,nil);

  MKTRoute* route2 = [MKTRoute create];
  
  result = [route2 loadRouteFromWplFile:tmpFile];
  GHAssertTrue(result,nil);
  
  GHAssertEquals(route.points.count, route2.points.count, nil);
  
  NSArray* r1 = [route orderedPoints];
  NSArray* r2 = [route2 orderedPoints];

  for(NSUInteger i=0;i<r1.count;i++ ){
    MKTPoint* p1 = [r1 objectAtIndex:i];
    MKTPoint* p2 = [r2 objectAtIndex:i];
    for (NSString* key in [MKTPoint attributesForPoint].allKeys) {
      GHAssertEqualObjects([p1 valueForKey:key], [p2 valueForKey:key],nil);
      
    }
  }
//  [MKTPoint attributesForPoint] ; 
}


- (void)testWriteFileUmlaute {
  
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *bundlePath = [bundle bundlePath];
  NSLog(@"Bundle: %@", bundle);
  
  NSString *someFile = [bundlePath stringByAppendingPathComponent:@"Test.wpl"];
  NSLog(@"File in Bundle: %@", someFile);
  
  MKTRoute* route = [MKTRoute create];
  
  BOOL result = [route loadRouteFromWplFile:someFile];
  GHAssertTrue(result,nil);
  
  route.name = @"TESTÄÖÜ";
  
  result = [route writeRouteToWplFile:tmpFile];
  GHAssertTrue(result,nil);
  
  MKTRoute* route2 = [MKTRoute create];
  
  result = [route2 loadRouteFromWplFile:tmpFile];
  GHAssertTrue(result,nil);
  
  GHAssertEquals(route.points.count, route2.points.count, nil);
  
  NSArray* r1 = [route orderedPoints];
  NSArray* r2 = [route2 orderedPoints];
  
  for(NSUInteger i=0;i<r1.count;i++ ){
    MKTPoint* p1 = [r1 objectAtIndex:i];
    MKTPoint* p2 = [r2 objectAtIndex:i];
    for (NSString* key in [MKTPoint attributesForPoint].allKeys) {
      GHAssertEqualObjects([p1 valueForKey:key], [p2 valueForKey:key],nil);
      
    }
  }
  //  [MKTPoint attributesForPoint] ; 
}


- (void)testWriteFileCheckType {
  
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *bundlePath = [bundle bundlePath];
  NSLog(@"Bundle: %@", bundle);
  
  NSString *someFile = [bundlePath stringByAppendingPathComponent:@"Test.wpl"];
  NSLog(@"File in Bundle: %@", someFile);
  
  MKTRoute* route = [MKTRoute create];
  
  BOOL result = [route loadRouteFromWplFile:someFile];
  GHAssertTrue(result,nil);

  NSArray* points = [route orderedPoints];
  
  MKTPoint* p;
  
  p = [points objectAtIndex:0];
  GHAssertEquals((MKTPointType)p.typeValue, MKTPointTypeWP, nil);

  p = [points objectAtIndex:1];
  GHAssertEquals((MKTPointType)p.typeValue, MKTPointTypePOI, nil);

  result = [route writeRouteToWplFile:tmpFile];
  GHAssertTrue(result,nil);
  
  
  INIParser* iniParser = [[INIParser alloc] initWithContentsOfFile:tmpFile encoding:NSUTF8StringEncoding error:nil];

  int type = [iniParser getInt:@"Type" section:@"Point1"];
  GHAssertEquals(type,1,nil);
  
  type = [iniParser getInt:@"Type" section:@"Point2"];
  GHAssertEquals(type,2,nil);
}


@end
