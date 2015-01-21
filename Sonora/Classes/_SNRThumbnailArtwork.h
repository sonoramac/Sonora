// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SNRThumbnailArtwork.h instead.

#import <CoreData/CoreData.h>
#import "SNRManagedObject.h"

extern const struct SNRThumbnailArtworkAttributes {
	__unsafe_unretained NSString *data;
} SNRThumbnailArtworkAttributes;

extern const struct SNRThumbnailArtworkRelationships {
	__unsafe_unretained NSString *album;
} SNRThumbnailArtworkRelationships;

@class SNRAlbum;

@interface SNRThumbnailArtworkID : NSManagedObjectID {}
@end

@interface _SNRThumbnailArtwork : SNRManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) SNRThumbnailArtworkID* objectID;

@property (nonatomic, strong) NSData* data;

//- (BOOL)validateData:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) SNRAlbum *album;

//- (BOOL)validateAlbum:(id*)value_ error:(NSError**)error_;

@end

@interface _SNRThumbnailArtwork (CoreDataGeneratedPrimitiveAccessors)

- (NSData*)primitiveData;
- (void)setPrimitiveData:(NSData*)value;

- (SNRAlbum*)primitiveAlbum;
- (void)setPrimitiveAlbum:(SNRAlbum*)value;

@end
