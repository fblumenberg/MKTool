// ///////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2012, Frank Blumenberg
//
// See License.txt for complete licensing and attribution information.
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// ///////////////////////////////////////////////////////////////////////////////

#import "MKTRoute+WPL.h"
#import "MKTPoint.h"
#import "INIParser.h"

#import "InnerBand.h"
#import "NSSet+BlocksKit.h"

@implementation MKTRoute (MKTRoute_WPL)

- (BOOL)addPointAtIndex:(int)index fromWpl:(INIParser*)p wpTypeZero:(BOOL)wpTypeZero {
  
  
  BOOL result =YES;
  NSString* sectionName = [NSString stringWithFormat:@"Point%d",index];
  
  
  result = result && [p exists:@"Latitude" section:sectionName];
  result = result && [p exists:@"Longitude" section:sectionName];
  result = result && [p exists:@"Radius" section:sectionName];
  result = result && [p exists:@"Altitude" section:sectionName];
  result = result && [p exists:@"ClimbRate" section:sectionName];
  result = result && [p exists:@"DelayTime" section:sectionName];
  result = result && [p exists:@"WP_Event_Channel_Value" section:sectionName];
  result = result && [p exists:@"Heading" section:sectionName];
  result = result && [p exists:@"Speed" section:sectionName];
  result = result && [p exists:@"CAM-Nick" section:sectionName];
  result = result && [p exists:@"Type" section:sectionName];
  result = result && [p exists:@"Prefix" section:sectionName];
  
  if(result){
    
    MKTPoint* pt = [MKTPoint create];
    
    pt.indexValue = index;
    pt.latitudeValue = [p getDouble:@"Latitude" section:sectionName];
    pt.longitudeValue = [p getDouble:@"Longitude" section:sectionName];
    pt.toleranceRadiusValue = [p getInt:@"Radius" section:sectionName];
    pt.altitudeValue = [p getInt:@"Altitude" section:sectionName];
    pt.altitudeRateValue = [p getInt:@"ClimbRate" section:sectionName];
    pt.holdTimeValue = [p getInt:@"DelayTime" section:sectionName];
    pt.eventChannelValueValue = [p getInt:@"WP_Event_Channel_Value" section:sectionName];
    pt.headingValue = [p getInt:@"Heading" section:sectionName];
    pt.speedValue = [p getInt:@"Speed" section:sectionName];
    pt.cameraAngleValue = [p getInt:@"CAM-Nick" section:sectionName];
    
    if(wpTypeZero)
      pt.typeValue = [p getInt:@"Type" section:sectionName];
    else
      pt.typeValue = [p getInt:@"Type" section:sectionName]-1;
    
    pt.prefix = [p get:@"Prefix" section:sectionName];
    
    [self addPointsObject:pt];
  }
  
  return result;
}



- (BOOL)loadRouteFromWplFile:(NSString *)path {
  NSString *data = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
  return [self loadRouteFromWplString:data withFilename:path.lastPathComponent];
}

-(BOOL)loadRouteFromWplString:(NSString *)data withFilename:(NSString*)fileName{
  
  INIParser *p = [[INIParser alloc] initWithString:data];
  if (!p)
    return NO;

  BOOL result = YES;

  result = result && [p exists:@"FileVersion" section:@"General"];
  result = result && [p exists:@"NumberOfWaypoints" section:@"General"];
  result = result && [p getInt:@"FileVersion" section:@"General"] == 3;

  if (result) {
    int numberOfPoints = [p getInt:@"NumberOfWaypoints" section:@"General"];

    self.fileName = fileName;
    BOOL wpTypeZero = NO;
    if([p exists:@"Name" section:@"General"]){
      wpTypeZero = [self hasZeroTypePoints:p numberOfPoints:numberOfPoints];
    }
    
    self.name = [p get:@"Name" section:@"General"];
    if (self.name == nil)
      self.name = [self.fileName stringByDeletingPathExtension];

    [self removePoints:self.points];

    for (int i = 1; result && i <= numberOfPoints; i++) {
      result = [self addPointAtIndex:i fromWpl:p wpTypeZero:wpTypeZero];
    }

    if (self.points.count != numberOfPoints) {
      result = NO;
    }
  }

  return result;
}


- (BOOL)writeRouteToWplFile:(NSString *)path {

  INIParser *p = [INIParser new];

  NSArray *ordPoints = [self orderedPoints];

  [p setNumber:BOX_INT(3) forName:@"FileVersion" section:@"General"];
  [p setNumber:BOX_INT(ordPoints.count) forName:@"NumberOfWaypoints" section:@"General"];
  [p set:self.name forName:@"Name" section:@"General"];

  [ordPoints enumerateObjectsUsingBlock:^(MKTPoint *pt, NSUInteger i, BOOL *stop) {

    NSString *sectionName = [NSString stringWithFormat:@"Point%d", i + 1];

    [p setNumber:pt.latitude forName:@"Latitude" section:sectionName];
    [p setNumber:pt.longitude forName:@"Longitude" section:sectionName];
    [p setNumber:pt.toleranceRadius forName:@"Radius" section:sectionName];
    [p setNumber:pt.altitude forName:@"Altitude" section:sectionName];
    [p setNumber:pt.altitudeRate forName:@"ClimbRate" section:sectionName];
    [p setNumber:pt.holdTime forName:@"DelayTime" section:sectionName];
    [p setNumber:pt.eventChannelValue forName:@"WP_Event_Channel_Value" section:sectionName];
    [p setNumber:pt.heading forName:@"Heading" section:sectionName];
    [p setNumber:pt.speed forName:@"Speed" section:sectionName];
    [p setNumber:pt.cameraAngle forName:@"CAM-Nick" section:sectionName];
    [p setNumber:@(pt.typeValue+1) forName:@"Type" section:sectionName];
    [p set:pt.prefix forName:@"Prefix" section:sectionName];

  }];

  NSError *error = nil;
  BOOL retVal = [p writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:&error];
  return retVal;
}

- (BOOL)hasZeroTypePoints:(INIParser*)p numberOfPoints:(NSInteger)numberOfPoints {
  
  BOOL result=NO;
  
  for(int i=1;!result &&  i<=numberOfPoints;i++){
    NSString* sectionName = [NSString stringWithFormat:@"Point%d",i];
    int type = [p getInt:@"Type" section:sectionName];
    result = result || (type==0);
  }
  
  return result;
}
@end
