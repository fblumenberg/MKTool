// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MKTPoint.h instead.

#import <CoreData/CoreData.h>


extern const struct MKTPointAttributes {
	__unsafe_unretained NSString *altitude;
	__unsafe_unretained NSString *altitudeRate;
	__unsafe_unretained NSString *cameraAngle;
	__unsafe_unretained NSString *eventChannelValue;
	__unsafe_unretained NSString *eventFlag;
	__unsafe_unretained NSString *heading;
	__unsafe_unretained NSString *holdTime;
	__unsafe_unretained NSString *index;
	__unsafe_unretained NSString *latitude;
	__unsafe_unretained NSString *longitude;
	__unsafe_unretained NSString *prefix;
	__unsafe_unretained NSString *speed;
	__unsafe_unretained NSString *toleranceRadius;
	__unsafe_unretained NSString *type;
} MKTPointAttributes;

extern const struct MKTPointRelationships {
	__unsafe_unretained NSString *route;
} MKTPointRelationships;

extern const struct MKTPointFetchedProperties {
} MKTPointFetchedProperties;

@class MKTRoute;
















@interface MKTPointID : NSManagedObjectID {}
@end

@interface _MKTPoint : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MKTPointID*)objectID;




@property (nonatomic, strong) NSNumber *altitude;


@property int16_t altitudeValue;
- (int16_t)altitudeValue;
- (void)setAltitudeValue:(int16_t)value_;

//- (BOOL)validateAltitude:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber *altitudeRate;


@property int16_t altitudeRateValue;
- (int16_t)altitudeRateValue;
- (void)setAltitudeRateValue:(int16_t)value_;

//- (BOOL)validateAltitudeRate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber *cameraAngle;


@property int16_t cameraAngleValue;
- (int16_t)cameraAngleValue;
- (void)setCameraAngleValue:(int16_t)value_;

//- (BOOL)validateCameraAngle:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber *eventChannelValue;


@property int16_t eventChannelValueValue;
- (int16_t)eventChannelValueValue;
- (void)setEventChannelValueValue:(int16_t)value_;

//- (BOOL)validateEventChannelValue:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber *eventFlag;


@property int16_t eventFlagValue;
- (int16_t)eventFlagValue;
- (void)setEventFlagValue:(int16_t)value_;

//- (BOOL)validateEventFlag:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber *heading;


@property int16_t headingValue;
- (int16_t)headingValue;
- (void)setHeadingValue:(int16_t)value_;

//- (BOOL)validateHeading:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber *holdTime;


@property int16_t holdTimeValue;
- (int16_t)holdTimeValue;
- (void)setHoldTimeValue:(int16_t)value_;

//- (BOOL)validateHoldTime:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber *index;


@property int16_t indexValue;
- (int16_t)indexValue;
- (void)setIndexValue:(int16_t)value_;

//- (BOOL)validateIndex:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber *latitude;


@property double latitudeValue;
- (double)latitudeValue;
- (void)setLatitudeValue:(double)value_;

//- (BOOL)validateLatitude:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber *longitude;


@property double longitudeValue;
- (double)longitudeValue;
- (void)setLongitudeValue:(double)value_;

//- (BOOL)validateLongitude:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *prefix;


//- (BOOL)validatePrefix:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber *speed;


@property int16_t speedValue;
- (int16_t)speedValue;
- (void)setSpeedValue:(int16_t)value_;

//- (BOOL)validateSpeed:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber *toleranceRadius;


@property int16_t toleranceRadiusValue;
- (int16_t)toleranceRadiusValue;
- (void)setToleranceRadiusValue:(int16_t)value_;

//- (BOOL)validateToleranceRadius:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber *type;


@property int16_t typeValue;
- (int16_t)typeValue;
- (void)setTypeValue:(int16_t)value_;

//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) MKTRoute* route;

//- (BOOL)validateRoute:(id*)value_ error:(NSError**)error_;





@end

@interface _MKTPoint (CoreDataGeneratedAccessors)

@end

@interface _MKTPoint (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber *)primitiveAltitude;
- (void)setPrimitiveAltitude:(NSNumber *)value;

- (int16_t)primitiveAltitudeValue;
- (void)setPrimitiveAltitudeValue:(int16_t)value_;




- (NSNumber *)primitiveAltitudeRate;
- (void)setPrimitiveAltitudeRate:(NSNumber *)value;

- (int16_t)primitiveAltitudeRateValue;
- (void)setPrimitiveAltitudeRateValue:(int16_t)value_;




- (NSNumber *)primitiveCameraAngle;
- (void)setPrimitiveCameraAngle:(NSNumber *)value;

- (int16_t)primitiveCameraAngleValue;
- (void)setPrimitiveCameraAngleValue:(int16_t)value_;




- (NSNumber *)primitiveEventChannelValue;
- (void)setPrimitiveEventChannelValue:(NSNumber *)value;

- (int16_t)primitiveEventChannelValueValue;
- (void)setPrimitiveEventChannelValueValue:(int16_t)value_;




- (NSNumber *)primitiveEventFlag;
- (void)setPrimitiveEventFlag:(NSNumber *)value;

- (int16_t)primitiveEventFlagValue;
- (void)setPrimitiveEventFlagValue:(int16_t)value_;




- (NSNumber *)primitiveHeading;
- (void)setPrimitiveHeading:(NSNumber *)value;

- (int16_t)primitiveHeadingValue;
- (void)setPrimitiveHeadingValue:(int16_t)value_;




- (NSNumber *)primitiveHoldTime;
- (void)setPrimitiveHoldTime:(NSNumber *)value;

- (int16_t)primitiveHoldTimeValue;
- (void)setPrimitiveHoldTimeValue:(int16_t)value_;




- (NSNumber *)primitiveIndex;
- (void)setPrimitiveIndex:(NSNumber *)value;

- (int16_t)primitiveIndexValue;
- (void)setPrimitiveIndexValue:(int16_t)value_;




- (NSNumber *)primitiveLatitude;
- (void)setPrimitiveLatitude:(NSNumber *)value;

- (double)primitiveLatitudeValue;
- (void)setPrimitiveLatitudeValue:(double)value_;




- (NSNumber *)primitiveLongitude;
- (void)setPrimitiveLongitude:(NSNumber *)value;

- (double)primitiveLongitudeValue;
- (void)setPrimitiveLongitudeValue:(double)value_;




- (NSString *)primitivePrefix;
- (void)setPrimitivePrefix:(NSString *)value;




- (NSNumber *)primitiveSpeed;
- (void)setPrimitiveSpeed:(NSNumber *)value;

- (int16_t)primitiveSpeedValue;
- (void)setPrimitiveSpeedValue:(int16_t)value_;




- (NSNumber *)primitiveToleranceRadius;
- (void)setPrimitiveToleranceRadius:(NSNumber *)value;

- (int16_t)primitiveToleranceRadiusValue;
- (void)setPrimitiveToleranceRadiusValue:(int16_t)value_;




- (NSNumber *)primitiveType;
- (void)setPrimitiveType:(NSNumber *)value;

- (int16_t)primitiveTypeValue;
- (void)setPrimitiveTypeValue:(int16_t)value_;





- (MKTRoute*)primitiveRoute;
- (void)setPrimitiveRoute:(MKTRoute*)value;


@end
