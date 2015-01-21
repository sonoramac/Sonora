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

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"popularityValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"popularity"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"rankingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"ranking"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
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

@implementation _SNRMix (SongsCoreDataGeneratedAccessors)
- (void)addSongs:(NSOrderedSet*)value_ {
	[self.songsSet unionOrderedSet:value_];
}
- (void)removeSongs:(NSOrderedSet*)value_ {
	[self.songsSet minusOrderedSet:value_];
}
- (void)addSongsObject:(SNRSong*)value_ {
	[self.songsSet addObject:value_];
}
- (void)removeSongsObject:(SNRSong*)value_ {
	[self.songsSet removeObject:value_];
}
- (void)insertObject:(SNRSong*)value inSongsAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"songs"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self songs]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"songs"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"songs"];
}
- (void)removeObjectFromSongsAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"songs"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self songs]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"songs"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"songs"];
}
- (void)insertSongs:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"songs"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self songs]];
    [tmpOrderedSet insertObjects:value atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"songs"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"songs"];
}
- (void)removeSongsAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"songs"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self songs]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"songs"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"songs"];
}
- (void)replaceObjectInSongsAtIndex:(NSUInteger)idx withObject:(SNRSong*)value {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"songs"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self songs]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"songs"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"songs"];
}
- (void)replaceSongsAtIndexes:(NSIndexSet *)indexes withSongs:(NSArray *)value {
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"songs"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self songs]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"songs"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"songs"];
}
@end

