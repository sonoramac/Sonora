// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SNRMixArtwork.m instead.

#import "_SNRMixArtwork.h"

const struct SNRMixArtworkAttributes SNRMixArtworkAttributes = {
	.data = @"data",
	.generated = @"generated",
};

const struct SNRMixArtworkRelationships SNRMixArtworkRelationships = {
	.mix = @"mix",
};

@implementation SNRMixArtworkID
@end

@implementation _SNRMixArtwork

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SNRMixArtwork" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SNRMixArtwork";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SNRMixArtwork" inManagedObjectContext:moc_];
}

- (SNRMixArtworkID*)objectID {
	return (SNRMixArtworkID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"generatedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"generated"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
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

