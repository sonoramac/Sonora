// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SNRThumbnailArtwork.m instead.

#import "_SNRThumbnailArtwork.h"

const struct SNRThumbnailArtworkAttributes SNRThumbnailArtworkAttributes = {
	.data = @"data",
};

const struct SNRThumbnailArtworkRelationships SNRThumbnailArtworkRelationships = {
	.album = @"album",
};

@implementation SNRThumbnailArtworkID
@end

@implementation _SNRThumbnailArtwork

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SNRThumbnailArtwork" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SNRThumbnailArtwork";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SNRThumbnailArtwork" inManagedObjectContext:moc_];
}

- (SNRThumbnailArtworkID*)objectID {
	return (SNRThumbnailArtworkID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic data;

@dynamic album;

@end

