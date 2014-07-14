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

#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>

#import "DDLog.h"
#import "OsdValue.h"
#import "MKConnectionController.h"
#import "MKDataConstants.h"
#import "MKTGpxSession.h"
#import "MKTGpxRecord.h"
#import "IKDebugData.h"
#import "IKPoint.h"
#import "IKDeviceVersion.h"
#import "InnerBand.h"

#import "MKTRouteTransferController.h"

#define kGpxLoggingInterval @"kGpxLoggingInterval"
#define kGpxLoggingActive @"kGpxLoggingActive"


static const NSString *errorMsg[30] = {
        @"No Error",
        @"FC not compatible",
        @"MK3Mag not compatible",
        @"no FC communication ",
        @"no MK3Mag communication",
        @"no GPS communication ",
        @"bad compass value",
        @"RC Signal lost",
        @"FC spi rx error",
        @"ERR: no NC communication",
        @"ERR: FC Nick Gyro",
        @"ERR: FC Roll Gyro",
        @"ERR: FC Yaw Gyro",
        @"ERR: FC Nick ACC",
        @"ERR: FC Roll ACC",
        @"ERR: FC Z-ACC",
        @"ERR: Pressure sensor",
        @"ERR: FC I2C",
        @"ERR: Bl Missing",
        @"Mixer Error",
        @"FC: Carefree Error",
        @"ERR: GPS Fix lost",
        @"ERR: Magnet Error",
        @"Motor restart",
        @"BL limitation",
        @"ERR:GPS range",
        @"ERR:No SD-Card",
        @"ERR:SD Logging aborted",
        @"ERR:",
        @"ERR:Max Altitude"
};

@interface OsdValue () <CLLocationManagerDelegate, MKTRouteTransferControllerDelegate>
- (void)sendOsdRefreshRequest;

- (void)sendFollowMeRequest;

- (void)logNCData;

- (void)osdNotification:(NSNotification *)aNotification;

- (void)debugValueNotification:(NSNotification *)aNotification;

- (void)motorDataNotification:(NSNotification *)aNotification;

@property(retain) IKNaviData *data;
@property(retain) CLLocationManager *lm;
@property(retain) AVAudioPlayer *audioPlayer;
@property(retain) IKDebugData *debugData;

@property(readwrite,strong) NSArray* routePoints;
@property(strong) MKTRouteTransferController* routeTransferController;

@end

///////////////////////////////////////////////////////////////////////////////
#pragma mark - DDRegisteredDynamicLogging
static int ddLogLevel = LOG_LEVEL_WARN;

@interface OsdValue (DDRegisteredDynamicLogging) <DDRegisteredDynamicLogging>
@end

@implementation OsdValue (DDRegisteredDynamicLogging)
+ (int)ddLogLevel {
  return ddLogLevel;
}

+ (void)ddSetLogLevel:(int)logLevel {
  ddLogLevel = logLevel;
}
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation OsdValue

@synthesize delegate = _delegate;
@synthesize data = _data;
@synthesize managedObjectContext;
@synthesize poiIndex;

@synthesize lm;
@synthesize canFollowMe;
@synthesize followMeRequests;
@synthesize audioPlayer;

- (void)setFollowMe:(BOOL)followMe {

  if (_followMe != followMe) {

    [self willChangeValueForKey:@"followMe"];
    _followMe = followMe;
    [self didChangeValueForKey:@"followMe"];

    if (_followMe) {
      [self.lm startUpdatingLocation];
      _followMeCanStart = NO;
      followMeRequests = 0;

      followMeTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:
              @selector(sendFollowMeRequest)         userInfo:nil repeats:YES];

    }
    else {
      followMeRequests = 0;
      [followMeTimer invalidate];
      followMeTimer = nil;
      _followMeCanStart = NO;
      [self.lm stopUpdatingLocation];
    }
  }
}

- (BOOL)followMe {

  return _followMe;
}

- (BOOL)followMeActive {
  return _followMe && _followMeCanStart;
}

- (double)followMeHorizontalAccuracy {
  return self.lm.location.horizontalAccuracy;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (const NSString *)currentErrorMessage {
  if (_data.data->Errorcode < 30)
    return errorMsg[_data.data->Errorcode];

  return @"";
}

- (BOOL)areEnginesOn {
  if (!_data.data)
    return NO;
  return ((_data.data->FCStatusFlags & FC_STATUS_MOTOR_RUN) == FC_STATUS_MOTOR_RUN);
}

- (BOOL)isFlying {
  if (!_data.data)
    return NO;
  return ((_data.data->FCStatusFlags & FC_STATUS_FLY) == FC_STATUS_FLY);
}

- (BOOL)isCalibrating {
  if (!_data.data)
    return NO;
  return ((_data.data->FCStatusFlags & FC_STATUS_CALIBRATE) == FC_STATUS_CALIBRATE);
}

- (BOOL)isStarting {
  if (!_data.data)
    return NO;
  return ((_data.data->FCStatusFlags & FC_STATUS_START) == FC_STATUS_START);
}

- (BOOL)isEmergencyLanding; {
  if (!_data.data)
    return NO;
  return ((_data.data->FCStatusFlags & FC_STATUS_EMERGENCY_LANDING) == FC_STATUS_EMERGENCY_LANDING);
}

- (BOOL)isLowBat; {
  if (!_data.data)
    return NO;
  return ((_data.data->FCStatusFlags & FC_STATUS_LOWBAT) == FC_STATUS_LOWBAT);
}

- (BOOL)isFreeModeEnabled; {
  if (!_data.data)
    return NO;
  return ((_data.data->NCFlags & NC_FLAG_FREE) == NC_FLAG_FREE);
}

- (BOOL)isPositionHoldEnabled; {
  if (!_data.data)
    return NO;
  return ((_data.data->NCFlags & NC_FLAG_PH) == NC_FLAG_PH);
}

- (BOOL)isComingHomeEnabled; {
  if (!_data.data)
    return NO;
  return ((_data.data->NCFlags & NC_FLAG_CH) == NC_FLAG_CH);
}

- (BOOL)isRangeLimitReached; {
  if (!_data.data)
    return NO;
  return ((_data.data->NCFlags & NC_FLAG_RANGE_LIMIT) == NC_FLAG_RANGE_LIMIT);
}

- (BOOL)isTargetReached; {
  if (!_data.data)
    return NO;
  return ((_data.data->NCFlags & NC_FLAG_TARGET_REACHED) == NC_FLAG_TARGET_REACHED);
}

- (BOOL)isManualControlEnabled; {
  if (!_data.data)
    return NO;
  return ((_data.data->NCFlags & NC_FLAG_MANUAL_CONTROL) == NC_FLAG_MANUAL_CONTROL);
}

- (BOOL)isGpsOk {
  if (!_data.data)
    return NO;
  return ((_data.data->NCFlags & NC_FLAG_GPS_OK) == NC_FLAG_GPS_OK);
}

- (BOOL)isCareFreeOn {
  if (!_data.data)
    return NO;
  return (_data.data->Version == 5 && (_data.data->FCStatusFlags2 & FC_STATUS2_CAREFREE) == FC_STATUS2_CAREFREE);
}

- (BOOL)isAltControlOn {
  if (!_data.data)
    return NO;
  return (_data.data->Version == 5 && (_data.data->FCStatusFlags2 & FC_STATUS2_ALTITUDE_CONTROL) == FC_STATUS2_ALTITUDE_CONTROL);
}


- (BOOL)isFailsafeOn {
  if (!_data.data)
    return NO;
  return (_data.data->Version == 5 && (_data.data->FCStatusFlags2 & FC_STATUS2_RC_FAILSAVE_ACTIVE) == FC_STATUS2_RC_FAILSAVE_ACTIVE);
}

- (BOOL)isOut1On {
  if (!_data.data)
    return NO;
  return (_data.data->Version == 5 && (_data.data->FCStatusFlags2 & FC_STATUS2_OUT1_ACTIVE) == FC_STATUS2_OUT1_ACTIVE);
}

- (BOOL)isOut2On {
  if (!_data.data)
    return NO;
  return (_data.data->Version == 5 && (_data.data->FCStatusFlags2 & FC_STATUS2_OUT2_ACTIVE) == FC_STATUS2_OUT2_ACTIVE);
}



///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)init {
  self = [super init];
  if (self != nil) {

    self.data = [IKNaviData data];

    _logActive = NO;
    _logInterval = 1.0;


    NSLog(@"Def:%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);

    NSString *testValue = [[NSUserDefaults standardUserDefaults] stringForKey:kGpxLoggingActive];
    if (testValue) {
      _logActive = [[NSUserDefaults standardUserDefaults] boolForKey:kGpxLoggingActive];
    }

    testValue = [[NSUserDefaults standardUserDefaults] stringForKey:kGpxLoggingInterval];
    if (testValue) {
      _logInterval = [[NSUserDefaults standardUserDefaults] doubleForKey:kGpxLoggingInterval]/1000.0;
    }

//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"IKOSDSoundActive"]) {
//
//      NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Bleep"
//                                                           ofType:@"mp3"];
//      NSURL *url = [NSURL fileURLWithPath:filePath];
//
//      NSError *error;
//      self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
//
//      [self.audioPlayer prepareToPlay];
//    }

    self.routeTransferController = [[MKTRouteTransferController alloc] initWithRoute:nil delegate:self];

    for (int i = 0; i < 12; i++)
      motorData[i] = nil;

    if ([[CLLocationManager class] respondsToSelector:@selector(authorizationStatus)]) {
      canFollowMe = ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized ||
              [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined);
    }
    else {
      canFollowMe = [CLLocationManager locationServicesEnabled];
    }

    _followMe = NO;
    _followMeCanStart = NO;

    self.lm = [[CLLocationManager alloc] init];
    self.lm.delegate = self;

    BOOL b = [[NSUserDefaults standardUserDefaults] boolForKey:@"FollowMeAccuracyBestForNavigation"];
    if (b)
      self.lm.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    else
      self.lm.desiredAccuracy = kCLLocationAccuracyBest;


  }
  return self;
}

- (void)dealloc {

  [self.audioPlayer stop];
  self.audioPlayer = nil;

  [self.lm stopUpdatingLocation];
  self.lm.delegate = nil;
  self.lm = nil;

  self.data = nil;

  self.managedObjectContext = nil;
  self.gpxLogSession = nil;
}

#pragma mark - MKCommunikation

- (void)startRequesting {

  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

  [nc addObserver:self
         selector:@selector(osdNotification:)
             name:MKOsdNotification
           object:nil];

  [nc addObserver:self
         selector:@selector(debugValueNotification:)
             name:MKDebugDataNotification
           object:nil];

  [nc addObserver:self
         selector:@selector(motorDataNotification:)
             name:MKMotorDataNotification
           object:nil];


  requestTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(sendOsdRefreshRequest)
                                                userInfo:nil repeats:YES];

  requestCount = 0;
  [self performSelector:@selector(sendOsdRefreshRequest) withObject:self afterDelay:0.1];

}

- (void)stopRequesting {

  [self.audioPlayer stop];

  [requestTimer invalidate];
  requestTimer = nil;

  [self stopGpxLog];

  [followMeTimer invalidate];
  followMeTimer = nil;


//  if (_logActive) {
//    self.ncLogSession.timeStampEnd = [NSDate date];
//
//    NSError *error = nil;
//    if (![self.managedObjectContext save:&error]) {
//      qlcritical(@"Could not save the NC-Log records %@", error);
//    }
//  }

  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc removeObserver:self];

}


- (void)sendOsdRefreshRequest {

  if (requestCount > 3)
    [self.delegate noDataAvailable];

  [[MKConnectionController sharedMKConnectionController] requestOsdDataForInterval:40];
  requestCount++;

  [[MKConnectionController sharedMKConnectionController] requestDebugValueForInterval:40];
  [[MKConnectionController sharedMKConnectionController] requestMotorDataForInterval:40];
}

- (void)osdNotification:(NSNotification *)aNotification {

  _followMeCanStart = self.lm.location.horizontalAccuracy >= 0.0;

  requestCount = 0;
  self.data = [[aNotification userInfo] objectForKey:kIKDataKeyOsd];

  [self.delegate newValue:self];

  if (self.isLowBat)
    [self.audioPlayer play];
  else
    [self.audioPlayer stop];
  
  //////////////////////////////////////
  
  if(_logActive){
    if(self.isFlying){
      if(!self.isGpxLogOn)
        [self startGpxLog];
    }
    else{
      [self stopGpxLog];
    }
  }
  
  if(self.data.data->WaypointNumber!=[self.routePoints count] && self.routeTransferController.state == RouteControllerIsIdle){
    [self.routeTransferController downloadRouteFromNaviCtrl];
  }
}

- (void)debugValueNotification:(NSNotification *)aNotification {
  self.debugData = [[aNotification userInfo] objectForKey:kIKDataKeyDebugData];
  poiIndex = [[self.debugData analogValueAtIndex:16] integerValue];
}


- (void)motorDataNotification:(NSNotification *)aNotification {
  NSInteger index = [[[aNotification userInfo] objectForKey:kMKDataKeyIndex] integerValue];

  IKMotorData *motorValue = [[aNotification userInfo] objectForKey:kIKDataKeyMotorData];
  motorData[index] = nil;
  motorCurrent[index] = NSIntegerMin;
  motorTemp[index] = NSIntegerMin;

  if ((motorValue.state & 0x80) == 0x80){
    motorData[index] = [NSString stringWithFormat:@"BL%-2ld: %ld°C %.0fA", (long)index + 1, (long)motorValue.temperature,
                                                  motorValue.current / 10.0 /*, motorValue.maxPWM, motorValue.state*/];
    
    motorCurrent[index] = motorValue.current;
    motorTemp[index] = motorValue.temperature;
  }
}

#pragma mark - GPX Logging

- (void)startGpxLog {

  if (self.isGpxLogOn)
    [self stopGpxLog];

  if (self.areEnginesOn && self.isFlying) {

    self.gpxLogSession = [MKTGpxSession create];

    IKDeviceVersion *ncVersion = [[MKConnectionController sharedMKConnectionController] versionForAddress:kIKMkAddressNC];
    IKDeviceVersion *fcVersion = [[MKConnectionController sharedMKConnectionController] versionForAddress:kIKMkAddressFC];

    self.gpxLogSession.descr = [NSString stringWithFormat:@"%@ %@", ncVersion.versionString, fcVersion.versionString];
    [[IBCoreDataStore mainStore] save];

    logTimer = [NSTimer scheduledTimerWithTimeInterval:_logInterval
                                                target:self
                                              selector:@selector(logNCData)
                                              userInfo:nil repeats:YES];

  }

}

- (void)stopGpxLog {

  if (logTimer) {
    [logTimer invalidate];
    logTimer = nil;

    self.gpxLogSession.endTime = [NSDate date];
    [self.gpxLogSession calculateCoordinateRegionForRecords];

    [[IBCoreDataStore mainStore] save];

    self.gpxLogSession = nil;
  }

}

- (BOOL)isGpxLogOn {
  return logTimer != nil;
}

- (void)logNCData {
  
  MKTGpxRecord* record = [MKTGpxRecord create];
  
  IKMkNaviData* mkData = self.data.data;
  record.gpsPos = [IKGPSPos positionWithMkPos:&mkData->CurrentPosition];
  record.satellites = @(mkData->SatsInUse);
  
  NSMutableArray* motorValues = [NSMutableArray arrayWithCapacity:12];
  for(int i=0;i<12;i++){
    [motorValues pushObject:@(motorTemp[i])];
  }
  
  NSString* motorTempData = [motorValues componentsJoinedByString:@","];

  [motorValues removeAllObjects];
  for(int i=0;i<12;i++){
    [motorValues pushObject:@(motorCurrent[i])];
  }
  NSString* motorCurrentData = [motorValues componentsJoinedByString:@","];

  
  NSDictionary* extensions = @{
    @"Altimeter": @(mkData->Altimeter / 20),
    @"Set_Altitude": @(mkData->SetpointAltitude / 20),
    @"Variometer": @(mkData->Variometer),
    @"Course": @(mkData->Heading),
    @"VerticalSpeed": @(mkData->GroundSpeed),
    @"FlightTime": [NSString stringWithFormat:@"%02d:%02d", mkData->FlyingTime / 60, mkData->FlyingTime % 60],
    @"Voltage": [NSString stringWithFormat:@"%0.1f", mkData->UBat / 10.0],
    @"Current": [NSString stringWithFormat:@"%0.1f", mkData->Current / 10.0],
    @"Capacity": @(mkData->UsedCapacity),

    @"RCQuality": @(mkData->RC_Quality),
    @"RSSI": @(mkData->RC_Quality),
    @"Compass": @(mkData->CompassHeading),
    @"NickAngle": @(mkData->AngleNick),
    @"RollAngle": @(mkData->AngleRoll),

    @"NCFlags": [NSString stringWithFormat:@"0x%02x", mkData->NCFlags],
    @"FCFlags2": [NSString stringWithFormat:@"0x%02x,0x%02x", mkData->FCStatusFlags,mkData->FCStatusFlags2],

    @"Thrust": @(mkData->Gas),
    @"ErrorCode": @(mkData->Errorcode),
    @"WaypointIndex": @(mkData->WaypointIndex),
    @"WaypointTotal": @(mkData->WaypointNumber),
    @"WaypointHoldTime": [NSString stringWithFormat:@"%02d:%02d", mkData->TargetHoldTime / 60, mkData->TargetHoldTime % 60],
    @"OperatingRadius": @(mkData->OperatingRadius),

    @"HomeDistance": @(mkData->HomePositionDeviation.Distance),
    @"TargetBearing": @(mkData->TargetPositionDeviation.Bearing),
    @"TargetDistance": @(mkData->TargetPositionDeviation.Distance),

    @"MotorCurrent": motorCurrentData,
    @"BL_Temperature": motorTempData,

    };

  record.extensions = extensions;
  
  [self.gpxLogSession addRecordsObject:record];
  DDLogVerbose(@"Did create a GPX log record");
}

#pragma mark - Location Manager Stuff

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {

  NSString *errorType = (error.code == kCLErrorDenied) ?
          NSLocalizedString(@"Access Denied", @"Access Denied") :
          NSLocalizedString(@"Unknown Error", @"Unknown Error");

  UIAlertView *alert = [[UIAlertView alloc]
          initWithTitle:NSLocalizedString(@"Error getting Location", @"Error getting Location") message:errorType
               delegate:self
      cancelButtonTitle:NSLocalizedString(@"Okay", @"Okay") otherButtonTitles:nil];
  [alert show];
  self.lm = nil;
}


- (NSInteger)calccurrentAltitude {

  IKNaviData *d = self.data;

  NSInteger altitudeAir = d.data->Altimeter / 20;

  NSInteger altitudeGPS = altitudeAir;

  if (d.data->CurrentPosition.Status != INVALID && d.data->HomePosition.Status != INVALID) {
    altitudeGPS = d.data->CurrentPosition.Altitude - d.data->HomePosition.Altitude;
  }

  NSInteger altitude = (4 * altitudeAir + altitudeGPS) / 5;

  return altitude * 10;
}

- (void)sendFollowMeRequest {
  if (!_followMeCanStart) return;

  IKPoint *targetPoint = [[IKPoint alloc] initWithCoordinate:self.lm.location.coordinate];

  targetPoint.index = 1;
  targetPoint.type = POINT_TYPE_WP;
  targetPoint.heading = -1;
  targetPoint.holdTime = 60;
  targetPoint.eventFlag = 1;
  targetPoint.wpEventChannelValue = 100;
  targetPoint.altitudeRate = 0;
  targetPoint.cameraNickControl = [[NSUserDefaults standardUserDefaults] boolForKey:@"FollowMeCameraNick"];

  switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"FollowMeHeigth"]) {
    case 1:
      targetPoint.altitude = 1;
      break;
    default:
      targetPoint.altitude = [self calccurrentAltitude];
      break;
  }

  [[MKConnectionController sharedMKConnectionController] sendPoint:targetPoint];
  followMeRequests++;
}


- (NSString *)motorDataForIndex:(NSUInteger)index {
  if (index > 11)
    return nil;

  return motorData[index];
}

- (void)routeControllerFinishedDownload:(MKTRouteTransferController *)controller{
  self.routePoints = [NSArray arrayWithArray:self.routeTransferController.points];
  if ([self.delegate respondsToSelector:@selector(newRouteDataAvailable:)]) {
      [self.delegate newRouteDataAvailable:self.routePoints];
  }
  
}



@end
