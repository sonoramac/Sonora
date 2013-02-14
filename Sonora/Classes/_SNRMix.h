// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SNRMix.h instead.

#import <CoreData/CoreData.h>
#import "SNRManagedObject.h"

extern const struct SNRMixAttributes {
	__unsafe_unretained NSString *dateModified;
	__unsafe_unretained NSString *iTunesPersistentID;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *popularity;
	__unsafe_unretained NSString *ranking;
} SNRMixAttributes;

extern const struct SNRMixRelationships {
	__unsafe_unretained NSString *artwork;
	__unsafe_unretained NSString *songs;
	__unsafe_unretained NSString *thumbnailArtwork;
} SNRMixRelationships;

extern const struct SNRMixFetchedProperties {
} SNRMixFetchedProperties;

@class SNRMixArtwork;
@class SNRSong;
@class SNRMixThumbnailArtwork;







@interface SNRMixID : NSManagedObjectID {}
@end

@interface _SNRMix : SNRManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SNRMixID*)objectID;





@property (nonatomic, strong) NSDate* dateModified;



//- (BOOL)validateDateModified:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* iTunesPersistentID;



//- (BOOL)validateITunesPersistentID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* popularity;



@property double popularityValue;
- (double)popularityValue;
- (void)setPopularityValue:(double)value_;

//- (BOOL)validatePopularity:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* ranking;



@property int32_t rankingValue;
- (int32_t)rankingValue;
- (void)setRankingValue:(int32_t)value_;

//- (BOOL)validateRanking:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) SNRMixArtwork *artwork;

//- (BOOL)validateArtwork:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSOrderedSet *songs;

- (NSMutableOrderedSet*)songsSet;




@property (nonatomic, strong) SNRMixThumbnailArtwork *thumbnailArtwork;

//- (BOOL)validateThumbnailArtwork:(id*)value_ error:(NSError**)error_;





@end

@interface _SNRMix (CoreDataGeneratedAccessors)

- (void)addSongs:(NSOrderedSet*)value_;
- (void)removeSongs:(NSOrderedSet*)value_;
- (void)addSongsObject:(SNRSong*)value_;
- (void)removeSongsObject:(SNRSong*)value_;

@end

@interface _SNRMix (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveDateModified;
- (void)setPrimitiveDateModified:(NSDate*)value;




- (NSString*)primitiveITunesPersistentID;
- (void)setPrimitiveITunesPersistentID:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitivePopularity;
- (void)setPrimitivePopularity:(NSNumber*)value;

- (double)primitivePopularityValue;
- (void)setPrimitivePopularityValue:(double)value_;




- (NSNumber*)primitiveRanking;
- (void)setPrimitiveRanking:(NSNumber*)value;

- (int32_t)primitiveRankingValue;
- (void)setPrimitiveRankingValue:(int32_t)value_;





- (SNRMixArtwork*)primitiveArtwork;
- (void)setPrimitiveArtwork:(SNRMixArtwork*)value;



- (NSMutableOrderedSet*)primitiveSongs;
- (void)setPrimitiveSongs:(NSMutableOrderedSet*)value;



- (SNRMixThumbnailArtwork*)primitiveThumbnailArtwork;
- (void)setPrimitiveThumbnailArtwork:(SNRMixThumbnailArtwork*)value;


@end
