// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SNRAlbum.h instead.

#import <CoreData/CoreData.h>
#import "SNRManagedObject.h"

extern const struct SNRAlbumAttributes {
	__unsafe_unretained NSString *dateModified;
	__unsafe_unretained NSString *didSearchForArtwork;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *popularity;
	__unsafe_unretained NSString *ranking;
} SNRAlbumAttributes;

extern const struct SNRAlbumRelationships {
	__unsafe_unretained NSString *artist;
	__unsafe_unretained NSString *artwork;
	__unsafe_unretained NSString *songs;
	__unsafe_unretained NSString *thumbnailArtwork;
} SNRAlbumRelationships;

extern const struct SNRAlbumFetchedProperties {
} SNRAlbumFetchedProperties;

@class SNRArtist;
@class SNRArtwork;
@class SNRSong;
@class SNRThumbnailArtwork;







@interface SNRAlbumID : NSManagedObjectID {}
@end

@interface _SNRAlbum : SNRManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SNRAlbumID*)objectID;





@property (nonatomic, strong) NSDate* dateModified;



//- (BOOL)validateDateModified:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* didSearchForArtwork;



@property BOOL didSearchForArtworkValue;
- (BOOL)didSearchForArtworkValue;
- (void)setDidSearchForArtworkValue:(BOOL)value_;

//- (BOOL)validateDidSearchForArtwork:(id*)value_ error:(NSError**)error_;





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





@property (nonatomic, strong) SNRArtist *artist;

//- (BOOL)validateArtist:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) SNRArtwork *artwork;

//- (BOOL)validateArtwork:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *songs;

- (NSMutableSet*)songsSet;




@property (nonatomic, strong) SNRThumbnailArtwork *thumbnailArtwork;

//- (BOOL)validateThumbnailArtwork:(id*)value_ error:(NSError**)error_;





@end

@interface _SNRAlbum (CoreDataGeneratedAccessors)

- (void)addSongs:(NSSet*)value_;
- (void)removeSongs:(NSSet*)value_;
- (void)addSongsObject:(SNRSong*)value_;
- (void)removeSongsObject:(SNRSong*)value_;

@end

@interface _SNRAlbum (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveDateModified;
- (void)setPrimitiveDateModified:(NSDate*)value;




- (NSNumber*)primitiveDidSearchForArtwork;
- (void)setPrimitiveDidSearchForArtwork:(NSNumber*)value;

- (BOOL)primitiveDidSearchForArtworkValue;
- (void)setPrimitiveDidSearchForArtworkValue:(BOOL)value_;




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





- (SNRArtist*)primitiveArtist;
- (void)setPrimitiveArtist:(SNRArtist*)value;



- (SNRArtwork*)primitiveArtwork;
- (void)setPrimitiveArtwork:(SNRArtwork*)value;



- (NSMutableSet*)primitiveSongs;
- (void)setPrimitiveSongs:(NSMutableSet*)value;



- (SNRThumbnailArtwork*)primitiveThumbnailArtwork;
- (void)setPrimitiveThumbnailArtwork:(SNRThumbnailArtwork*)value;


@end
