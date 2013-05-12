//
//  MKTGpxSessionViewController.h
//  MKTool
//
//  Created by Frank Blumenberg on 12.05.13.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class MKTGpxSession;

@interface MKTGpxSessionViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *startTime;
@property (weak, nonatomic) IBOutlet UILabel *endTime;
@property (weak, nonatomic) IBOutlet UILabel *recordsCount;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong) MKTGpxSession* session;

- (id)initWithSession:(MKTGpxSession*)session;

@end
