// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MKTRoute.m instead.

#import "_MKTRoute.h"

const struct MKTRouteAttributes MKTRouteAttributes = {
	.fileName = @"fileName",
	.index = @"index",
	.lastUpdated = @"lastUpdated",
	.name = @"name",
	.parentRev = @"parentRev",
	.thumbnail = @"thumbnail",
};

const struct MKTRouteRelationships MKTRouteRelationships = {
	.points = @"points",
};

const struct MKTRouteFetchedProperties MKTRouteFetchedProperties = {
};

@implementation MKTRouteID
@end

@implementation _MKTRoute

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MKTRoute" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MKTRoute";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MKTRoute" inManagedObjectContext:moc_];
}

- (MKTRouteID*)objectID {
	return (MKTRouteID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"indexValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"index"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic fileName;






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





@dynamic lastUpdated;






@dynamic name;






@dynamic parentRev;






@dynamic thumbnail;






@dynamic points;

	
- (NSMutableSet*)pointsSet {
	[self willAccessValueForKey:@"points"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"points"];
  
	[self didAccessValueForKey:@"points"];
	return result;
}
	






@end
