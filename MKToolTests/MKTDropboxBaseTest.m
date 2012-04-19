//
//  MKTDropboxBaseTest.m
//  MK Waypoints
//
//  Created by Frank Blumenberg on 16.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "DropboxSDK/DropboxSDK.h"

#import "MKTDropboxBaseTest.h"

@interface MKTDropboxBaseTest () <DBRestClientDelegate>

@property(strong) DBRestClient* restClient;

@end

@implementation MKTDropboxBaseTest

@synthesize fileToCheck;
@synthesize fileMetaData;
@synthesize restClient;

-(void) setUpClass{
  self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
  self.restClient.delegate = self;
}


- (void)checkFileExitstance:(NSString *)path{

  self.fileToCheck = path;
  self.fileMetaData = nil;
  
  [self prepare:@selector(checkFileExitstance:)];
  [self.restClient loadMetadata:self.fileToCheck];  
  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:30.0];
}

//------------------------------------------------------------------------------------------------------

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)newMetadata {
  self.fileMetaData = newMetadata;
  NSLog(@"checkFileExitstance loadedMetadata %@",newMetadata);
  [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(checkFileExitstance:)];
}

- (void)restClient:(DBRestClient *)client metadataUnchangedAtPath:(NSString *)path {
  NSLog(@"metadataUnchangedAtPath:%@",path);
  [self notify:kGHUnitWaitStatusFailure forSelector:@selector(checkFileExitstance:)];
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
  NSLog(@"restClient:loadMetadataFailedWithError: %@", [error localizedDescription]);
  [self notify:kGHUnitWaitStatusFailure forSelector:@selector(checkFileExitstance:)];
}


- (void) deletePath:(NSString*) path{
  [self prepare:@selector(checkFileExitstance:)];
  [self.restClient deletePath:path];  
  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:30.0];
}

- (void)restClient:(DBRestClient*)client deletedPath:(NSString *)path  {
  NSLog(@"Deleted %@",path);
  
  [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(checkFileExitstance:)];
}
- (void)restClient:(DBRestClient*)client deletePathFailedWithError:(NSError*)error{
  
  NSLog(@"restClient:loadMetadataFailedWithError: %@", [error localizedDescription]);
  [self notify:kGHUnitWaitStatusFailure forSelector:@selector(checkFileExitstance:)];
}


@end
