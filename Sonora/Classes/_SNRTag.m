// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SNRTag.m instead.

#import "_SNRTag.h"

const struct SNRTagAttributes SNRTagAttributes = {
	.name = @"name",
	.ranking = @"ranking",
};

const struct SNRTagRelationships SNRTagRelationships = {
	.songs = @"songs",
};

const struct SNRTagFetchedProperties SNRTagFetchedProperties = {
};

@implementation SNRTagID
@end

@implementation _SNRTag

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SNRTag" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SNRTag";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SNRTag" inManagedObjectContext:moc_];
}

- (SNRTagID*)objectID {
	return (SNRTagID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"rankingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"ranking"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic name;






@dynamic ranking;



- (int32_t)rankingValue {
	NSNumber *result = [self ranking];
	return [result intValue];
}

- (void)setRankingValue:(int32_t)value_ {
	[self setRanking:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveRankingValue {
	NSNumber *result = [self primitiveRanking];
	return [result intValue];
}

- (void)setPrimitiveRankingValue:(int32_t)value_ {
	[self setPrimitiveRanking:[NSNumber numberWithInt:value_]];
}





@dynamic songs;

	
- (NSMutableSet*)songsSet {
	[self willAccessValueForKey:@"songs"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"songs"];
  
	[self didAccessValueForKey:@"songs"];
	return result;
}
	






@end
