// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SNRArtist.h instead.

#import <CoreData/CoreData.h>
#import "SNRManagedObject.h"

extern const struct SNRArtistAttributes {
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *ranking;
	__unsafe_unretained NSString *sortingName;
} SNRArtistAttributes;

extern const struct SNRArtistRelationships {
	__unsafe_unretained NSString *albums;
} SNRArtistRelationships;

@class SNRAlbum;

@interface SNRArtistID : NSManagedObjectID {}
@end

@interface _SNRArtist : SNRManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) SNRArtistID* objectID;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* ranking;

@property (atomic) int32_t rankingValue;
- (int32_t)rankingValue;
- (void)setRankingValue:(int32_t)value_;

//- (BOOL)validateRanking:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* sortingName;

//- (BOOL)validateSortingName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *albums;

- (NSMutableSet*)albumsSet;

@end

@interface _SNRArtist (AlbumsCoreDataGeneratedAccessors)
- (void)addAlbums:(NSSet*)value_;
- (void)removeAlbums:(NSSet*)value_;
- (void)addAlbumsObject:(SNRAlbum*)value_;
- (void)removeAlbumsObject:(SNRAlbum*)value_;

@end

@interface _SNRArtist (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSNumber*)primitiveRanking;
- (void)setPrimitiveRanking:(NSNumber*)value;

- (int32_t)primitiveRankingValue;
- (void)setPrimitiveRankingValue:(int32_t)value_;

- (NSString*)primitiveSortingName;
- (void)setPrimitiveSortingName:(NSString*)value;

- (NSMutableSet*)primitiveAlbums;
- (void)setPrimitiveAlbums:(NSMutableSet*)value;

@end
