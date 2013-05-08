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
#import "IKNaviData.h"


@interface MKTGPXRecordTest : GHTestCase

@end

@implementation MKTGPXRecordTest

- (void)setUp {
  CoreDataStore *store = [CoreDataStore mainStore];
  [store clearAllData];
}

- (void)testWaypointCoordinate {
  
}

@end
