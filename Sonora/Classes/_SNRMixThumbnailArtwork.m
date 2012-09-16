// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SNRMixThumbnailArtwork.m instead.

#import "_SNRMixThumbnailArtwork.h"

const struct SNRMixThumbnailArtworkAttributes SNRMixThumbnailArtworkAttributes = {
	.data = @"data",
	.generated = @"generated",
};

const struct SNRMixThumbnailArtworkRelationships SNRMixThumbnailArtworkRelationships = {
	.mix = @"mix",
};

const struct SNRMixThumbnailArtworkFetchedProperties SNRMixThumbnailArtworkFetchedProperties = {
};

@implementation SNRMixThumbnailArtworkID
@end

@implementation _SNRMixThumbnailArtwork

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SNRMixThumbnailArtwork" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SNRMixThumbnailArtwork";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SNRMixThumbnailArtwork" inManagedObjectContext:moc_];
}

- (SNRMixThumbnailArtworkID*)objectID {
	return (SNRMixThumbnailArtworkID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"generatedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"generated"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic data;






@dynamic generated;



- (BOOL)generatedValue {
	NSNumber *result = [self generated];
	return [result boolValue];
}

- (void)setGeneratedValue:(BOOL)value_ {
	[self setGenerated:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveGeneratedValue {
	NSNumber *result = [self primitiveGenerated];
	return [result boolValue];
}

- (void)setPrimitiveGeneratedValue:(BOOL)value_ {
	[self setPrimitiveGenerated:[NSNumber numberWithBool:value_]];
}





@dynamic mix;

	






@end
