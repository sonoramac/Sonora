//
//  SNRSearchIndex.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-07-22.
//  Copyright 2011 indragie.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 @class SNRSearchIndex
 A wrapper for SearchKit created specifically for Core Data. From the SearchKit documentation:
 "Search Kit is thread-safe. You can use separate indexing and searching threads. Your application is responsible for ensuring that no more than one process is open at a time for writing to an index."
 Since SearchKit itself is thread-safe, this wrapper is also thread-safe.
 */

typedef enum {
    SNRSearchIndexSearchOptionDefault, // compute relevance scores, spaces in query interpreted as AND, no similarity searching
    SNRSearchIndexSearchOptionNoRelevanceScores, // do not compute relevance scores
    SNRSearchIndexSearchOptionSpaceMeansOR, // spaces in ths search query are interpreted as OR instead of AND
    SNRSearchIndexSearchOptionFindSimilar // alters the search to find similar objects instead of exact matches
} SNRSearchIndexSearchOptions;

@class SNRSearchIndexSearch;
@interface SNRSearchIndex : NSObject
@property (nonatomic, readonly, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
/** The URL to the file that contains this search index */
@property (nonatomic, readonly, copy) NSURL *fileURL;
/** The underlying SKIndexRef, if you need to access it directly */
@property (nonatomic, readonly) SKIndexRef index;
/** The number of objects in the search index. (CFIndex = signed long) */
@property (nonatomic, readonly) CFIndex numberOfObjects;
/**
 Opens an existing search index at the specified URL. If it does not exist, this method will return nil
 @param url The URL to the file that stores this search index. If url is nil, then SNRSearchIndex will attempt to open the search index in the same directory as the first Core Data persistent store
 @param coordinator The persistent store coordinator for your Core Data persistent store
 */
- (id)initByOpeningSearchIndexAtURL:(NSURL*)url persistentStoreCoordinator:(NSPersistentStoreCoordinator*)coordinator;
/**
 Creates a new search index at the specified URL. If there is an error while creating, this method will return nil
 @param url The URL to the file that stores this search index. If url is nil, then SNRSearchIndex will automatically create an index file in the same directory as the first Core Data persistent store
 @param coordinator The persistent store coordinator for your Core Data persistent store
 */
- (id)initByCreatingSearchIndexAtURL:(NSURL*)url persistentStoreCoordinator:(NSPersistentStoreCoordinator*)coordinator;
/**
 @return A previously set shared instance of this object
 */
+ (id)sharedIndex;
/**
 Set a shared instance of SNRSearchIndex for easy access
 @param index An SNRSearchIndex object
 */
+ (void)setSharedIndex:(SNRSearchIndex*)index;
/**
 Compacts the search index to reduce fragmentation and commits changes to the backing store. Compacting can take a considerable amount of time, so do not call this method on the main thread or else it will block UI 
  @return YES if the operation was successful, otherwise NO
 */
- (BOOL)compact;
/**
 Commits all in-memory changes to the backing store. 
 @return YES if the operation was successful, otherwise NO
 */
- (BOOL)flush;
/**
 Sets the specified keywords under the object's entry in the index
 @param keywords An array of NSString's of keywords that describe the contents of the object
 @param objectID The object ID representing the managed object (safe to use across managed object contexts)
 */
- (BOOL)setKeywords:(NSArray*)keywords forObjectID:(NSManagedObjectID*)objectID;
/**
 Creates an autoreleased search object that can be used to execute a search
 @param query The search query. Check here <http://developer.apple.com/library/mac/documentation/UserExperience/Reference/SearchKit/Reference/reference.html#//apple_ref/c/func/SKSearchCreate> for more information on the query format. 
 @param options The search options
 @return An autoreleased SNRSearchIndexSearch object
 */
- (SNRSearchIndexSearch*)searchForQuery:(NSString*)query options:(SNRSearchIndexSearchOptions)options;
@end

/**
 @class SNRSearchIndexSearch
 Represents an asynchronous search operation for an SNRSearchIndex
 */
@interface SNRSearchIndexSearch : NSObject
/** The search index that this search operation searches */
@property (nonatomic, weak, readonly) SNRSearchIndex *searchIndex;
/** The raw SKSearchRef for this wrapper object */
@property (nonatomic, readonly) SKSearchRef search;
/**
 Begins an asynchronous search operation
 @param fetchLimit the total (maximum) number of results to fetch in the given maximum time. If the fetchLimit is 0, then as many search results as possible are returned
 @param time the maximum amount of time given to execute the search. If the maximumTime is 0, then results will be returned immediately
 @param handler The results handler for the search operation.
 @discussion This method can be called from a background thread to avoid blocking, and the search operation can be cancelled from the main thread.
 */
- (BOOL)findMatchesWithFetchLimit:(CFIndex)limit maximumTime:(NSTimeInterval)time handler:(void(^)(NSArray *results))handler;
/**
 Cancel the current search operation (if there is one)
 */
- (void)cancel;
@end

@interface SNRSearchIndexSearchResult : NSObject
/** The Core Data managed object ID. 
 @discussion Use NSManagedObjectContext's -objectWithID: to retrieve the object for this ID
 */
@property (nonatomic, retain, readonly) NSManagedObjectID *objectID;
/** The relevance score for the result. Scores can be scaled to a linear scale of 0.0 - 1.0 by dividing all the scores by the largest score. */
@property (nonatomic, readonly) float score;
@end