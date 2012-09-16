// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SNRArtist.m instead.

#import "_SNRArtist.h"

const struct SNRArtistAttributes SNRArtistAttributes = {
	.name = @"name",
	.ranking = @"ranking",
	.sortingName = @"sortingName",
};

const struct SNRArtistRelationships SNRArtistRelationships = {
	.albums = @"albums",
};

const struct SNRArtistFetchedProperties SNRArtistFetchedProperties = {
};

@implementation SNRArtistID
@end

@implementation _SNRArtist

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SNRArtist" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SNRArtist";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SNRArtist" inManagedObjectContext:moc_];
}

- (SNRArtistID*)objectID {
	return (SNRArtistID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"rankingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"ranking"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
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





@dynamic sortingName;






@dynamic albums;

	
- (NSMutableSet*)albumsSet {
	[self willAccessValueForKey:@"albums"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"albums"];
  
	[self didAccessValueForKey:@"albums"];
	return result;
}
	






@end
