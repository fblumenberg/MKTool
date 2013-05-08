// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MKTGpxRecord.h instead.

#import <CoreData/CoreData.h>


extern const struct MKTGpxRecordAttributes {
	__unsafe_unretained NSString *extensions;
	__unsafe_unretained NSString *gpsPos;
	__unsafe_unretained NSString *satellites;
	__unsafe_unretained NSString *timestamp;
} MKTGpxRecordAttributes;

extern const struct MKTGpxRecordRelationships {
	__unsafe_unretained NSString *session;
} MKTGpxRecordRelationships;

extern const struct MKTGpxRecordFetchedProperties {
} MKTGpxRecordFetchedProperties;

@class MKTGpxSession;

@class NSObject;
@class NSObject;



@interface MKTGpxRecordID : NSManagedObjectID {}
@end

@interface _MKTGpxRecord : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MKTGpxRecordID*)objectID;





@property (nonatomic, strong) id extensions;



//- (BOOL)validateExtensions:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) id gpsPos;



//- (BOOL)validateGpsPos:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* satellites;



@property int16_t satellitesValue;
- (int16_t)satellitesValue;
- (void)setSatellitesValue:(int16_t)value_;

//- (BOOL)validateSatellites:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* timestamp;



//- (BOOL)validateTimestamp:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) MKTGpxSession *session;

//- (BOOL)validateSession:(id*)value_ error:(NSError**)error_;





@end

@interface _MKTGpxRecord (CoreDataGeneratedAccessors)

@end

@interface _MKTGpxRecord (CoreDataGeneratedPrimitiveAccessors)


- (id)primitiveExtensions;
- (void)setPrimitiveExtensions:(id)value;




- (id)primitiveGpsPos;
- (void)setPrimitiveGpsPos:(id)value;




- (NSNumber*)primitiveSatellites;
- (void)setPrimitiveSatellites:(NSNumber*)value;

- (int16_t)primitiveSatellitesValue;
- (void)setPrimitiveSatellitesValue:(int16_t)value_;




- (NSDate*)primitiveTimestamp;
- (void)setPrimitiveTimestamp:(NSDate*)value;





- (MKTGpxSession*)primitiveSession;
- (void)setPrimitiveSession:(MKTGpxSession*)value;


@end
