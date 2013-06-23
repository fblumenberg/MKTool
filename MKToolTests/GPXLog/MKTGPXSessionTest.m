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
#import "IKNaviData.h"


@interface MKTGPXSessionTest : GHTestCase

@end

@implementation MKTGPXSessionTest

- (void)setUp {
  CoreDataStore *store = [CoreDataStore mainStore];
  [store clearAllData];
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
  
  NSArray* sessions = [store allForEntity:[MKTGpxSession entityName] error:nil];
  
  GHAssertEquals(sessions.count, 1U, nil);
  
  MKTGpxSession *s2 = [sessions objectAtIndex:0];
  
  GHAssertEquals(s.region, s2.region, nil);
  
}

@end
