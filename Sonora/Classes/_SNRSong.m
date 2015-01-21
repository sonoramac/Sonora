// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SNRSong.m instead.

#import "_SNRSong.h"

const struct SNRSongAttributes SNRSongAttributes = {
	.bookmark = @"bookmark",
	.compilation = @"compilation",
	.composer = @"composer",
	.dateAdded = @"dateAdded",
	.discNumber = @"discNumber",
	.discTotal = @"discTotal",
	.duration = @"duration",
	.iTunesPersistentID = @"iTunesPersistentID",
	.lyrics = @"lyrics",
	.name = @"name",
	.popularity = @"popularity",
	.ranking = @"ranking",
	.rawAlbumArtist = @"rawAlbumArtist",
	.rawArtist = @"rawArtist",
	.trackNumber = @"trackNumber",
	.trackTotal = @"trackTotal",
	.year = @"year",
};

const struct SNRSongRelationships SNRSongRelationships = {
	.album = @"album",
	.mixes = @"mixes",
	.playCounts = @"playCounts",
	.tags = @"tags",
};

@implementation SNRSongID
@end

@implementation _SNRSong

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SNRSong" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SNRSong";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SNRSong" inManagedObjectContext:moc_];
}

- (SNRSongID*)objectID {
	return (SNRSongID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"compilationValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"compilation"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"discNumberValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"discNumber"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"discTotalValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"discTotal"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"durationValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"duration"];
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
	if ([key isEqualToString:@"trackNumberValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"trackNumber"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"trackTotalValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"trackTotal"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"yearValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"year"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic bookmark;

@dynamic compilation;

- (BOOL)compilationValue {
	NSNumber *result = [self compilation];
	return [result boolValue];
}

- (void)setCompilationValue:(BOOL)value_ {
	[self setCompilation:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveCompilationValue {
	NSNumber *result = [self primitiveCompilation];
	return [result boolValue];
}

- (void)setPrimitiveCompilationValue:(BOOL)value_ {
	[self setPrimitiveCompilation:[NSNumber numberWithBool:value_]];
}

@dynamic composer;

@dynamic dateAdded;

@dynamic discNumber;

- (int32_t)discNumberValue {
	NSNumber *result = [self discNumber];
	return [result intValue];
}

- (void)setDiscNumberValue:(int32_t)value_ {
	[self setDiscNumber:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveDiscNumberValue {
	NSNumber *result = [self primitiveDiscNumber];
	return [result intValue];
}

- (void)setPrimitiveDiscNumberValue:(int32_t)value_ {
	[self setPrimitiveDiscNumber:[NSNumber numberWithInt:value_]];
}

@dynamic discTotal;

- (int32_t)discTotalValue {
	NSNumber *result = [self discTotal];
	return [result intValue];
}

- (void)setDiscTotalValue:(int32_t)value_ {
	[self setDiscTotal:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveDiscTotalValue {
	NSNumber *result = [self primitiveDiscTotal];
	return [result intValue];
}

- (void)setPrimitiveDiscTotalValue:(int32_t)value_ {
	[self setPrimitiveDiscTotal:[NSNumber numberWithInt:value_]];
}

@dynamic duration;

- (int32_t)durationValue {
	NSNumber *result = [self duration];
	return [result intValue];
}

- (void)setDurationValue:(int32_t)value_ {
	[self setDuration:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveDurationValue {
	NSNumber *result = [self primitiveDuration];
	return [result intValue];
}

- (void)setPrimitiveDurationValue:(int32_t)value_ {
	[self setPrimitiveDuration:[NSNumber numberWithInt:value_]];
}

@dynamic iTunesPersistentID;

@dynamic lyrics;

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

@dynamic rawAlbumArtist;

@dynamic rawArtist;

@dynamic trackNumber;

- (int32_t)trackNumberValue {
	NSNumber *result = [self trackNumber];
	return [result intValue];
}

- (void)setTrackNumberValue:(int32_t)value_ {
	[self setTrackNumber:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveTrackNumberValue {
	NSNumber *result = [self primitiveTrackNumber];
	return [result intValue];
}

- (void)setPrimitiveTrackNumberValue:(int32_t)value_ {
	[self setPrimitiveTrackNumber:[NSNumber numberWithInt:value_]];
}

@dynamic trackTotal;

- (int32_t)trackTotalValue {
	NSNumber *result = [self trackTotal];
	return [result intValue];
}

- (void)setTrackTotalValue:(int32_t)value_ {
	[self setTrackTotal:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveTrackTotalValue {
	NSNumber *result = [self primitiveTrackTotal];
	return [result intValue];
}

- (void)setPrimitiveTrackTotalValue:(int32_t)value_ {
	[self setPrimitiveTrackTotal:[NSNumber numberWithInt:value_]];
}

@dynamic year;

- (int32_t)yearValue {
	NSNumber *result = [self year];
	return [result intValue];
}

- (void)setYearValue:(int32_t)value_ {
	[self setYear:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveYearValue {
	NSNumber *result = [self primitiveYear];
	return [result intValue];
}

- (void)setPrimitiveYearValue:(int32_t)value_ {
	[self setPrimitiveYear:[NSNumber numberWithInt:value_]];
}

@dynamic album;

@dynamic mixes;

- (NSMutableSet*)mixesSet {
	[self willAccessValueForKey:@"mixes"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"mixes"];

	[self didAccessValueForKey:@"mixes"];
	return result;
}

@dynamic playCounts;

- (NSMutableSet*)playCountsSet {
	[self willAccessValueForKey:@"playCounts"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"playCounts"];

	[self didAccessValueForKey:@"playCounts"];
	return result;
}

@dynamic tags;

- (NSMutableSet*)tagsSet {
	[self willAccessValueForKey:@"tags"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"tags"];

	[self didAccessValueForKey:@"tags"];
	return result;
}

@end

