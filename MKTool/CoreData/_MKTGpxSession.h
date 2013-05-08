// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MKTGpxSession.h instead.

#import <CoreData/CoreData.h>


extern const struct MKTGpxSessionAttributes {
	__unsafe_unretained NSString *descr;
	__unsafe_unretained NSString *endTime;
	__unsafe_unretained NSString *regionData;
	__unsafe_unretained NSString *startTime;
} MKTGpxSessionAttributes;

extern const struct MKTGpxSessionRelationships {
	__unsafe_unretained NSString *records;
} MKTGpxSessionRelationships;

extern const struct MKTGpxSessionFetchedProperties {
} MKTGpxSessionFetchedProperties;

@class MKTGpxRecord;



@class NSObject;


@interface MKTGpxSessionID : NSManagedObjectID {}
@end

@interface _MKTGpxSession : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MKTGpxSessionID*)objectID;





@property (nonatomic, strong) NSString* descr;



//- (BOOL)validateDescr:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* endTime;



//- (BOOL)validateEndTime:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) id regionData;



//- (BOOL)validateRegionData:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* startTime;



//- (BOOL)validateStartTime:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *records;

- (NSMutableSet*)recordsSet;





@end

@interface _MKTGpxSession (CoreDataGeneratedAccessors)

- (void)addRecords:(NSSet*)value_;
- (void)removeRecords:(NSSet*)value_;
- (void)addRecordsObject:(MKTGpxRecord*)value_;
- (void)removeRecordsObject:(MKTGpxRecord*)value_;

@end

@interface _MKTGpxSession (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveDescr;
- (void)setPrimitiveDescr:(NSString*)value;




- (NSDate*)primitiveEndTime;
- (void)setPrimitiveEndTime:(NSDate*)value;




- (id)primitiveRegionData;
- (void)setPrimitiveRegionData:(id)value;




- (NSDate*)primitiveStartTime;
- (void)setPrimitiveStartTime:(NSDate*)value;





- (NSMutableSet*)primitiveRecords;
- (void)setPrimitiveRecords:(NSMutableSet*)value;


@end
