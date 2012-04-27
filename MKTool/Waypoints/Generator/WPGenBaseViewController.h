// ///////////////////////////////////////////////////////////////////////////////
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
// ///////////////////////////////////////////////////////////////////////////////


#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "InnerBand.h"

#import "WPGenBaseDataSource.h"

DECLARE_KEY(WPaltitude);
DECLARE_KEY(WPprefix);
DECLARE_KEY(WPtoleranceRadius);
DECLARE_KEY(WPholdTime);
DECLARE_KEY(WPcamAngle);
DECLARE_KEY(WPheading);
DECLARE_KEY(WPaltitudeRate);
DECLARE_KEY(WPspeed);
DECLARE_KEY(WPwpEventChannelValue);
DECLARE_KEY(WPclearWpList);
DECLARE_KEY(WPnoPointsX);
DECLARE_KEY(WPnoPointsY);
DECLARE_KEY(WPnoPoints);
DECLARE_KEY(WPclockwise);
DECLARE_KEY(WPclosed);
DECLARE_KEY(WPstartangle);

@class MKTPoint;
@protocol WPGenBaseViewControllerDelegate;

@interface WPGenBaseViewController : UIViewController

- (id)initWithShapeView:(UIView *)shapeView forMapView:(MKMapView *)mapView;

@property(nonatomic, retain) NSMutableDictionary *wpData;
@property(nonatomic, assign) id <WPGenBaseViewControllerDelegate> delegate;
@property(nonatomic, retain) MKMapView *mapView;

@property(nonatomic, retain) IBOutlet UIView *shapeView;
@property(nonatomic, retain) WPGenBaseDataSource *dataSource;
@property(nonatomic, assign) UIViewController* parentController;

- (NSArray *)generatePointsList;

- (IBAction)closeView:(id)sender;

- (IBAction)generatePoints:(id)sender;
- (IBAction)showConfig:(id)sender;
- (MKTPoint *)pointOfType:(NSInteger)type forCoordinate:(CLLocationCoordinate2D)coordinate;

@end

@protocol WPGenBaseViewControllerDelegate

- (void)controllerWillClose:(WPGenBaseViewController *)controller;
- (void)controller:(WPGenBaseViewController *)controller generatedPoints:(NSArray *)points clearList:(BOOL)clear;

@end
