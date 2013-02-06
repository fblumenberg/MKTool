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
#import "NSData+MKCommandDecode.h"
#import "NSData+MKCommandEncode.h"
#import "NSData+MKPayloadDecode.h"
#import "NSData+MKPayloadEncode.h"

#import "MKDataConstants.h"

#import "DDLog.h"


static NSString *const MKSimConnectionException = @"MKSimConnectionException";

///////////////////////////////////////////////////////////////////////////////
#pragma mark - DDRegisteredDynamicLogging
static int ddLogLevel = LOG_LEVEL_WARN;

@interface MKSimConnection (DDRegisteredDynamicLogging) <DDRegisteredDynamicLogging>
@end

@implementation MKSimConnection (DDRegisteredDynamicLogging)
+ (int)ddLogLevel {
  return ddLogLevel;
}

+ (void)ddSetLogLevel:(int)logLevel {
  ddLogLevel = logLevel;
}
@end
///////////////////////////////////////////////////////////////////////////////


@interface MKSimConnection () {
  IKMkAddress currentDevice;
  NSData *magicPacket;
  BOOL connected;
}

- (void)handleRequest:(NSData *)data;
- (void)handleConnect;
- (void)handleDisconnect;

@end

@implementation MKSimConnection

#pragma mark Properties

@synthesize delegate;
@synthesize devices;
@synthesize settings;
@synthesize activeSetting;
@synthesize mixerTable;
@synthesize naviData,osdData,osdTimer,dataRow;

#pragma mark Initialization

- (id)init {
  return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id <MKConnectionDelegate>)theDelegate; {
  self = [super init];
  if (self) {
    self.delegate = theDelegate;

    activeSetting = 3;

    connected = NO;

    uint8_t bytes[6];
    bytes[0] = 0x1B;
    bytes[1] = 0x1B;
    bytes[2] = 0x55;
    bytes[3] = 0xAA;
    bytes[4] = 0x00;
    bytes[5] = 0x0D;

    magicPacket = [NSData dataWithBytes:&bytes length:6];

    [self initDevices];
    currentDevice = kIKMkAddressNC;
    [self initSettings];
    [self initMixer];
    [self initNCData];
  }
  return self;
}

- (void)dealloc {
  [self clearDevices];
  [self.osdTimer invalidate];
  self.osdTimer = nil;
}

#pragma mark - mark MKInput

- (void)handleConnect {
  connected = YES;
  if ([delegate respondsToSelector:@selector(didConnectTo:)]) {
    [delegate didConnectTo:@"SIMULATOR"];
  }
}

- (BOOL)connectTo:(NSDictionary *)connectionInfo {

  NSAssert(delegate != nil, @"Attempting to connect without a delegate. Set a delegate first.");
  [self performSelector:@selector(handleConnect) withObject:nil afterDelay:0.2];

  return YES;
}

- (BOOL)isConnected; {
  return connected;
}


- (void)handleDisconnect {
  connected = NO;
  if ([delegate respondsToSelector:@selector(didDisconnect)]) {
    [delegate didDisconnect];
  }
}

- (void)disconnect; {
  [self performSelector:@selector(handleDisconnect) withObject:nil afterDelay:0.1];
}

- (void)writeMkData:(NSData *)data; {
  [self performSelector:@selector(handleRequest:) withObject:data afterDelay:0.1];
}

#pragma mark -

- (void)handleRequest:(NSData *)data {

  if ([data isEqual:magicPacket]) {
    DDLogVerbose(@"Magic packet received, switch to NC");
    currentDevice = kIKMkAddressNC;
    return;
  }

  if ([data isCrcOk]) {

    NSData *payload = [data payload];

    DDLogVerbose(@"Need responde for command %c", [data command]);

    if( [data address]==kIKMkAddressNC ){
      switch ([data command]) {
        case MKCommandOsdRequest:
          [self sendNCDataResponse];
          break;
        case MKCommandRedirectRequest:
          currentDevice = [self addressForRedirecIndex:[payload index]];
          DDLogVerbose(@"Switch to device %d", currentDevice);
          break;
        default:
          DDLogVerbose(@"Unknown command %c", [data command]);
          return;
      }
    }
    else {
      
      switch ([data command]) {
        case MKCommandVersionRequest:
          [self sendVersionForAddress:currentDevice];
          break;
        case MKCommandReadSettingsRequest:
          [self sendReadSettingsResponseForIndex:[payload index]];
          break;
        case MKCommandWriteSettingsRequest:
          [self handleWriteSettingResponse:payload];
          break;
        case MKCommandChannelsValueRequest:
          [self sendPPMChannelsResponse];
          break;
        case MKCommandMixerReadRequest:
          [self sendReadMixerResponse];
          break;
        case MKCommandMixerWriteRequest:
          [self handleWriteMixerResponse:payload];
          break;
        default:
          DDLogVerbose(@"Unknown command %c", [data command]);
          return;
      }
    }
  }
}

- (void)sendResponse:(NSData *)data {
  if ([delegate respondsToSelector:@selector(didReadMkData:)]) {
    [delegate didReadMkData:data];
  }
}

#pragma  -

- (void)sendPPMChannelsResponse; {
  int16_t data[26];

  for (int i = 0; i < 26; i++) {
    data[i] = random() % 250;
  }

  NSData *payload = [NSData dataWithBytes:(void *) &data length:sizeof(data)];
  [self sendResponse:[payload dataWithCommand:MKCommandChannelsValueResponse forAddress:kIKMkAddressFC]];
}


@end
