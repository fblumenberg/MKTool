//
//  MKTRoute+MKTRoute_Test.m
//  MK Waypoints
//
//  Created by Frank Blumenberg on 16.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MKTRoute+Test.h"
#import "MKTPoint.h"

#import "InnerBand.h"

@implementation MKTRoute (MKTRoute_Test)

- (BOOL) hasEqualValuesTo:(MKTRoute*)route{

  BOOL result = TRUE;
  
  for (NSString* key in [MKTRoute attributesForRoute].allKeys) {
    if(! [key isEqualToString:@"lastUpdated"]){
      id o1 = [self valueForKey:key];
      id o2 = [route valueForKey:key];
      BOOL b = [o1 isEqual:o2];
      NSLog(@"Check %@ %@ == %@ - %d",key,o1,o2,b);
      if(o1!=nil||o2!=nil)
        result = result && b;
    }
  }

  if(result)
    result = (self.points.count == route.points.count);
  
  if(result){
    NSArray* r1 = [route orderedPoints];
    NSArray* r2 = [self orderedPoints];
    
    for(NSUInteger i=0;i<r1.count;i++ ){
      MKTPoint* p1 = [r1 objectAtIndex:i];
      MKTPoint* p2 = [r2 objectAtIndex:i];
      for (NSString* key in [MKTPoint attributesForPoint].allKeys) {
        result = result && [[p1 valueForKey:key] isEqual:[p2 valueForKey:key]];
        if(!result)
          NSLog(@"Result is false for %@",key);
      }
    }
  }

  return result;
}

+ (MKTRoute *)addRouteWithName:(NSString *)name numberOfPoints:(NSInteger)count prefix:(NSString *)prefix {
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
