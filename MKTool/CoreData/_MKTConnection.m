// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MKTConnection.m instead.

#import "_MKTConnection.h"

const struct MKTConnectionAttributes MKTConnectionAttributes = {
	.address = @"address",
	.connectionClass = @"connectionClass",
	.connectionData = @"connectionData",
	.index = @"index",
	.lastUsed = @"lastUsed",
	.name = @"name",
};

const struct MKTConnectionRelationships MKTConnectionRelationships = {
};

const struct MKTConnectionFetchedProperties MKTConnectionFetchedProperties = {
};

@implementation MKTConnectionID
@end

@implementation _MKTConnection

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MKTConnection" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MKTConnection";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MKTConnection" inManagedObjectContext:moc_];
}

- (MKTConnectionID*)objectID {
	return (MKTConnectionID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"indexValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"index"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic address;






@dynamic connectionClass;






@dynamic connectionData;






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





@dynamic lastUsed;






@dynamic name;











@end
