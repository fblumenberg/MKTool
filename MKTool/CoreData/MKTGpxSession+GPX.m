// ///////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013, Frank Blumenberg
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

#import "MKTGpxSession+GPX.h"
#import "MKTGpxRecord.h"
#import "MKTGPXExtensions.h"
#import "IKNaviData.h"

#import "GHNSDate+Formatters.h"

#import "GPX.h"

@implementation MKTGpxSession (GPX)

- (BOOL)writeSessionToGPXFile:(NSString *)path{

  NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
  NSString *appDisplayName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
  NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
  NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
  
  NSString *extra=@"";
#ifdef CYDIA
  extra = @"(CYDIA)";
#endif

  NSString* creator = [NSString stringWithFormat:@"%@%@",appDisplayName,extra];
  GPXRoot* root = [GPXRoot rootWithCreator:creator];
  
  root.version = [NSString stringWithFormat:@"%@ (%@)",majorVersion, minorVersion];

  //---------------------------------------------------------
  
  GPXMetadata* metadata = [GPXMetadata new];
  metadata.desc = self.descr;
  metadata.link = [GPXLink linkWithHref:@"http://www.mikrokopter.de"];
  metadata.link.text = @"MikroKopter";
  
  root.metadata = metadata;
  
  //---------------------------------------------------------

  GPXTrack* track = [root newTrack];
  
  track.name = @"Flight";
  
  //---------------------------------------------------------

  GPXTrackSegment* trackSegment = [track newTrackSegment];
  
  [self.orderedRecords enumerateObjectsUsingBlock:^(MKTGpxRecord *r, NSUInteger i, BOOL *stop) {
    IKGPSPos* gpsPos = r.gpsPos;
    GPXTrackPoint* trackPoint = [trackSegment newTrackpointWithLatitude:gpsPos.coordinate.latitude longitude:gpsPos.coordinate.longitude];
    
    trackPoint.elevation = gpsPos.altitude / 1000.0;
    trackPoint.time = r.timestamp;
    trackPoint.satellites = [r.satellites integerValue];
    
    MKTGPXExtensions* extensions = [MKTGPXExtensions extensionsWithDictionary:r.extensions];
    
    trackPoint.extensions = extensions;
    
  }];
  
  
  //---------------------------------------------------------

//  NSLog(@"OUT:%@", root.gpx);
  
  return [root.gpx writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

@end
