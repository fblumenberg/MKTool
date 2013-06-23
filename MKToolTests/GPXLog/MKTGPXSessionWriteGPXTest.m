//
//  MKTGPXRecordTest.m
//  MKTool
//
//  Created by Frank Blumenberg on 08.05.13.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "YKCLUtils.h"
#import "GHUnit.h"
#import "InnerBand.h"

#import "MKTGpxRecord.h"
#import "MKTGpxSession.h"
#import "MKTGpxSession+GPX.h"
#import "IKNaviData.h"


@interface MKTGPXSessionWriteGPXTest : GHTestCase

@end

@implementation MKTGPXSessionWriteGPXTest

- (void)setUp {
  CoreDataStore *store = [CoreDataStore mainStore];
  [store clearAllData];
}


- (MKTGpxRecord*) createAndFillRecord:(NSUInteger)index{
  
  MKTGpxRecord* record = [MKTGpxRecord create];
  
  record.gpsPos = [[IKGPSPos alloc] initWithCoordinate:CLLocationCoordinate2DMake(48.0, 8.0)];
  record.satellites = @(7);
  
  NSDictionary* extensions = @{
                               @"Altimeter": @(17),
                               @"Set_Altitude": @(14),
                               @"Variometer": @(3),
                               @"Course": @(123),
                               @"VerticalSpeed": @(45),
                               @"FlightTime": [NSString stringWithFormat:@"%02d:%02d", 0, 12],
                               @"Voltage": [NSString stringWithFormat:@"%0.1f", 11.3],
                               @"Current": [NSString stringWithFormat:@"%0.1f", 5.6],
                               @"Capacity": @(1234),
                               
                               @"RCQuality": @(128),
                               @"RSSI": @(128),
                               @"Compass": @(44),
                               @"NickAngle": @(2),
                               @"RollAngle": @(0),
                               
                               @"NCFlags": [NSString stringWithFormat:@"0x%02x", 0x82],
                               @"FCFlags2": [NSString stringWithFormat:@"0x%02x,0x%02x", 0x03,0x06],
                               
                               @"Thrust": @(123),
                               @"ErrorCode": @(0),
                               @"WaypointIndex": @(1),
                               @"WaypointTotal": @(4),
                               @"WaypointHoldTime": [NSString stringWithFormat:@"%02d:%02d", 0,5],
                               @"OperatingRadius": @(135),
                               
                               @"HomeDistance": @(34),
                               @"TargetBearing": @(123),
                               @"TargetDistance": @(11),
                               
                               @"MotorCurrent": @"1,2,3,4,5,6,7,8,0,0,0,0",
                               @"BL_Temperature": @"11,12,13,14,15,16,17,18,0,0,0,0"
                               
                               };
  
  record.extensions = extensions;

  return record;
}

- (void)testSavingSession {
  
  CoreDataStore *store = [CoreDataStore mainStore];
  MKTGpxSession *s = [MKTGpxSession create];
  
  GHAssertNotNil(s.startTime, nil);
  
  MKCoordinateRegion region = {
    CLLocationCoordinate2DMake(48.0, 8.0),
    {
      10.0,11.0
    }
  };
  
  s.endTime = [NSDate date];
  s.region = region;
  
  [store save];
  
  for(int i=0;i<3;i++){
    [s addRecordsObject:[self createAndFillRecord:i]];
  }
  
  
  [store save];
  
  NSArray* sessions = [store allForEntity:[MKTGpxSession entityName] error:nil];
  
  GHAssertEquals(sessions.count, 1U, nil);
  
  MKTGpxSession *s2 = [sessions objectAtIndex:0];
  
  GHAssertEquals(s.region, s2.region, nil);

  NSString *localPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"TEST.gpx"];

  BOOL result = [s writeSessionToGPXFile:localPath];
  
  GHAssertTrue(result, nil);
  
}

@end
