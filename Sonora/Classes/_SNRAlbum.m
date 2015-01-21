// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SNRAlbum.m instead.

#import "_SNRAlbum.h"

const struct SNRAlbumAttributes SNRAlbumAttributes = {
	.dateModified = @"dateModified",
	.didSearchForArtwork = @"didSearchForArtwork",
	.name = @"name",
	.popularity = @"popularity",
	.ranking = @"ranking",
};

const struct SNRAlbumRelationships SNRAlbumRelationships = {
	.artist = @"artist",
	.artwork = @"artwork",
	.songs = @"songs",
	.thumbnailArtwork = @"thumbnailArtwork",
};

@implementation SNRAlbumID
@end

@implementation _SNRAlbum

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SNRAlbum" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SNRAlbum";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SNRAlbum" inManagedObjectContext:moc_];
}

- (SNRAlbumID*)objectID {
	return (SNRAlbumID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"didSearchForArtworkValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"didSearchForArtwork"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
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

@dynamic didSearchForArtwork;

- (BOOL)didSearchForArtworkValue {
	NSNumber *result = [self didSearchForArtwork];
	return [result boolValue];
}

- (void)setDidSearchForArtworkValue:(BOOL)value_ {
	[self setDidSearchForArtwork:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveDidSearchForArtworkValue {
	NSNumber *result = [self primitiveDidSearchForArtwork];
	return [result boolValue];
}

- (void)setPrimitiveDidSearchForArtworkValue:(BOOL)value_ {
	[self setPrimitiveDidSearchForArtwork:[NSNumber numberWithBool:value_]];
}

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

@dynamic artist;

@dynamic artwork;

@dynamic songs;

- (NSMutableSet*)songsSet {
	[self willAccessValueForKey:@"songs"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"songs"];

	[self didAccessValueForKey:@"songs"];
	return result;
}

@dynamic thumbnailArtwork;

@end

