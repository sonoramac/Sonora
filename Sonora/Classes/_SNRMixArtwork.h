// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SNRMixArtwork.h instead.

#import <CoreData/CoreData.h>
#import "SNRManagedObject.h"

extern const struct SNRMixArtworkAttributes {
	__unsafe_unretained NSString *data;
	__unsafe_unretained NSString *generated;
} SNRMixArtworkAttributes;

extern const struct SNRMixArtworkRelationships {
	__unsafe_unretained NSString *mix;
} SNRMixArtworkRelationships;

extern const struct SNRMixArtworkFetchedProperties {
} SNRMixArtworkFetchedProperties;

@class SNRMix;




@interface SNRMixArtworkID : NSManagedObjectID {}
@end

@interface _SNRMixArtwork : SNRManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SNRMixArtworkID*)objectID;




@property (nonatomic, strong) NSData* data;


//- (BOOL)validateData:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* generated;


@property BOOL generatedValue;
- (BOOL)generatedValue;
- (void)setGeneratedValue:(BOOL)value_;

//- (BOOL)validateGenerated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) SNRMix* mix;

//- (BOOL)validateMix:(id*)value_ error:(NSError**)error_;





@end

@interface _SNRMixArtwork (CoreDataGeneratedAccessors)

@end

@interface _SNRMixArtwork (CoreDataGeneratedPrimitiveAccessors)


- (NSData*)primitiveData;
- (void)setPrimitiveData:(NSData*)value;




- (NSNumber*)primitiveGenerated;
- (void)setPrimitiveGenerated:(NSNumber*)value;

- (BOOL)primitiveGeneratedValue;
- (void)setPrimitiveGeneratedValue:(BOOL)value_;





- (SNRMix*)primitiveMix;
- (void)setPrimitiveMix:(SNRMix*)value;


@end
