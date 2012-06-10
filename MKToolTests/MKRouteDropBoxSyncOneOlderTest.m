//
//  WaypointTest.m
//  iKopter
//
//  Created by Frank Blumenberg on 16.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "DropboxSDK/DropboxSDK.h"

#import "GHUnit.h"
#import "InnerBand.h"

#import "MKTDropboxBaseTest.h"

#import "INIParser.h"
#import "MKTRoute.h"
#import "MKTPoint.h"

#import "MKTRouteDropboxController.h"

#define kIKDropboxPath @"MKToolTest"

@interface MKRouteDropBoxSyncOneOlderTest : MKTDropboxBaseTest<MKTRouteDropboxControllerDelegate> {
  NSString *tmpFile;  
  NSString *dataPath;
  UIViewController* view;

}

- (MKTRoute *)addRouteWithName:(NSString *)name numberOfPoints:(NSInteger)count prefix:(NSString *)prefix;

@end

@implementation MKRouteDropBoxSyncOneOlderTest

- (void)setUp {
  view = [[[[UIApplication sharedApplication] delegate] window]rootViewController];

  NSString *tmpDirectory = NSTemporaryDirectory();
  tmpFile = [tmpDirectory stringByAppendingPathComponent:@"temp.txt"];
  
  CoreDataStore *store = [CoreDataStore mainStore];
  [store clearAllData];
  
  dataPath = @"/RouteDataTest";
}

- (void)tearDown {
  NSFileManager* fm = [NSFileManager defaultManager];
     
  if([fm fileExistsAtPath:tmpFile])
    [fm removeItemAtPath:tmpFile error:nil];
  
  [self deletePath:dataPath];
}

- (void)testDBSync {
  
  GHFail(@"No Dropbox");

  GHAssertNotNil([DBSession sharedSession],nil);
  
  MKTRouteDropboxController* c = [MKTRouteDropboxController new];
  c.delegate=self;
  c.dataPath=dataPath;
    
  [self prepare];
  [c connectAndPrepareMetadataFromController:view];
  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:30.0];
  
  CoreDataStore *store = [CoreDataStore mainStore];
  MKTRoute* r = [self addRouteWithName:@"TEST" numberOfPoints:10 prefix:@"T"];

  [store save];
  
  [self prepare];
  [c syncronizeRoute:r withOption:MKTRouteDropboxSyncOverrideRemote fromController:view];
  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:30.0];

  [self checkFileExitstance:[dataPath stringByAppendingPathComponent:r.fileName]];
  GHAssertEqualStrings(self.fileMetaData.filename, r.fileName,nil);
  GHAssertEqualStrings(self.fileMetaData.rev, r.parentRev,nil);
  GHAssertEqualObjects(self.fileMetaData.lastModifiedDate, r.lastUpdated,nil);

  // make local older and different rev. Different rev means DB is newer
  r.name =@"TEST2";
  r.parentRev = @"0";
  r.lastUpdated = [r.lastUpdated dateByAddingTimeInterval:-3600];
  [store save];

  [self checkFileExitstance:[dataPath stringByAppendingPathComponent:r.fileName]];
  GHAssertEqualStrings(self.fileMetaData.filename, r.fileName,nil);
  GHAssertNotEqualStrings(self.fileMetaData.rev, r.parentRev,nil);
  GHAssertNotEqualObjects(self.fileMetaData.lastModifiedDate, r.lastUpdated,nil);
  GHAssertEquals([r.lastUpdated compare:self.fileMetaData.lastModifiedDate], NSOrderedAscending,nil);

  [self prepare];
  [c syncronizeRoute:r withOption:MKTRouteDropboxSyncOverrideOlder fromController:view];
  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:30.0];
  
  GHAssertEqualStrings(r.name, @"TEST",nil);

  [self checkFileExitstance:[dataPath stringByAppendingPathComponent:r.fileName]];
  GHAssertEqualStrings(self.fileMetaData.filename, r.fileName,nil);
  GHAssertEqualStrings(self.fileMetaData.rev, r.parentRev,nil);
  GHAssertEqualObjects(self.fileMetaData.lastModifiedDate, r.lastUpdated,nil);

  // now change the local one
  r.name =@"TEST2";
  [store save];
  
  [self checkFileExitstance:[dataPath stringByAppendingPathComponent:r.fileName]];

  GHAssertEqualStrings(self.fileMetaData.filename, r.fileName,nil);
  GHAssertEqualStrings(self.fileMetaData.rev, r.parentRev,nil);
  GHAssertNotEqualObjects(self.fileMetaData.lastModifiedDate, r.lastUpdated,nil);
  GHAssertEquals([r.lastUpdated compare:self.fileMetaData.lastModifiedDate], NSOrderedDescending,nil);
  
  long long oldBytes=self.fileMetaData.totalBytes;
  
  [self prepare];
  [c syncronizeRoute:r withOption:MKTRouteDropboxSyncOverrideOlder fromController:view];
  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:30.0];
  
  [self checkFileExitstance:[dataPath stringByAppendingPathComponent:r.fileName]];
  GHAssertEquals(self.fileMetaData.totalBytes, oldBytes+1,nil);

}



- (void)dropboxReady:(MKTRouteDropboxController*)controller{
  [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testDBSync)];
}

- (void)controller:(MKTRouteDropboxController*)crontroller dropboxInitFailedWithError:(NSError*)error{
  NSLog(@"dropboxInitFailedWithError %@",error);
  [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testDBSync)];
}

- (void)controller:(MKTRouteDropboxController*)crontroller syncFailedWithError:(NSError*)error{
  NSLog(@"dropboxInitFailedWithError %@",error);
  [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testDBSync)];
}

- (void)controllerSyncCompleted:(MKTRouteDropboxController*)crontroller{
  [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testDBSync)];
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
