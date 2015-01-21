// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SNRArtwork.m instead.

#import "_SNRArtwork.h"

const struct SNRArtworkAttributes SNRArtworkAttributes = {
	.data = @"data",
};

const struct SNRArtworkRelationships SNRArtworkRelationships = {
	.album = @"album",
};

@implementation SNRArtworkID
@end

@implementation _SNRArtwork

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SNRArtwork" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SNRArtwork";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SNRArtwork" inManagedObjectContext:moc_];
}

- (SNRArtworkID*)objectID {
	return (SNRArtworkID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic data;

@dynamic album;

@end

