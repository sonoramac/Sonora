// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SNRMix.m instead.

#import "_SNRMix.h"

const struct SNRMixAttributes SNRMixAttributes = {
	.dateModified = @"dateModified",
	.iTunesPersistentID = @"iTunesPersistentID",
	.name = @"name",
	.popularity = @"popularity",
	.ranking = @"ranking",
};

const struct SNRMixRelationships SNRMixRelationships = {
	.artwork = @"artwork",
	.songs = @"songs",
	.thumbnailArtwork = @"thumbnailArtwork",
};

const struct SNRMixFetchedProperties SNRMixFetchedProperties = {
};

@implementation SNRMixID
@end

@implementation _SNRMix

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SNRMix" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SNRMix";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SNRMix" inManagedObjectContext:moc_];
}

- (SNRMixID*)objectID {
	return (SNRMixID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"popularityValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"popularity"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"rankingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"ranking"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic dateModified;






@dynamic iTunesPersistentID;






@dynamic name;






@dynamic popularity;



- (double)popularityValue {
	NSNumber *result = [self popularity];
	return [result doubleValue];
}

- (void)setPopularityValue:(double)value_ {
	[self setPopularity:[NSNumber numberWithDouble:value_]];
}

- (double)primitivePopularityValue {
	NSNumber *result = [self primitivePopularity];
	return [result doubleValue];
}

- (void)setPrimitivePopularityValue:(double)value_ {
	[self setPrimitivePopularity:[NSNumber numberWithDouble:value_]];
}





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





@dynamic artwork;

	

@dynamic songs;

	
- (NSMutableOrderedSet*)songsSet {
	[self willAccessValueForKey:@"songs"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"songs"];
  
	[self didAccessValueForKey:@"songs"];
	return result;
}
	

@dynamic thumbnailArtwork;

	






@end
