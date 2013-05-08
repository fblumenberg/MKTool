// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MKTConnection.h instead.

#import <CoreData/CoreData.h>


extern const struct MKTConnectionAttributes {
	__unsafe_unretained NSString *address;
	__unsafe_unretained NSString *connectionClass;
	__unsafe_unretained NSString *connectionData;
	__unsafe_unretained NSString *index;
	__unsafe_unretained NSString *lastUsed;
	__unsafe_unretained NSString *name;
} MKTConnectionAttributes;

extern const struct MKTConnectionRelationships {
} MKTConnectionRelationships;

extern const struct MKTConnectionFetchedProperties {
} MKTConnectionFetchedProperties;









@interface MKTConnectionID : NSManagedObjectID {}
@end

@interface _MKTConnection : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MKTConnectionID*)objectID;





@property (nonatomic, strong) NSString* address;



//- (BOOL)validateAddress:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* connectionClass;



//- (BOOL)validateConnectionClass:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* connectionData;



//- (BOOL)validateConnectionData:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* index;



@property int16_t indexValue;
- (int16_t)indexValue;
- (void)setIndexValue:(int16_t)value_;

//- (BOOL)validateIndex:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastUsed;



//- (BOOL)validateLastUsed:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;






@end

@interface _MKTConnection (CoreDataGeneratedAccessors)

@end

@interface _MKTConnection (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAddress;
- (void)setPrimitiveAddress:(NSString*)value;




- (NSString*)primitiveConnectionClass;
- (void)setPrimitiveConnectionClass:(NSString*)value;




- (NSString*)primitiveConnectionData;
- (void)setPrimitiveConnectionData:(NSString*)value;




- (NSNumber*)primitiveIndex;
- (void)setPrimitiveIndex:(NSNumber*)value;

- (int16_t)primitiveIndexValue;
- (void)setPrimitiveIndexValue:(int16_t)value_;




- (NSDate*)primitiveLastUsed;
- (void)setPrimitiveLastUsed:(NSDate*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




@end
