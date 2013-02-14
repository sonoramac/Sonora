// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SNRPlayCount.m instead.

#import "_SNRPlayCount.h"

const struct SNRPlayCountAttributes SNRPlayCountAttributes = {
	.date = @"date",
};

const struct SNRPlayCountRelationships SNRPlayCountRelationships = {
	.song = @"song",
};

const struct SNRPlayCountFetchedProperties SNRPlayCountFetchedProperties = {
};

@implementation SNRPlayCountID
@end

@implementation _SNRPlayCount

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SNRPlayCount" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SNRPlayCount";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SNRPlayCount" inManagedObjectContext:moc_];
}

- (SNRPlayCountID*)objectID {
	return (SNRPlayCountID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic date;






@dynamic song;

	






@end
