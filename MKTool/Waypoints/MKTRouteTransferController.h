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

#import <Foundation/Foundation.h>

@protocol MKTRouteTransferControllerDelegate;

@class MKTRoute;

typedef enum {
  RouteControllerIsIdle,
  RouteControllerIsUploading,
  RouteControllerIsDownloading
} RouteControllerState;

@interface MKTRouteTransferController : NSObject {

  RouteControllerState state;
  NSUInteger currIndex;
  NSUInteger firstIndex;
  NSUInteger lastIndex;
  NSUInteger uploadIndex;
}

@property(readonly) RouteControllerState state;
@property(assign) id <MKTRouteTransferControllerDelegate> delegate;
@property(retain) NSMutableArray *points;

- (id)initWithRoute:(MKTRoute*)route delegate:(id <MKTRouteTransferControllerDelegate>)delegate;

- (void)uploadRouteToNaviCtrlFrom:(NSUInteger)firstIndex to:(NSUInteger)lastIndex;

- (void)downloadRouteFromNaviCtrl;

@end

@protocol MKTRouteTransferControllerDelegate <NSObject>

@optional
- (void)routeControllerStartDownload:(MKTRouteTransferController *)controller forIndex:(NSInteger)index;

- (void)routeControllerFinishedDownload:(MKTRouteTransferController *)controller forIndex:(NSInteger)index of:(NSInteger)count;

- (void)routeControllerFinishedDownload:(MKTRouteTransferController *)controller;

- (void)routeControllerFailedDownload:(MKTRouteTransferController *)controller WithError:(NSError *)error;

- (void)routeControllerStartUpload:(MKTRouteTransferController *)controller forIndex:(NSInteger)index of:(NSInteger)count;

- (void)routeControllerFinishedUpload:(MKTRouteTransferController *)controller forIndex:(NSInteger)index of:(NSInteger)count;

- (void)routeControllerFinishedUpload:(MKTRouteTransferController *)controller;

- (void)routeControllerFailedUpload:(MKTRouteTransferController *)controller WithError:(NSError *)error;


@end