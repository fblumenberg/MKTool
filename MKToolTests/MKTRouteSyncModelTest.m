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

#import "MKTPoint.h"
#import "MKTRoute.h"
#import "MKTRouteSyncModel.h"

@interface MKTRouteSyncModelTest : GHTestCase

- (MKTRoute *)addRouteWithName:(NSString *)name;
- (MKTRoute *)addRouteWithName:(NSString *)name numberOfPoints:(NSInteger)count prefix:(NSString *)prefix;

- (DBMetadata*) metaData;
@end

@implementation MKTRouteSyncModelTest

- (void)setUp {
  CoreDataStore *store = [CoreDataStore mainStore];
  [store clearAllData];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)testSyncAllRemoteEmpty {

  [self addRouteWithName:@"Test1" numberOfPoints:5 prefix:@"T"];
  [self addRouteWithName:@"Test2" numberOfPoints:5 prefix:@"U"];
  [self addRouteWithName:@"Test3" numberOfPoints:5 prefix:@"V"];
  
  NSArray* routes = [MKTRoute all];
  NSArray* metaData = [NSArray array];
  
  MKTRouteSyncModel* model = [[MKTRouteSyncModel alloc] initWithRoutes:routes metaData:metaData];
  [model prepareForSynchWithOption:MKTRouteDropboxSyncOverrideRemote];
    
  GHAssertEquals(model.itemsForDownload.count, 0U,nil);
  GHAssertEquals(model.itemsForDelete.count, 0U,nil);
  GHAssertEquals(model.itemsForUpload.count, routes.count,nil);

  [model.itemsForUpload each:^(MKTSyncItem* item){
    GHAssertNotEquals([routes indexOfObject:item.route], (NSUInteger)NSNotFound, nil);
  }];
}


- (void)testSyncAllRemoteExtra {
  
  [self addRouteWithName:@"Test1" numberOfPoints:5 prefix:@"T"];
  [self addRouteWithName:@"Test2" numberOfPoints:5 prefix:@"U"];
  [self addRouteWithName:@"Test3" numberOfPoints:5 prefix:@"V"];
  
  NSArray* routes = [MKTRoute all];

  NSMutableArray* metaData = [NSMutableArray array];
  [metaData pushObject:[self metaData]];
  
  MKTRouteSyncModel* model = [[MKTRouteSyncModel alloc] initWithRoutes:routes metaData:metaData];
  [model prepareForSynchWithOption:MKTRouteDropboxSyncOverrideRemote];
  
  GHAssertEquals(model.itemsForDownload.count, 0U,nil);
  GHAssertEquals(model.itemsForUpload.count, routes.count,nil);
  GHAssertEquals(model.itemsForDelete.count, metaData.count,nil);

  [model.itemsForUpload each:^(MKTSyncItem* item){
    GHAssertNotEquals([routes indexOfObject:item.route], (NSUInteger)NSNotFound, nil);
  }];

  [model.itemsForDelete each:^(MKTSyncItem* item){
    GHAssertNotEquals([metaData indexOfObject:item.metaData], (NSUInteger)NSNotFound, nil);
  }];
}


- (void)testSyncAllRemoteOneEqual {
  
  MKTRoute* r = [self addRouteWithName:@"Test1" numberOfPoints:5 prefix:@"T"];
  r.parentRev = @"TESTREV";
  
  [self addRouteWithName:@"Test2" numberOfPoints:5 prefix:@"U"];
  [self addRouteWithName:@"Test3" numberOfPoints:5 prefix:@"V"];
  
  NSMutableArray* metaData = [NSMutableArray array];

  DBMetadata* m = [self metaDataForRoute:r];
  [metaData pushObject:m];

  NSArray* routes = [MKTRoute all];
  
  MKTRouteSyncModel* model = [[MKTRouteSyncModel alloc] initWithRoutes:routes metaData:metaData];
  [model prepareForSynchWithOption:MKTRouteDropboxSyncOverrideRemote];
  
  GHAssertEquals(model.itemsForDownload.count, 0U,nil);
  GHAssertEquals(model.itemsForUpload.count, routes.count,nil);
  GHAssertEquals(model.itemsForDelete.count,0U,nil);
  
  [model.itemsForUpload each:^(MKTSyncItem* item){
    GHAssertNotEquals([routes indexOfObject:item.route], (NSUInteger)NSNotFound, nil);
  }];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)testSyncAllLocalOneEqual {
  
  NSArray* routes = [NSArray array];
  MKTRoute* r = [self addRouteWithName:@"Test1" numberOfPoints:5 prefix:@"T"];
  r.parentRev = @"TESTREV";
  
  NSMutableArray* metaData = [NSMutableArray array];
  [metaData pushObject:[self metaData]];
  [metaData pushObject:[self metaData]];
  [metaData pushObject:[self metaData]];
  [metaData pushObject:[self metaDataForRoute:r]];
  
  MKTRouteSyncModel* model = [[MKTRouteSyncModel alloc] initWithRoutes:routes metaData:metaData];
  [model prepareForSynchWithOption:MKTRouteDropboxSyncOverrideLocal];
  
  GHAssertEquals(model.itemsForUpload.count, 0U,nil);
  GHAssertEquals(model.itemsForDelete.count, 0U,nil);
  GHAssertEquals(model.itemsForDownload.count, metaData.count,nil);
  
  [model.itemsForDownload each:^(MKTSyncItem* item){
    GHAssertNotEquals([metaData indexOfObject:item.metaData], (NSUInteger)NSNotFound, nil);
  }];
}


- (void)testSyncAllLocalEmpty {

  NSArray* routes = [NSArray array];
  
  NSMutableArray* metaData = [NSMutableArray array];
  [metaData pushObject:[self metaData]];
  [metaData pushObject:[self metaData]];
  [metaData pushObject:[self metaData]];
  
  MKTRouteSyncModel* model = [[MKTRouteSyncModel alloc] initWithRoutes:routes metaData:metaData];
  [model prepareForSynchWithOption:MKTRouteDropboxSyncOverrideLocal];
  
  GHAssertEquals(model.itemsForUpload.count, 0U,nil);
  GHAssertEquals(model.itemsForDelete.count, 0U,nil);
  GHAssertEquals(model.itemsForDownload.count, metaData.count,nil);
  
  [model.itemsForDownload each:^(MKTSyncItem* item){
    GHAssertNotEquals([metaData indexOfObject:item.metaData], (NSUInteger)NSNotFound, nil);
  }];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)testSyncAllOlderLocalEmpty {
  
  NSArray* routes = [NSArray array];
  
  NSMutableArray* metaData = [NSMutableArray array];
  [metaData pushObject:[self metaData]];
  [metaData pushObject:[self metaData]];
  [metaData pushObject:[self metaData]];
  
  MKTRouteSyncModel* model = [[MKTRouteSyncModel alloc] initWithRoutes:routes metaData:metaData];
  [model prepareForSynchWithOption:MKTRouteDropboxSyncOverrideOlder];
  
  GHAssertEquals(model.itemsForUpload.count, 0U,nil);
  GHAssertEquals(model.itemsForDelete.count, 0U,nil);
  GHAssertEquals(model.itemsForDownload.count, metaData.count,nil);
  
  [model.itemsForDownload each:^(MKTSyncItem* item){
    GHAssertNotEquals([metaData indexOfObject:item.metaData], (NSUInteger)NSNotFound, nil);
  }];
}

- (void)testSyncAllLocaOlderOneEqual {
  
  MKTRoute* r = [self addRouteWithName:@"Test1" numberOfPoints:5 prefix:@"T"];
  r.parentRev = @"TESTREV";
  NSArray* routes = [MKTRoute all];
  
  NSMutableArray* metaData = [NSMutableArray array];
  [metaData pushObject:[self metaData]];
  [metaData pushObject:[self metaData]];
  [metaData pushObject:[self metaData]];
  [metaData pushObject:[self metaDataForRoute:r]];
  
  MKTRouteSyncModel* model = [[MKTRouteSyncModel alloc] initWithRoutes:routes metaData:metaData];
  [model prepareForSynchWithOption:MKTRouteDropboxSyncOverrideOlder];
  
  GHAssertEquals(model.itemsForUpload.count, 0U,nil);
  GHAssertEquals(model.itemsForDelete.count, 0U,nil);
  GHAssertEquals(model.itemsForDownload.count, metaData.count-1,nil);
  
  [model.itemsForDownload each:^(MKTSyncItem* item){
    GHAssertNotEquals([metaData indexOfObject:item.metaData], (NSUInteger)NSNotFound, nil);
  }];
}


- (void)testSyncAllOlderRemoteEmpty {
  
  [self addRouteWithName:@"Test1" numberOfPoints:5 prefix:@"T"];
  [self addRouteWithName:@"Test2" numberOfPoints:5 prefix:@"U"];
  [self addRouteWithName:@"Test3" numberOfPoints:5 prefix:@"V"];
  
  NSArray* routes = [MKTRoute all];
  NSArray* metaData = [NSArray array];
  
  MKTRouteSyncModel* model = [[MKTRouteSyncModel alloc] initWithRoutes:routes metaData:metaData];
  [model prepareForSynchWithOption:MKTRouteDropboxSyncOverrideOlder];
  
  GHAssertEquals(model.itemsForDownload.count, 0U,nil);
  GHAssertEquals(model.itemsForDelete.count, 0U,nil);
  GHAssertEquals(model.itemsForUpload.count, routes.count,nil);
  
  [model.itemsForUpload each:^(MKTSyncItem* item){
    GHAssertNotEquals([routes indexOfObject:item.route], (NSUInteger)NSNotFound, nil);
  }];
}


- (void)testSyncAllOlderRemoteOneEqual {
  
  MKTRoute* r = [self addRouteWithName:@"Test1" numberOfPoints:5 prefix:@"T"];
  r.parentRev = @"TESTREV";
  
  [self addRouteWithName:@"Test2" numberOfPoints:5 prefix:@"U"];
  [self addRouteWithName:@"Test3" numberOfPoints:5 prefix:@"V"];
  
  NSMutableArray* metaData = [NSMutableArray array];
  
  DBMetadata* m = [self metaDataForRoute:r];
  [metaData pushObject:m];
  
  NSArray* routes = [MKTRoute all];
  
  MKTRouteSyncModel* model = [[MKTRouteSyncModel alloc] initWithRoutes:routes metaData:metaData];
  [model prepareForSynchWithOption:MKTRouteDropboxSyncOverrideOlder];
  
  GHAssertEquals(model.itemsForDownload.count, 0U,nil);
  GHAssertEquals(model.itemsForUpload.count, routes.count-1,nil);
  GHAssertEquals(model.itemsForDelete.count,0U,nil);
  
  [model.itemsForUpload each:^(MKTSyncItem* item){
    GHAssertNotEquals([routes indexOfObject:item.route], (NSUInteger)NSNotFound, nil);
  }];
}

- (void)testSyncAllOlderFullSync {
  
  /*
  R   L
  a >
  b > b 
  c = c
  d < d
    < e   
   */
  NSMutableArray* metaData = [NSMutableArray array];
   
  MKTRoute* r;
  DBMetadata* m;
  
  //A
  m = [self metaDataWithRev:@"A1"];
  [metaData pushObject:m];  
  
  r = [self addRouteWithName:@"B" numberOfPoints:5 prefix:@"T"];
  r.parentRev = @"B1";
  
  m = [self metaDataWithFile:r.fileName rev:@"B2" data:[r.lastUpdated dateByAddingTimeInterval:60]];
  [metaData pushObject:m];  

  r = [self addRouteWithName:@"C" numberOfPoints:5 prefix:@"T"];
  r.parentRev = @"C1";
  
  m = [self metaDataForRoute:r];
  [metaData pushObject:m];  

  r = [self addRouteWithName:@"D" numberOfPoints:5 prefix:@"T"];
  r.parentRev = @"D1";
  
  m = [self metaDataForRoute:r];
  [metaData pushObject:m];  

  r.lastUpdated = [r.lastUpdated dateByAddingTimeInterval:-60];
  
  r = [self addRouteWithName:@"E" numberOfPoints:5 prefix:@"T"];
  r.parentRev = @"E1";
  
  NSArray* routes = [MKTRoute all];
  
  GHAssertEquals(routes.count, 4U,nil);
  GHAssertEquals(metaData.count, 4U,nil);
  
  MKTRouteSyncModel* model = [[MKTRouteSyncModel alloc] initWithRoutes:routes metaData:metaData];
  [model prepareForSynchWithOption:MKTRouteDropboxSyncOverrideOlder];
  
  NSArray* dlResult = [model.itemsForDownload map:^(MKTSyncItem* i){return i.metaData.rev;}];
  dlResult = [dlResult sortedArray];
  NSArray* dlRequired = [NSArray arrayWithObjects:@"A1",@"B2",nil];

  NSArray* ulResult = [model.itemsForUpload map:^(MKTSyncItem* i){return i.route.parentRev;}];
  ulResult = [ulResult sortedArray];
  NSArray* ulRequired = [NSArray arrayWithObjects:@"D1",@"E1",nil];
  
  GHAssertEqualObjects(dlResult, dlRequired,nil);
  GHAssertEqualObjects(ulResult, ulRequired,nil);
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////


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


- (NSDateFormatter*)dateFormatter {
  NSMutableDictionary* dictionary = [[NSThread currentThread] threadDictionary];
  static NSString* dateFormatterKey = @"DBMetadataDateFormatter";
  
  NSDateFormatter* dateFormatter = [dictionary objectForKey:dateFormatterKey];
  if (dateFormatter == nil) {
    dateFormatter = [NSDateFormatter new];
    // Must set locale to ensure consistent parsing:
    // http://developer.apple.com/iphone/library/qa/qa2010/qa1480.html
    dateFormatter.locale = 
    [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss Z";
    [dictionary setObject:dateFormatter forKey:dateFormatterKey];
  }
  return dateFormatter;
}

- (DBFileInfo*) metaDataWithRev:(NSString*)rev {
  
  // Create universally unique identifier (object)
  CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
  // Get the string representation of CFUUID object.
  NSString *uuidStr = (__bridge NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
  CFRelease(uuidObject);
  
  NSMutableDictionary* d = [NSMutableDictionary dictionary];
  
  [d setObject:[@"/ROOT/" stringByAppendingPathComponent:uuidStr] forKey:@"path"];
  
  NSString* modified = [[self dateFormatter] stringFromDate:[NSDate date]];
  [d setObject:modified forKey:@"modified"];
  
  [d setObject:rev forKey:@"rev"];
  
  DBMetadata* m = [[DBMetadata alloc] initWithDictionary:d];
  return m;
}

- (DBMetadata*) metaData{

  NSString* rev = [NSString stringWithFormat:@"%d",(int)([[NSDate date] timeIntervalSinceReferenceDate]*1000)];
  return [self metaDataWithRev:rev];
}


- (DBMetadata*) metaDataForRoute:(MKTRoute*) r {
  
  NSMutableDictionary* d = [NSMutableDictionary dictionary];
  
  [d setObject:[@"/ROOT/" stringByAppendingPathComponent:r.fileName] forKey:@"path"];
  
  NSString* modified = [[self dateFormatter] stringFromDate:r.lastUpdated];
  [d setObject:modified forKey:@"modified"];

  [d setObject:r.parentRev forKey:@"rev"];
  
  DBMetadata* m = [[DBMetadata alloc] initWithDictionary:d];
  return m;
}

- (DBMetadata*) metaDataWithFile:(NSString*)fileName rev:(NSString*)rev data:(NSDate*)date {
  
  NSMutableDictionary* d = [NSMutableDictionary dictionary];
  
  [d setObject:[@"/ROOT/" stringByAppendingPathComponent:fileName] forKey:@"path"];
  
  NSString* modified = [[self dateFormatter] stringFromDate:date];
  [d setObject:modified forKey:@"modified"];
  
  [d setObject:rev forKey:@"rev"];
  
  DBMetadata* m = [[DBMetadata alloc] initWithDictionary:d];
  return m;
}

@end
