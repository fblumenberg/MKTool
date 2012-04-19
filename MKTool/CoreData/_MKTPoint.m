// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MKTPoint.m instead.

#import "_MKTPoint.h"

const struct MKTPointAttributes MKTPointAttributes = {
	.altitude = @"altitude",
	.altitudeRate = @"altitudeRate",
	.cameraAngle = @"cameraAngle",
	.eventChannelValue = @"eventChannelValue",
	.eventFlag = @"eventFlag",
	.heading = @"heading",
	.holdTime = @"holdTime",
	.index = @"index",
	.latitude = @"latitude",
	.longitude = @"longitude",
	.prefix = @"prefix",
	.speed = @"speed",
	.toleranceRadius = @"toleranceRadius",
	.type = @"type",
};

const struct MKTPointRelationships MKTPointRelationships = {
	.route = @"route",
};

const struct MKTPointFetchedProperties MKTPointFetchedProperties = {
};

@implementation MKTPointID
@end

@implementation _MKTPoint

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MKTPoint" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MKTPoint";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MKTPoint" inManagedObjectContext:moc_];
}

- (MKTPointID*)objectID {
	return (MKTPointID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"altitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"altitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"altitudeRateValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"altitudeRate"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"cameraAngleValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"cameraAngle"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"eventChannelValueValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"eventChannelValue"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"eventFlagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"eventFlag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"headingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"heading"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"holdTimeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"holdTime"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"indexValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"index"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"latitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"latitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"longitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"longitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"speedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"speed"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"toleranceRadiusValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"toleranceRadius"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"typeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"type"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic altitude;



- (int16_t)altitudeValue {
	NSNumber *result = [self altitude];
	return [result shortValue];
}

- (void)setAltitudeValue:(int16_t)value_ {
	[self setAltitude:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveAltitudeValue {
	NSNumber *result = [self primitiveAltitude];
	return [result shortValue];
}

- (void)setPrimitiveAltitudeValue:(int16_t)value_ {
	[self setPrimitiveAltitude:[NSNumber numberWithShort:value_]];
}





@dynamic altitudeRate;



- (int16_t)altitudeRateValue {
	NSNumber *result = [self altitudeRate];
	return [result shortValue];
}

- (void)setAltitudeRateValue:(int16_t)value_ {
	[self setAltitudeRate:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveAltitudeRateValue {
	NSNumber *result = [self primitiveAltitudeRate];
	return [result shortValue];
}

- (void)setPrimitiveAltitudeRateValue:(int16_t)value_ {
	[self setPrimitiveAltitudeRate:[NSNumber numberWithShort:value_]];
}





@dynamic cameraAngle;



- (int16_t)cameraAngleValue {
	NSNumber *result = [self cameraAngle];
	return [result shortValue];
}

- (void)setCameraAngleValue:(int16_t)value_ {
	[self setCameraAngle:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveCameraAngleValue {
	NSNumber *result = [self primitiveCameraAngle];
	return [result shortValue];
}

- (void)setPrimitiveCameraAngleValue:(int16_t)value_ {
	[self setPrimitiveCameraAngle:[NSNumber numberWithShort:value_]];
}





@dynamic eventChannelValue;



- (int16_t)eventChannelValueValue {
	NSNumber *result = [self eventChannelValue];
	return [result shortValue];
}

- (void)setEventChannelValueValue:(int16_t)value_ {
	[self setEventChannelValue:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveEventChannelValueValue {
	NSNumber *result = [self primitiveEventChannelValue];
	return [result shortValue];
}

- (void)setPrimitiveEventChannelValueValue:(int16_t)value_ {
	[self setPrimitiveEventChannelValue:[NSNumber numberWithShort:value_]];
}





@dynamic eventFlag;



- (int16_t)eventFlagValue {
	NSNumber *result = [self eventFlag];
	return [result shortValue];
}

- (void)setEventFlagValue:(int16_t)value_ {
	[self setEventFlag:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveEventFlagValue {
	NSNumber *result = [self primitiveEventFlag];
	return [result shortValue];
}

- (void)setPrimitiveEventFlagValue:(int16_t)value_ {
	[self setPrimitiveEventFlag:[NSNumber numberWithShort:value_]];
}





@dynamic heading;



- (int16_t)headingValue {
	NSNumber *result = [self heading];
	return [result shortValue];
}

- (void)setHeadingValue:(int16_t)value_ {
	[self setHeading:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveHeadingValue {
	NSNumber *result = [self primitiveHeading];
	return [result shortValue];
}

- (void)setPrimitiveHeadingValue:(int16_t)value_ {
	[self setPrimitiveHeading:[NSNumber numberWithShort:value_]];
}





@dynamic holdTime;



- (int16_t)holdTimeValue {
	NSNumber *result = [self holdTime];
	return [result shortValue];
}

- (void)setHoldTimeValue:(int16_t)value_ {
	[self setHoldTime:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveHoldTimeValue {
	NSNumber *result = [self primitiveHoldTime];
	return [result shortValue];
}

- (void)setPrimitiveHoldTimeValue:(int16_t)value_ {
	[self setPrimitiveHoldTime:[NSNumber numberWithShort:value_]];
}





@dynamic index;



- (int16_t)indexValue {
	NSNumber *result = [self index];
	return [result shortValue];
}

- (void)setIndexValue:(int16_t)value_ {
	[self setIndex:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveIndexValue {
	NSNumber *result = [self primitiveIndex];
	return [result shortValue];
}

- (void)setPrimitiveIndexValue:(int16_t)value_ {
	[self setPrimitiveIndex:[NSNumber numberWithShort:value_]];
}





@dynamic latitude;



- (double)latitudeValue {
	NSNumber *result = [self latitude];
	return [result doubleValue];
}

- (void)setLatitudeValue:(double)value_ {
	[self setLatitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLatitudeValue {
	NSNumber *result = [self primitiveLatitude];
	return [result doubleValue];
}

- (void)setPrimitiveLatitudeValue:(double)value_ {
	[self setPrimitiveLatitude:[NSNumber numberWithDouble:value_]];
}





@dynamic longitude;



- (double)longitudeValue {
	NSNumber *result = [self longitude];
	return [result doubleValue];
}

- (void)setLongitudeValue:(double)value_ {
	[self setLongitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLongitudeValue {
	NSNumber *result = [self primitiveLongitude];
	return [result doubleValue];
}

- (void)setPrimitiveLongitudeValue:(double)value_ {
	[self setPrimitiveLongitude:[NSNumber numberWithDouble:value_]];
}





@dynamic prefix;






@dynamic speed;



- (int16_t)speedValue {
	NSNumber *result = [self speed];
	return [result shortValue];
}

- (void)setSpeedValue:(int16_t)value_ {
	[self setSpeed:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveSpeedValue {
	NSNumber *result = [self primitiveSpeed];
	return [result shortValue];
}

- (void)setPrimitiveSpeedValue:(int16_t)value_ {
	[self setPrimitiveSpeed:[NSNumber numberWithShort:value_]];
}





@dynamic toleranceRadius;



- (int16_t)toleranceRadiusValue {
	NSNumber *result = [self toleranceRadius];
	return [result shortValue];
}

- (void)setToleranceRadiusValue:(int16_t)value_ {
	[self setToleranceRadius:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveToleranceRadiusValue {
	NSNumber *result = [self primitiveToleranceRadius];
	return [result shortValue];
}

- (void)setPrimitiveToleranceRadiusValue:(int16_t)value_ {
	[self setPrimitiveToleranceRadius:[NSNumber numberWithShort:value_]];
}





@dynamic type;



- (int16_t)typeValue {
	NSNumber *result = [self type];
	return [result shortValue];
}

- (void)setTypeValue:(int16_t)value_ {
	[self setType:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveTypeValue {
	NSNumber *result = [self primitiveType];
	return [result shortValue];
}

- (void)setPrimitiveTypeValue:(int16_t)value_ {
	[self setPrimitiveType:[NSNumber numberWithShort:value_]];
}





@dynamic route;

	






@end
