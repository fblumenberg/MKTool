//
//  YKCLSortDescriptor.h
//  YelpKit
//
//  Created by Gabriel Handford on 9/16/09.
//  Copyright 2009 Yelp. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

/*!
 Sort descriptor for object with coordinate (CLLocationCoordinate2D) properties.
 
    YKCLSortDescriptor *distanceSortDescriptor = [[[YKCLSortDescriptor alloc] initWithAscending:YES coordinate:coordinate] autorelease];
    [annotations sortUsingDescriptors:[NSArray arrayWithObject:distanceSortDescriptor]];
 
 Or with custom latitude and longitude selectors:
 
    YKCLSortDescriptor *distanceSortDescriptor = [[[YKCLSortDescriptor alloc] initWithLatitudeKey:@"business.latitudeNumber" longitudeKey:@"business.longitudeNumber" ascending:YES coordinate:coordinate] autorelease];
    [bookmarks sortUsingDescriptors:[NSArray arrayWithObject:distanceSortDescriptor]];
 
 */
@interface YKCLSortDescriptor : NSSortDescriptor {
  CLLocationCoordinate2D _coordinate;
  NSString *_latitudeKey;
  NSString *_longitudeKey;
}

/*!
 Sort descriptor when objects respond to the "coordinate" property.
 @param ascending Ascending order
 @param coordinate Coordinate to sort from
 */
- (id)initWithAscending:(BOOL)ascending coordinate:(CLLocationCoordinate2D)coordinate;

/*!
 Sort descriptor when objects respond to a latitude and longitude property.
 @param latitudeKey Name of latitude property
 @param longitudeKey Name of longitude property
 @param ascending Ascending order
 @param coordinate Coordinate to sort from
 */
- (id)initWithLatitudeKey:(NSString *)latitudeKey longitudeKey:(NSString *)longitudeKey ascending:(BOOL)ascending coordinate:(CLLocationCoordinate2D)coordinate;

@end