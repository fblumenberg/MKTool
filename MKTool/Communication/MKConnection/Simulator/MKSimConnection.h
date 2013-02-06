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

#import <Foundation/Foundation.h>
#import "MKConnection.h"
#import "IKMkDataTypes.h"

@class IKMixerTable;
@class IKNaviData;

@interface MKSimConnection : NSObject <MKConnection>

@property(nonatomic, strong) NSArray *devices;
@property(nonatomic, strong) NSMutableArray *settings;
@property(nonatomic, assign) NSUInteger activeSetting;
@property(nonatomic, strong) IKMixerTable *mixerTable;
@property(nonatomic, strong) IKNaviData *naviData;
@property(nonatomic, assign) NSInteger dataRow;
@property(nonatomic, strong) NSTimer *osdTimer;
@property(nonatomic, retain) NSArray *osdData;


- (void)sendResponse:(NSData *)data;

@end

@interface MKSimConnection (Versions)

- (void)initDevices;
- (void)clearDevices;
- (void)sendVersionForAddress:(IKMkAddress)address;
- (IKMkAddress)addressForRedirecIndex:(NSUInteger)index;

@end

@interface MKSimConnection (Settings)

- (void)initSettings;

- (void)sendReadSettingsResponseForIndex:(NSUInteger)index;
- (void)handleWriteSettingResponse:(NSData *)payload;

@end

@interface MKSimConnection (Mixer)

- (void)initMixer;

- (void)sendReadMixerResponse;
- (void)handleWriteMixerResponse:(NSData *)payload;

@end

@interface MKSimConnection (NCData)

- (void)initNCData;

- (void)sendNCDataResponse;
//- (void)handleWriteMixerResponse:(NSData *)payload;

@end
