// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MKTGpxRecord.m instead.

#import "_MKTGpxRecord.h"

const struct MKTGpxRecordAttributes MKTGpxRecordAttributes = {
	.extensions = @"extensions",
	.gpsPos = @"gpsPos",
	.satellites = @"satellites",
	.timestamp = @"timestamp",
};

const struct MKTGpxRecordRelationships MKTGpxRecordRelationships = {
	.session = @"session",
};

const struct MKTGpxRecordFetchedProperties MKTGpxRecordFetchedProperties = {
};

@implementation MKTGpxRecordID
@end

@implementation _MKTGpxRecord

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MKTGpxRecord" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MKTGpxRecord";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MKTGpxRecord" inManagedObjectContext:moc_];
}

- (MKTGpxRecordID*)objectID {
	return (MKTGpxRecordID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"satellitesValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"satellites"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic extensions;






@dynamic gpsPos;






@dynamic satellites;



- (int16_t)satellitesValue {
	NSNumber *result = [self satellites];
	return [result shortValue];
}

- (void)setSatellitesValue:(int16_t)value_ {
	[self setSatellites:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveSatellitesValue {
	NSNumber *result = [self primitiveSatellites];
	return [result shortValue];
}

- (void)setPrimitiveSatellitesValue:(int16_t)value_ {
	[self setPrimitiveSatellites:[NSNumber numberWithShort:value_]];
}





@dynamic timestamp;






@dynamic session;

	






@end
