//
//  YKCLUtils.h
//  YelpKit
//
//  Created by Gabriel Handford on 1/29/09.
//  Copyright 2009 Yelp. All rights reserved.
//

#import "YKDefines.h"
#import <CoreLocation/CoreLocation.h>

/*!
 References:
 http://www.movable-type.co.uk/scripts/latlong.html
 http://wiki.answers.com/Q/How_many_miles_are_in_a_degree_of_longitude_or_latitude
 */


/*! 
 Geocoded address accuracy constants.
 http://code.google.com/apis/maps/documentation/reference.html#GGeoAddressAccuracy
 */
typedef enum {
  YKGeoAddressAccuracyUnknown = 0,
  YKGeoAddressAccuracyCountry = 1,
  YKGeoAddressAccuracyRegion = 2,
  YKGeoAddressAccuracySubRegion = 3,
  YKGeoAddressAccuracyTown = 4,
  YKGeoAddressAccuracyPostCode = 5,
  YKGeoAddressAccuracyStreet = 6,
  YKGeoAddressAccuracyIntersection = 7,
  YKGeoAddressAccuracyAddress = 8,
  YKGeoAddressAccuracyPremise = 9
} YKGeoAddressAccuracy;

// Macros
#define YK_DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)

#define YK_RADIANS_TO_DEGREES(__RADIANS__) ((__RADIANS__) * (180.0 / M_PI))

#define kYKMetersToMiles 0.000621371192
#define kYKMilesToMeters 1609.34401
#define kYKMetersToDegrees 0.000008992
#define kYKDegreesToMeters 111200.0

#define kYKMilesPerLongitude 69.16022727272727;
#define kYKMilesPerLatitude 68.70795454545454;


/*!
 Difference between coordinates (c2-c1).
 
 Haversine Formula
 R = earth’s radius (mean radius = 6,371km)
 Δlat = lat2 − lat1
 Δlong = long2 − long1
 a = sin²(Δlat/2) + cos(lat1).cos(lat2).sin²(Δlong/2)
 c = 2.atan2(√a, √(1−a))
 d = R.c
 
 @param c1 First coordinate
 @param c2 Second coordinate
 @param absolute If YES will take absolute value
 @result Distance in meters
 */
CLLocationDistance YKCLLocationCoordinateDistance(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2, BOOL absolute);

/*!
 Bearing (degrees angle from north) from location coordinate c1 to c2.
 @param c1 First coordinate
 @param c2 Second coordinate
 @result Bearing in degrees
 */
double YKCLLocationCoordinateBearing(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2);

// Represents NULL CLLocationCoordinate2D
extern const CLLocationCoordinate2D YKCLLocationCoordinate2DNull;
extern const CLLocationDegrees YKCLLatitudeNull;
extern const CLLocationDegrees YKCLLongitudeNull;

/*!
 Check if CLLocationCoordinate2D is NULL.
 @param coordinate
 @result YES if NULL, NO otherwise
 */
static inline BOOL YKCLLocationCoordinate2DIsNull(CLLocationCoordinate2D coordinate) {
  return coordinate.latitude == YKCLLatitudeNull && coordinate.longitude == YKCLLongitudeNull;
}

static inline BOOL YKLatitudeIsNull(CLLocationDegrees latitude) { return latitude == YKCLLatitudeNull; }
static inline BOOL YKLongitudeIsNull(CLLocationDegrees latitude) { return latitude == YKCLLongitudeNull; }

static inline BOOL YKCLLocationCoordinate2DIsEqual(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2, CLLocationDegrees accuracy) {
  return (YKIsEqualWithAccuracy(c1.latitude, c2.latitude, accuracy) && YKIsEqualWithAccuracy(c1.longitude, c1.longitude, accuracy));
}


/*!
 Create location coordinate from dictionary with "latitude", "longitude".
 @param dict Dictionary with "latitude", "longitude"
 @param Coordinate or YKCLLocationCoordinate2DNull if the dictionary was invalid
 */
CLLocationCoordinate2D YKCLLocationCoordinate2DDecode(id dict);

id YKCLLocationCoordinate2DEncode(CLLocationCoordinate2D coordinate);

/*!
 Make location coordinate.
 @param latitude
 @param longitude
 */
static inline CLLocationCoordinate2D YKCLLocationCoordinate2DMake(CLLocationDegrees latitude, CLLocationDegrees longitude) {
  if (latitude == YKCLLatitudeNull || longitude == YKCLLongitudeNull) return YKCLLocationCoordinate2DNull;
  CLLocationCoordinate2D coordinate;
  coordinate.latitude = latitude;
  coordinate.longitude = longitude;
  return coordinate;
}

BOOL YKCLLocationCoordinate2DIsValid(CLLocationCoordinate2D coordinate);

/*!
 Check if circle (center+radius) contains coordinate. (Inclusive)
 @param circle
 @param coordinate
 @result YES if coordinate is inside circle
 */
BOOL YKCenterRadiusContainsCoordinate(CLLocationCoordinate2D center, CLLocationDistance radius, CLLocationCoordinate2D coordinate);

/*!
 Returns string from location coordinate.
 */
NSString *YKNSStringFromCLLocationCoordinate2D(CLLocationCoordinate2D coordinate);

/*!
 Check if location coordinates are equal.
 */
BOOL YKCLLocationCoordinateIsEqual(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2);

/*!
 Check if location coordinates are equal within accuracy (epsilon).
 @param c1 Location 1
 @param c2 Location 2
 @param accuracy Epsilon
 @result YES if equal within +/- epsilon
 */
BOOL YKCLLocationCoordinateIsEqualWithAccuracy(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2, double accuracy);

/*!
 Calculate an endpoint given a startpoint, bearing and distance
 Vincenty 'Direct' formula based on the formula as described at http://www.movable-type.co.uk/scripts/latlong-vincenty-direct.html
 Original JavaScript implementation © 2002-2006 Chris Veness
 Obj-C code derived from http://www.thismuchiknow.co.uk/?p=120
 @param source Starting lat/lng coordinates
 @param distance Distance in meters to move
 @param bearingInRadians Bearing in radians (bearing is 0 north clockwise compass direction; 0 degrees is north, 90 degrees is east)
 @result New lat/lng coordinate
 */
CLLocationCoordinate2D YKCLLocationCoordinateMoveDistance(CLLocationCoordinate2D coordinate, CLLocationDistance distance, double bearingInRadians);

//
// NSValue encoding/decoding
//

NSValue *NSValueFromCLLocationCoordinate2D(CLLocationCoordinate2D coordinate);
CLLocationCoordinate2D CLLocationCoordinate2DFromNSValue(NSValue *value);
