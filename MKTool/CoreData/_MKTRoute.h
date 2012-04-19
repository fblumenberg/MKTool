// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MKTRoute.h instead.

#import <CoreData/CoreData.h>


extern const struct MKTRouteAttributes {
	__unsafe_unretained NSString *fileName;
	__unsafe_unretained NSString *index;
	__unsafe_unretained NSString *lastUpdated;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *parentRev;
} MKTRouteAttributes;

extern const struct MKTRouteRelationships {
	__unsafe_unretained NSString *points;
} MKTRouteRelationships;

extern const struct MKTRouteFetchedProperties {
} MKTRouteFetchedProperties;

@class MKTPoint;







@interface MKTRouteID : NSManagedObjectID {}
@end

@interface _MKTRoute : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MKTRouteID*)objectID;




@property (nonatomic, strong) NSString *fileName;


//- (BOOL)validateFileName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber *index;


@property int16_t indexValue;
- (int16_t)indexValue;
- (void)setIndexValue:(int16_t)value_;

//- (BOOL)validateIndex:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSDate *lastUpdated;


//- (BOOL)validateLastUpdated:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *parentRev;


//- (BOOL)validateParentRev:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet* points;

- (NSMutableSet*)pointsSet;





@end

@interface _MKTRoute (CoreDataGeneratedAccessors)

- (void)addPoints:(NSSet*)value_;
- (void)removePoints:(NSSet*)value_;
- (void)addPointsObject:(MKTPoint*)value_;
- (void)removePointsObject:(MKTPoint*)value_;

@end

@interface _MKTRoute (CoreDataGeneratedPrimitiveAccessors)


- (NSString *)primitiveFileName;
- (void)setPrimitiveFileName:(NSString *)value;




- (NSNumber *)primitiveIndex;
- (void)setPrimitiveIndex:(NSNumber *)value;

- (int16_t)primitiveIndexValue;
- (void)setPrimitiveIndexValue:(int16_t)value_;




- (NSDate *)primitiveLastUpdated;
- (void)setPrimitiveLastUpdated:(NSDate *)value;




- (NSString *)primitiveName;
- (void)setPrimitiveName:(NSString *)value;




- (NSString *)primitiveParentRev;
- (void)setPrimitiveParentRev:(NSString *)value;





- (NSMutableSet*)primitivePoints;
- (void)setPrimitivePoints:(NSMutableSet*)value;


@end
