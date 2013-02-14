// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SNRMixThumbnailArtwork.h instead.

#import <CoreData/CoreData.h>
#import "SNRManagedObject.h"

extern const struct SNRMixThumbnailArtworkAttributes {
	__unsafe_unretained NSString *data;
	__unsafe_unretained NSString *generated;
} SNRMixThumbnailArtworkAttributes;

extern const struct SNRMixThumbnailArtworkRelationships {
	__unsafe_unretained NSString *mix;
} SNRMixThumbnailArtworkRelationships;

extern const struct SNRMixThumbnailArtworkFetchedProperties {
} SNRMixThumbnailArtworkFetchedProperties;

@class SNRMix;




@interface SNRMixThumbnailArtworkID : NSManagedObjectID {}
@end

@interface _SNRMixThumbnailArtwork : SNRManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SNRMixThumbnailArtworkID*)objectID;





@property (nonatomic, strong) NSData* data;



//- (BOOL)validateData:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* generated;



@property BOOL generatedValue;
- (BOOL)generatedValue;
- (void)setGeneratedValue:(BOOL)value_;

//- (BOOL)validateGenerated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) SNRMix *mix;

//- (BOOL)validateMix:(id*)value_ error:(NSError**)error_;





@end

@interface _SNRMixThumbnailArtwork (CoreDataGeneratedAccessors)

@end

@interface _SNRMixThumbnailArtwork (CoreDataGeneratedPrimitiveAccessors)


- (NSData*)primitiveData;
- (void)setPrimitiveData:(NSData*)value;




- (NSNumber*)primitiveGenerated;
- (void)setPrimitiveGenerated:(NSNumber*)value;

- (BOOL)primitiveGeneratedValue;
- (void)setPrimitiveGeneratedValue:(BOOL)value_;





- (SNRMix*)primitiveMix;
- (void)setPrimitiveMix:(SNRMix*)value;


@end
