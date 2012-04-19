//
//  MKTDropboxBaseTest.h
//  MK Waypoints
//
//  Created by Frank Blumenberg on 16.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GHAsyncTestCase.h"

@class DBMetadata;

@interface MKTDropboxBaseTest : GHAsyncTestCase

@property(strong) NSString* fileToCheck;
@property(strong) DBMetadata* fileMetaData;

- (void) checkFileExitstance:(NSString*) path;
- (void) deletePath:(NSString*) path;

@end
