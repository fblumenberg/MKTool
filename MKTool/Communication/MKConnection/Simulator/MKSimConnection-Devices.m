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

@implementation MKSimConnection (Versions)

- (void)initDevices {

  NSMutableArray *dev = [NSMutableArray arrayWithCapacity:4];
  IKMkVersionInfo *versionInfo;

  //  kIKMkAddressAll   =0,
  [dev addObject:[NSNull null]];

  //  kIKMkAddressFC    =1,
  versionInfo = calloc(sizeof(IKMkVersionInfo), 1);

  versionInfo->SWMajor = 0;
  versionInfo->SWMinor = 90;
  versionInfo->SWPatch = 3;
  versionInfo->ProtoMajor = 11;
  versionInfo->ProtoMinor = 0;

  [dev addObject:[NSValue valueWithPointer:versionInfo]];

  //  kIKMkAddressNC    =2,
  versionInfo = calloc(sizeof(IKMkVersionInfo), 1);

  versionInfo->SWMajor = 0;
  versionInfo->SWMinor = 30;
  versionInfo->SWPatch = 0;
  versionInfo->ProtoMajor = 11;
  versionInfo->ProtoMinor = 0;

  [dev addObject:[NSValue valueWithPointer:versionInfo]];
  //  kIKMkAddressMK3MAg=3,
  versionInfo = calloc(sizeof(IKMkVersionInfo), 1);

  versionInfo->SWMajor = 0;
  versionInfo->SWMinor = 23;
  versionInfo->SWPatch = 0;
  versionInfo->ProtoMajor = 11;
  versionInfo->ProtoMinor = 0;

  [dev addObject:[NSValue valueWithPointer:versionInfo]];

  self.devices = dev;
}

- (void)clearDevices {

  for (id obj in self.devices) {
    if ([obj isEqual:[NSNull null]] == NO) {
      free([((NSValue *) obj) pointerValue]);
    }
  }

  self.devices = nil;
}

- (void)sendVersionForAddress:(IKMkAddress)address {

  if (address > kIKMkAddressAll && address <= kIKMkAddressMK3MAg) {

    NSValue *value = [self.devices objectAtIndex:address];
    IKMkVersionInfo *versionInfo = [value pointerValue];

    NSData *payload = [NSData dataWithBytes:(void *) versionInfo length:sizeof(IKMkVersionInfo)];

    [self sendResponse:[payload dataWithCommand:MKCommandVersionResponse forAddress:address]];
  }
}

- (IKMkAddress)addressForRedirecIndex:(NSUInteger)index {
  NSAssert(index >= 0 && index <= 2, @"Index wrong");

  static IKMkAddress mapping[] = {kIKMkAddressFC, kIKMkAddressMK3MAg, kIKMkAddressMKGPS};

  return mapping[index];
}

@end
