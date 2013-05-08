// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MKTGpxSession.m instead.

#import "_MKTGpxSession.h"

const struct MKTGpxSessionAttributes MKTGpxSessionAttributes = {
	.descr = @"descr",
	.endTime = @"endTime",
	.regionData = @"regionData",
	.startTime = @"startTime",
};

const struct MKTGpxSessionRelationships MKTGpxSessionRelationships = {
	.records = @"records",
};

const struct MKTGpxSessionFetchedProperties MKTGpxSessionFetchedProperties = {
};

@implementation MKTGpxSessionID
@end

@implementation _MKTGpxSession

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MKTGpxSession" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MKTGpxSession";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MKTGpxSession" inManagedObjectContext:moc_];
}

- (MKTGpxSessionID*)objectID {
	return (MKTGpxSessionID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic descr;






@dynamic endTime;






@dynamic regionData;






@dynamic startTime;






@dynamic records;

	
- (NSMutableSet*)recordsSet {
	[self willAccessValueForKey:@"records"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"records"];
  
	[self didAccessValueForKey:@"records"];
	return result;
}
	






@end
