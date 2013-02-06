// ///////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2010-2012, Frank Blumenberg
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


#import "IKMixerTable.h"

@implementation IKMixerMotorData

@synthesize gas;
@synthesize nick;
@synthesize roll;
@synthesize yaw;

@end


@interface IKMixerTable () {
  IKMkMixerTable _mixerTable;
}

@end

@implementation IKMixerTable

+ (id)tableWithData:(NSData *)data {
  return [[IKMixerTable alloc] initWithData:data];
}

- (id)initWithData:(NSData *)data {
  self = [super init];
  if (self) {
    memcpy(&_mixerTable, [data bytes], sizeof(_mixerTable));
  }
  return self;
}

- (NSData *)data {
  return [NSData dataWithBytes:(unsigned char *) &_mixerTable length:sizeof(_mixerTable)];
}

- (NSString *)name {
  return [NSString stringWithCString:(const char *) _mixerTable.Name encoding:NSASCIIStringEncoding];
}

- (void)setName:(NSString *)name {

  memset(_mixerTable.Name, 0, 12);

  [name getBytes:(void *) _mixerTable.Name
       maxLength:12
      usedLength:NULL encoding:NSASCIIStringEncoding
         options:0
           range:NSMakeRange(0, [name length])
  remainingRange:NULL];
}

- (IKMixerMotorData *)dataForMotor:(NSUInteger)motor {
  NSAssert(motor >= 0 && motor < 16, @"Wron motor index");

  IKMixerMotorData *data = [IKMixerMotorData new];
  data.gas = _mixerTable.Motor[motor][0];
  data.nick = _mixerTable.Motor[motor][1];
  data.roll = _mixerTable.Motor[motor][2];
  data.yaw = _mixerTable.Motor[motor][3];

  return data;
}

- (void)setData:(IKMixerMotorData *)data forMotor:(NSUInteger)motor {
  NSAssert(motor >= 0 && motor < 16, @"Wron motor index");

  _mixerTable.Motor[motor][0] = (int8_t) data.gas;
  _mixerTable.Motor[motor][1] = (int8_t) data.nick;
  _mixerTable.Motor[motor][2] = (int8_t) data.roll;
  _mixerTable.Motor[motor][3] = (int8_t) data.yaw;
}

@end
