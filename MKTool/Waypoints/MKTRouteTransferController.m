  /////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2011, Frank Blumenberg
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
/////////////////////////////////////////////////////////////////////////////////

#import <GHKit/GHKit.h>

#import "MKTRouteTransferController.h"

#import "MKConnectionController.h"
#import "MKDataConstants.h"
#import "IKPoint.h"
#import "MKTRoute.h"
#import "MKTPoint+MKTPoint_IKPoint.h"

#import <CocoaLumberjack/CocoaLumberjack.h>


@interface MKTRouteTransferController ()

@property(strong) NSTimer* timeoutTimer;

@property(strong) MKTRoute* route;

- (void)uploadPoint:(NSUInteger)index;

- (void)downloadPoint:(NSUInteger)index;

@end

///////////////////////////////////////////////////////////////////////////////
#pragma mark - DDRegisteredDynamicLogging
static int ddLogLevel = LOG_LEVEL_WARN;

@interface MKTRouteTransferController (DDRegisteredDynamicLogging) <DDRegisteredDynamicLogging>
@end

@implementation MKTRouteTransferController (DDRegisteredDynamicLogging)
+ (int)ddLogLevel {
  return ddLogLevel;
}

+ (void)ddSetLogLevel:(int)logLevel {
  ddLogLevel = logLevel;
}
@end
///////////////////////////////////////////////////////////////////////////////


@implementation MKTRouteTransferController

@synthesize delegate;
@synthesize points;
@synthesize state;

- (id)initWithRoute:(MKTRoute *)route delegate:(id<MKTRouteTransferControllerDelegate>)aDelegate{
  self = [super init];
  if (self) {
    self.delegate = aDelegate;
    self.route = route;

    state = RouteControllerIsIdle;

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(writePointNotification:)
               name:MKWritePointNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(readPointNotification:)
               name:MKReadPointNotification
             object:nil];
    
  }
  return self;
}

- (void)dealloc {
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc removeObserver:self];
  
  [self.timeoutTimer invalidate];
  self.timeoutTimer=nil;
}


////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Upload 

- (void)uploadRouteToNaviCtrlFrom:(NSUInteger)fromIndex to:(NSUInteger)toIndex {

  self.points = [NSMutableArray arrayWithCapacity:[self.route count]+1];
  
  [self.points addObject:[self buildClearPoint]];

  NSInteger firstIndex = fromIndex-1;
  NSInteger lastIndex = toIndex-1;
  
  uploadIndex = 0;
  retryCounter = 0;
  
  NSArray* routePoints = [self.route orderedPoints];
  
  for (NSUInteger i=firstIndex;i<=lastIndex;i++) {
    MKTPoint* p = [routePoints objectAtIndex:i];
    IKPoint *ikPoint = [p toIKPoint];
    [self.points addObject:ikPoint];
  }
  
  state = RouteControllerIsUploading;
  
  DDLogInfo(@"Start uploading route  from %ld to%ld",(long)currIndex,(long)lastIndex);
  [[MKConnectionController sharedMKConnectionController] activateNaviCtrl];
   
  [self uploadPoint:uploadIndex];

}

- (IKPoint*)buildClearPoint {
  
  IKPoint *p = [[IKPoint alloc] init];
  p.status = INVALID;
  p.index = 0;
  
  return p;
}


- (void)uploadPoint:(NSUInteger)index {

  IKPoint *p = (IKPoint *) [self.points objectAtIndex:index];
  
  p.index = uploadIndex;
  
  DDLogInfo(@"Upload point (%lu) %@", (unsigned long)index, p);
  [[MKConnectionController sharedMKConnectionController] writePoint:p];
  [self performSelector:@selector(uploadTimeout) withObject:self afterDelay:2.0];

  if ([self.delegate respondsToSelector:@selector(routeControllerStartUpload:forIndex:of:)])
    [self.delegate routeControllerStartUpload:self forIndex:p.index of:[self.points count]];
}

- (void)writePointNotification:(NSNotification *)aNotification {

  [NSObject cancelPreviousPerformRequestsWithTarget:self];

  NSDictionary *d = [aNotification userInfo];
  NSInteger resultIndex = [[d objectForKey:kMKDataKeyIndex] integerValue];
  DDLogInfo(@"Upload point (%ld) finished", (long)resultIndex);
  
  if (state != RouteControllerIsUploading || resultIndex!=uploadIndex) {
    DDLogInfo(@"Ignore result from WP upload");
    return;
  }

  if ([self.delegate respondsToSelector:@selector(routeControllerFinishedUpload:forIndex:of:)])
    [self.delegate routeControllerFinishedUpload:self forIndex:uploadIndex of:[self.points count]];
  
  if (state == RouteControllerIsUploading && uploadIndex < ([self.points count]-1) && resultIndex<254) {
    uploadIndex++;
    retryCounter = 0;
    [self uploadPoint:uploadIndex];
  }
  else {
    if( resultIndex>=254 ){
      if ([self.delegate respondsToSelector:@selector(routeControllerFailedUpload:WithError:)]){
        
        NSString* description = NSLocalizedString(@"Maximum count of waypoints reached", "WP Upload");
        NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : description};
        NSError *error = [[NSError alloc] initWithDomain:@"MK" code:1 userInfo:errorDictionary];
        
        [self.delegate routeControllerFailedUpload:self WithError:error];
      }
      DDLogInfo(@"Maximum count of waypoints reached");
    }
    else{
      if ([self.delegate respondsToSelector:@selector(routeControllerFinishedUpload:)])
        [self.delegate routeControllerFinishedUpload:self];
    }
    
    state = RouteControllerIsIdle;
  }
}

- (void) uploadTimeout {
  
  [NSObject cancelPreviousPerformRequestsWithTarget:self];
  
  if(++retryCounter>5){
    
    [self.timeoutTimer invalidate];
    self.timeoutTimer=nil;
    
    NSString* description = NSLocalizedString(@"Thimeout while uploading waypoints", "WP Upload");
    NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : description};
    NSError *error = [[NSError alloc] initWithDomain:@"MK" code:1 userInfo:errorDictionary];
    
    state = RouteControllerIsIdle;
    [self.delegate routeControllerFailedUpload:self WithError:error];
  }
  else{
    [self uploadPoint:uploadIndex];
  }
  
}

////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Download 

- (void)downloadPoint:(NSUInteger)index {

  DDLogInfo(@"Download point (%lu)", (unsigned long)index);
  [[MKConnectionController sharedMKConnectionController] requestPointForIndex:index + 1];

  if ([self.delegate respondsToSelector:@selector(routeControllerStartDownload:forIndex:)])
    [self.delegate routeControllerStartDownload:self forIndex:index];
}

- (void)downloadRouteFromNaviCtrl {

  self.points = [NSMutableArray new];

  currIndex = 0;
  state = RouteControllerIsDownloading;

  [self downloadPoint:currIndex++];
}

- (void)readPointNotification:(NSNotification *)aNotification {

  NSDictionary *d = [aNotification userInfo];
  NSInteger count = [[d objectForKey:kMKDataKeyMaxItem] integerValue];

  BOOL downloadFinished = NO;

  if ([d objectForKey:kMKDataKeyIndex]) {
    NSInteger index = [[d objectForKey:kMKDataKeyIndex] integerValue] - 1;
    DDLogInfo(@"Download point (NC index %ld) finished", (long)index);

    if ([self.delegate respondsToSelector:@selector(routeControllerFinishedUpload:forIndex:of:)])
      [self.delegate routeControllerFinishedUpload:self forIndex:index of:[self.points count]];

    IKPoint *p = [d objectForKey:kIKDataKeyPoint];
    [self.points addObject:p];

    DDLogVerbose(@"Route is now %@", self.points);

    if (state == RouteControllerIsDownloading && currIndex < count) {
      [self downloadPoint:currIndex++];
    }
    else {
      downloadFinished = YES;
    }
  }
  else {
    DDLogError(@"No point for the NC index %ld. Count is %ld", (long)currIndex, (long)count);
    downloadFinished = YES;
  }

  if (downloadFinished) {
    if ([self.delegate respondsToSelector:@selector(routeControllerFinishedDownload:)])
      [self.delegate routeControllerFinishedDownload:self];

    if (state == RouteControllerIsDownloading) {
      state = RouteControllerIsIdle;
    }
  }
}

@end
