// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SNRTag.h instead.

#import <CoreData/CoreData.h>
#import "SNRManagedObject.h"

extern const struct SNRTagAttributes {
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *ranking;
} SNRTagAttributes;

extern const struct SNRTagRelationships {
	__unsafe_unretained NSString *songs;
} SNRTagRelationships;

extern const struct SNRTagFetchedProperties {
} SNRTagFetchedProperties;

@class SNRSong;




@interface SNRTagID : NSManagedObjectID {}
@end

@interface _SNRTag : SNRManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SNRTagID*)objectID;




@property (nonatomic, strong) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* ranking;


@property int32_t rankingValue;
- (int32_t)rankingValue;
- (void)setRankingValue:(int32_t)value_;

//- (BOOL)validateRanking:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet* songs;

- (NSMutableSet*)songsSet;





@end

@interface _SNRTag (CoreDataGeneratedAccessors)

- (void)addSongs:(NSSet*)value_;
- (void)removeSongs:(NSSet*)value_;
- (void)addSongsObject:(SNRSong*)value_;
- (void)removeSongsObject:(SNRSong*)value_;

@end

@interface _SNRTag (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveRanking;
- (void)setPrimitiveRanking:(NSNumber*)value;

- (int32_t)primitiveRankingValue;
- (void)setPrimitiveRankingValue:(int32_t)value_;





- (NSMutableSet*)primitiveSongs;
- (void)setPrimitiveSongs:(NSMutableSet*)value;


@end
