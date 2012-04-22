//
//  YKMKAnnotation.h
//  YelpIPhone
//
//  Created by Gabriel Handford on 10/14/10.
//  Copyright 2010 Yelp. All rights reserved.
//

#import <MapKit/MapKit.h>

@protocol YKMKAnnotationView, YKMKAnnotation;


@protocol YKMKAnnotationViewDelegate <NSObject>
- (void)annotationView:(MKAnnotationView<YKMKAnnotationView> *)annotationView didSelectAnnotation:(id<YKMKAnnotation>)annotation;
@end


@protocol YKMKAnnotationView <NSObject>
// Don't add required methods to this protocol
@optional
@property (assign, nonatomic) id<YKMKAnnotationViewDelegate> delegate;
- (NSString *)viewReuseIdentifier;
- (UIView *)view;
@end


@protocol YKMKAnnotation <MKAnnotation>
- (NSString *)viewReuseIdentifier;
- (MKAnnotationView<YKMKAnnotationView> *)view;
- (id<YKMKAnnotation>)annotationForCallout;
@optional
@property (readonly, nonatomic) NSInteger index;
@property (assign, nonatomic, getter=isSelected) BOOL selected;
- (UIImage *)annotationImageForSelected:(BOOL)selected; // If nil uses default
@end


/*!
 An implementation for MKAnnotation protocol.
 */
@interface YKMKAnnotation : NSObject <MKAnnotation, YKMKAnnotation> {
  CLLocationCoordinate2D _coordinate;
  NSString *_title;
  NSString *_subtitle;
  BOOL _draggable;
  BOOL _selected;
  BOOL _enabled;
  BOOL _canShowCallout;
  BOOL _animatesDrop;
  MKPinAnnotationColor _color;
  UIView *_leftCalloutAccessoryView;
  NSInteger _index;
}

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (assign, nonatomic, getter=isDraggable) BOOL draggable;
@property (assign, nonatomic, getter=isEnabled) BOOL enabled;
@property (assign, nonatomic) BOOL canShowCallout;
@property (assign, nonatomic) BOOL animatesDrop;
@property (assign, nonatomic) MKPinAnnotationColor color;
@property (retain, nonatomic) UIView *leftCalloutAccessoryView;
@property (assign, nonatomic) NSInteger index;


+ (YKMKAnnotation *)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title subtitle:(NSString *)subtitle leftCalloutAccessoryView:(UIView *)leftCalloutAccessoryView draggable:(BOOL)draggable;
@end

