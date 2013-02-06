// ///////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2010, Frank Blumenberg
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


#import "MKSimConnection.h"
#import "IKMkDataTypes.h"
#import "NSData+MKCommandEncode.h"
#import "NSString+Parsing.h"
#import "IKNaviData.h"
#import "InnerBand.h"

enum CsvIndex {
  CSV_altimeter = 0, CSV_angleNick, CSV_angleRoll, CSV_compassHeading, CSV_current, CSV_currentPosition,
  CSV_errorCode, CSV_fcStatusFlags, CSV_fcStatusFlags2, CSV_flyingTime, CSV_gas, CSV_groundSpeed,
  CSV_heading, CSV_homePosition, CSV_homePositionDeviation, CSV_ncFlags, CSV_operatingRadius,
  CSV_rcQuality, CSV_satsInUse, CSV_setpointAltitude, CSV_targetHoldTime, CSV_targetPosition,
  CSV_targetPositionDeviation, CSV_timeStamp, CSV_topSpeed, CSV_uBat, CSV_usedCapacity,
  CSV_variometer, CSV_version, CSV_waypointIndex, CSV_waypointNumber
};

@implementation MKSimConnection (NCData)

- (void)initNCData{
  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"FakeOsd"
                                                       ofType:@"csv"];
  
  self.naviData = [IKNaviData new];
  
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_async(queue, ^{
    NSError *error;
    NSString *data = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];

    self.osdData = [data csvRows];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      self.dataRow = 0;
      [self updateNaviDataFromRow:self.dataRow];
      
      self.osdTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(nextRow)
                                                userInfo:nil repeats:YES];
    });
  });
  
}

- (void)sendNCDataResponse {
  NSData *payload = [NSData dataWithBytes:(void *) self.naviData.data length:sizeof(IKMkNaviData)];
  [self sendResponse:[payload dataWithCommand:MKCommandOsdResponse forAddress:kIKMkAddressNC]];
}

- (void)nextRow{
  self.dataRow = (++self.dataRow % [self.osdData count]);
  
  [self updateNaviDataFromRow:self.dataRow];
}


static void fillIKMkGPSPosDevFromString(NSString *data, IKMkGPSPosDev *pos) {
  
  NSArray *components = [data componentsSeparatedByString:@":"];
  
  pos->Distance = [[components objectAtIndex:0] intValue];
  pos->Bearing = [[components objectAtIndex:1] intValue];
}

static void fillIKMkGPSPosFromString(NSString *data, IKMkGPSPos *pos) {
  
  NSArray *components = [data componentsSeparatedByString:@":"];
  
  pos->Latitude = [[components objectAtIndex:0] intValue];
  pos->Longitude = [[components objectAtIndex:1] intValue];
  
  pos->Altitude = [[components objectAtIndex:2] intValue];
  pos->Status = [[components objectAtIndex:3] intValue];
}

- (void)updateNaviDataFromRow:(NSInteger)row{
  
    NSArray *columns = [self.osdData objectAtIndex:(NSUInteger) row];
    
    self.naviData.data->Version = NAVIDATA_VERSION;
    
    fillIKMkGPSPosFromString([columns objectAtIndex:CSV_currentPosition], &(self.naviData.data->CurrentPosition));
    fillIKMkGPSPosFromString([columns objectAtIndex:CSV_targetPosition], &(self.naviData.data->TargetPosition));
    fillIKMkGPSPosFromString([columns objectAtIndex:CSV_homePosition], &(self.naviData.data->HomePosition));
    
    fillIKMkGPSPosDevFromString([columns objectAtIndex:CSV_homePositionDeviation], &(self.naviData.data->HomePositionDeviation));
    fillIKMkGPSPosDevFromString([columns objectAtIndex:CSV_targetPositionDeviation], &(self.naviData.data->TargetPositionDeviation));
    
    self.naviData.data->WaypointIndex = (u_int8_t)[[columns objectAtIndex:CSV_waypointIndex] intValue];        // index of current waypoints running from 0 to WaypointNumber-1
    self.naviData.data->WaypointNumber = (u_int8_t)[[columns objectAtIndex:CSV_waypointNumber] intValue];       // number of stored waypoints
    self.naviData.data->SatsInUse = (u_int8_t)[[columns objectAtIndex:CSV_satsInUse] intValue];          // number of satellites used for position solution
    self.naviData.data->Altimeter = (u_int8_t)[[columns objectAtIndex:CSV_altimeter] intValue];          // hight according to air pressure
    self.naviData.data->Variometer = (int16_t) [[columns objectAtIndex:CSV_variometer] intValue];         // climb(+) and sink(-) rate
    self.naviData.data->FlyingTime = (uint16_t) [[columns objectAtIndex:CSV_flyingTime] intValue];         // in seconds
    self.naviData.data->UBat = (uint8_t) [[columns objectAtIndex:CSV_uBat] intValue];           // Battery Voltage in 0.1 Volts
    self.naviData.data->GroundSpeed = (uint16_t) [[columns objectAtIndex:CSV_groundSpeed] intValue];        // speed over ground in cm/s (2D)
    self.naviData.data->Heading = (int16_t) [[columns objectAtIndex:CSV_heading] intValue];          // current flight direction in � as angle to north
    self.naviData.data->CompassHeading = (int16_t) [[columns objectAtIndex:CSV_compassHeading] intValue];       // current compass value in �
    self.naviData.data->AngleNick = (int8_t) [[columns objectAtIndex:CSV_angleNick] intValue];          // current Nick angle in 1�
    self.naviData.data->AngleRoll = (int8_t) [[columns objectAtIndex:CSV_angleRoll] intValue];          // current Rick angle in 1�
    self.naviData.data->RC_Quality = (uint8_t) [[columns objectAtIndex:CSV_rcQuality] intValue];         // RC_Quality
    self.naviData.data->FCStatusFlags = (uint8_t) [[columns objectAtIndex:CSV_fcStatusFlags] intValue];        // Flags from FC
    self.naviData.data->NCFlags = (uint8_t) [[columns objectAtIndex:CSV_ncFlags] intValue];          // Flags from NC
    self.naviData.data->Errorcode = (uint8_t) [[columns objectAtIndex:CSV_errorCode] intValue];          // 0 --> okay
    self.naviData.data->OperatingRadius = (uint8_t) [[columns objectAtIndex:CSV_operatingRadius] intValue];      // current operation radius around the Home Position in m
    self.naviData.data->TopSpeed = (int16_t) [[columns objectAtIndex:CSV_topSpeed] intValue];         // velocity in vertical direction in cm/s
    self.naviData.data->TargetHoldTime = (uint8_t) [[columns objectAtIndex:CSV_targetHoldTime] intValue];       // time in s to stay at the given target, counts down to 0 if target has been reached
    self.naviData.data->FCStatusFlags2 = (uint8_t) [[columns objectAtIndex:CSV_fcStatusFlags2] intValue];        // StatusFlags2 (since version 5 added)
    self.naviData.data->SetpointAltitude = (int16_t) [[columns objectAtIndex:CSV_setpointAltitude] intValue];     // setpoint for altitude
    self.naviData.data->Gas = (uint8_t) [[columns objectAtIndex:CSV_gas] intValue];            // for future use
    self.naviData.data->Current = (uint16_t) [[columns objectAtIndex:CSV_current] intValue];          // actual current in 0.1A steps
    self.naviData.data->UsedCapacity = (uint16_t) [[columns objectAtIndex:CSV_usedCapacity] intValue];       // used capacity in mAh
}

@end
