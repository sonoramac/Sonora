// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SNRPlayCount.h instead.

#import <CoreData/CoreData.h>
#import "SNRManagedObject.h"

extern const struct SNRPlayCountAttributes {
	__unsafe_unretained NSString *date;
} SNRPlayCountAttributes;

extern const struct SNRPlayCountRelationships {
	__unsafe_unretained NSString *song;
} SNRPlayCountRelationships;

extern const struct SNRPlayCountFetchedProperties {
} SNRPlayCountFetchedProperties;

@class SNRSong;



@interface SNRPlayCountID : NSManagedObjectID {}
@end

@interface _SNRPlayCount : SNRManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SNRPlayCountID*)objectID;





@property (nonatomic, strong) NSDate* date;



//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) SNRSong *song;

//- (BOOL)validateSong:(id*)value_ error:(NSError**)error_;





@end

@interface _SNRPlayCount (CoreDataGeneratedAccessors)

@end

@interface _SNRPlayCount (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;





- (SNRSong*)primitiveSong;
- (void)setPrimitiveSong:(SNRSong*)value;


@end
