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
#import "NSArray+BlocksKit.h"

#import "MKTDropboxBaseTest.h"

#import "INIParser.h"
#import "MKTRoute.h"
#import "MKTPoint.h"

#import "MKTRouteDropboxController.h"

#define kIKDropboxPath @"MKToolTest"

@interface MKRouteDropBoxSyncAllLocalRemoteTest : MKTDropboxBaseTest<MKTRouteDropboxControllerDelegate> {
  NSString *tmpFile;  
  NSString *dataPath;
  UIViewController* view;
}

- (MKTRoute *)addRouteWithName:(NSString *)name numberOfPoints:(NSInteger)count prefix:(NSString *)prefix;
- (void) checkSyncResult;
@end

@implementation MKRouteDropBoxSyncAllLocalRemoteTest


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
  
  // create local, ush to remote
  [self addRouteWithName:@"TEST1" numberOfPoints:2 prefix:@"S"];
  [self addRouteWithName:@"TEST2" numberOfPoints:2 prefix:@"T"];
  [self addRouteWithName:@"TEST3" numberOfPoints:2 prefix:@"U"];
  [store save];
  
  [self prepare];
  [c syncronizeAllRoutesWithOption:MKTRouteDropboxSyncOverrideRemote fromController:view];
  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:30.0];

  [self checkSyncResult];
  
  [[MKTRoute first] destroy];
  
  [self prepare];
  [c syncronizeAllRoutesWithOption:MKTRouteDropboxSyncOverrideRemote fromController:view];
  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:30.0];
  
  [self checkSyncResult];

  [self addRouteWithName:@"TEST5" numberOfPoints:2 prefix:@"U"];

  [self prepare];
  [c syncronizeAllRoutesWithOption:MKTRouteDropboxSyncOverrideLocal fromController:view];
  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:30.0];
  
  [self checkSyncResult];
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


- (void) checkSyncResult{
  
  [self checkFileExitstance:dataPath];

  NSUInteger count = [MKTRoute count];
  GHAssertEquals(self.fileMetaData.contents.count,count, nil);

  [self.fileMetaData.contents each:^(DBMetadata* data){
    MKTRoute* r = [[MKTRoute allForPredicate:[NSPredicate predicateWithFormat:@"fileName=%@",data.filename]] firstObject];
    GHAssertNotNil(r,nil);
    GHAssertEqualStrings(data.filename, r.fileName,nil);
    GHAssertEqualStrings(data.rev, r.parentRev,nil);
    GHAssertEqualObjects(data.lastModifiedDate, r.lastUpdated,nil);
  }];
}


@end
