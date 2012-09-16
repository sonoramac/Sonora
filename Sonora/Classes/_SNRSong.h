// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SNRSong.h instead.

#import <CoreData/CoreData.h>
#import "SNRManagedObject.h"

extern const struct SNRSongAttributes {
	__unsafe_unretained NSString *bookmark;
	__unsafe_unretained NSString *compilation;
	__unsafe_unretained NSString *composer;
	__unsafe_unretained NSString *dateAdded;
	__unsafe_unretained NSString *discNumber;
	__unsafe_unretained NSString *discTotal;
	__unsafe_unretained NSString *duration;
	__unsafe_unretained NSString *iTunesPersistentID;
	__unsafe_unretained NSString *lyrics;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *popularity;
	__unsafe_unretained NSString *ranking;
	__unsafe_unretained NSString *rawAlbumArtist;
	__unsafe_unretained NSString *rawArtist;
	__unsafe_unretained NSString *trackNumber;
	__unsafe_unretained NSString *trackTotal;
	__unsafe_unretained NSString *year;
} SNRSongAttributes;

extern const struct SNRSongRelationships {
	__unsafe_unretained NSString *album;
	__unsafe_unretained NSString *mixes;
	__unsafe_unretained NSString *playCounts;
	__unsafe_unretained NSString *tags;
} SNRSongRelationships;

extern const struct SNRSongFetchedProperties {
} SNRSongFetchedProperties;

@class SNRAlbum;
@class SNRMix;
@class SNRPlayCount;
@class SNRTag;



















@interface SNRSongID : NSManagedObjectID {}
@end

@interface _SNRSong : SNRManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SNRSongID*)objectID;




@property (nonatomic, strong) NSData* bookmark;


//- (BOOL)validateBookmark:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* compilation;


@property BOOL compilationValue;
- (BOOL)compilationValue;
- (void)setCompilationValue:(BOOL)value_;

//- (BOOL)validateCompilation:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* composer;


//- (BOOL)validateComposer:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSDate* dateAdded;


//- (BOOL)validateDateAdded:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* discNumber;


@property int32_t discNumberValue;
- (int32_t)discNumberValue;
- (void)setDiscNumberValue:(int32_t)value_;

//- (BOOL)validateDiscNumber:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* discTotal;


@property int32_t discTotalValue;
- (int32_t)discTotalValue;
- (void)setDiscTotalValue:(int32_t)value_;

//- (BOOL)validateDiscTotal:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* duration;


@property int32_t durationValue;
- (int32_t)durationValue;
- (void)setDurationValue:(int32_t)value_;

//- (BOOL)validateDuration:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* iTunesPersistentID;


//- (BOOL)validateITunesPersistentID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* lyrics;


//- (BOOL)validateLyrics:(id*)value_ error:(NSError**)error_;




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




@property (nonatomic, strong) NSString* rawAlbumArtist;


//- (BOOL)validateRawAlbumArtist:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* rawArtist;


//- (BOOL)validateRawArtist:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* trackNumber;


@property int32_t trackNumberValue;
- (int32_t)trackNumberValue;
- (void)setTrackNumberValue:(int32_t)value_;

//- (BOOL)validateTrackNumber:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* trackTotal;


@property int32_t trackTotalValue;
- (int32_t)trackTotalValue;
- (void)setTrackTotalValue:(int32_t)value_;

//- (BOOL)validateTrackTotal:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* year;


@property int32_t yearValue;
- (int32_t)yearValue;
- (void)setYearValue:(int32_t)value_;

//- (BOOL)validateYear:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) SNRAlbum* album;

//- (BOOL)validateAlbum:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet* mixes;

- (NSMutableSet*)mixesSet;




@property (nonatomic, strong) NSSet* playCounts;

- (NSMutableSet*)playCountsSet;




@property (nonatomic, strong) NSSet* tags;

- (NSMutableSet*)tagsSet;





@end

@interface _SNRSong (CoreDataGeneratedAccessors)

- (void)addMixes:(NSSet*)value_;
- (void)removeMixes:(NSSet*)value_;
- (void)addMixesObject:(SNRMix*)value_;
- (void)removeMixesObject:(SNRMix*)value_;

- (void)addPlayCounts:(NSSet*)value_;
- (void)removePlayCounts:(NSSet*)value_;
- (void)addPlayCountsObject:(SNRPlayCount*)value_;
- (void)removePlayCountsObject:(SNRPlayCount*)value_;

- (void)addTags:(NSSet*)value_;
- (void)removeTags:(NSSet*)value_;
- (void)addTagsObject:(SNRTag*)value_;
- (void)removeTagsObject:(SNRTag*)value_;

@end

@interface _SNRSong (CoreDataGeneratedPrimitiveAccessors)


- (NSData*)primitiveBookmark;
- (void)setPrimitiveBookmark:(NSData*)value;




- (NSNumber*)primitiveCompilation;
- (void)setPrimitiveCompilation:(NSNumber*)value;

- (BOOL)primitiveCompilationValue;
- (void)setPrimitiveCompilationValue:(BOOL)value_;




- (NSString*)primitiveComposer;
- (void)setPrimitiveComposer:(NSString*)value;




- (NSDate*)primitiveDateAdded;
- (void)setPrimitiveDateAdded:(NSDate*)value;




- (NSNumber*)primitiveDiscNumber;
- (void)setPrimitiveDiscNumber:(NSNumber*)value;

- (int32_t)primitiveDiscNumberValue;
- (void)setPrimitiveDiscNumberValue:(int32_t)value_;




- (NSNumber*)primitiveDiscTotal;
- (void)setPrimitiveDiscTotal:(NSNumber*)value;

- (int32_t)primitiveDiscTotalValue;
- (void)setPrimitiveDiscTotalValue:(int32_t)value_;




- (NSNumber*)primitiveDuration;
- (void)setPrimitiveDuration:(NSNumber*)value;

- (int32_t)primitiveDurationValue;
- (void)setPrimitiveDurationValue:(int32_t)value_;




- (NSString*)primitiveITunesPersistentID;
- (void)setPrimitiveITunesPersistentID:(NSString*)value;




- (NSString*)primitiveLyrics;
- (void)setPrimitiveLyrics:(NSString*)value;




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




- (NSString*)primitiveRawAlbumArtist;
- (void)setPrimitiveRawAlbumArtist:(NSString*)value;




- (NSString*)primitiveRawArtist;
- (void)setPrimitiveRawArtist:(NSString*)value;




- (NSNumber*)primitiveTrackNumber;
- (void)setPrimitiveTrackNumber:(NSNumber*)value;

- (int32_t)primitiveTrackNumberValue;
- (void)setPrimitiveTrackNumberValue:(int32_t)value_;




- (NSNumber*)primitiveTrackTotal;
- (void)setPrimitiveTrackTotal:(NSNumber*)value;

- (int32_t)primitiveTrackTotalValue;
- (void)setPrimitiveTrackTotalValue:(int32_t)value_;




- (NSNumber*)primitiveYear;
- (void)setPrimitiveYear:(NSNumber*)value;

- (int32_t)primitiveYearValue;
- (void)setPrimitiveYearValue:(int32_t)value_;





- (SNRAlbum*)primitiveAlbum;
- (void)setPrimitiveAlbum:(SNRAlbum*)value;



- (NSMutableSet*)primitiveMixes;
- (void)setPrimitiveMixes:(NSMutableSet*)value;



- (NSMutableSet*)primitivePlayCounts;
- (void)setPrimitivePlayCounts:(NSMutableSet*)value;



- (NSMutableSet*)primitiveTags;
- (void)setPrimitiveTags:(NSMutableSet*)value;


@end
