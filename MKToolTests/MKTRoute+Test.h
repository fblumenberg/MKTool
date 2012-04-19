//
//  MKTRoute+MKTRoute_Test.h
//  MK Waypoints
//
//  Created by Frank Blumenberg on 16.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MKTRoute.h"

@interface MKTRoute (MKTRoute_Test)

+ (MKTRoute *)addRouteWithName:(NSString *)name numberOfPoints:(NSInteger)count prefix:(NSString *)prefix;

- (BOOL) hasEqualValuesTo:(MKTRoute*)route;

@end
