// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SNRArtwork.h instead.

#import <CoreData/CoreData.h>
#import "SNRManagedObject.h"

extern const struct SNRArtworkAttributes {
	__unsafe_unretained NSString *uuid;
} SNRArtworkAttributes;

extern const struct SNRArtworkRelationships {
	__unsafe_unretained NSString *album;
} SNRArtworkRelationships;

extern const struct SNRArtworkFetchedProperties {
} SNRArtworkFetchedProperties;

@class SNRAlbum;



@interface SNRArtworkID : NSManagedObjectID {}
@end

@interface _SNRArtwork : SNRManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SNRArtworkID*)objectID;





@property (nonatomic, strong) NSData* uuid;



//- (BOOL)validateUuid:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) SNRAlbum *album;

//- (BOOL)validateAlbum:(id*)value_ error:(NSError**)error_;





@end

@interface _SNRArtwork (CoreDataGeneratedAccessors)

@end

@interface _SNRArtwork (CoreDataGeneratedPrimitiveAccessors)


- (NSData*)primitiveUuid;
- (void)setPrimitiveUuid:(NSData*)value;





- (SNRAlbum*)primitiveAlbum;
- (void)setPrimitiveAlbum:(SNRAlbum*)value;


@end
