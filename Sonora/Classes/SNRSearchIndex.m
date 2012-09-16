/*
 *  Copyright (C) 2012 Indragie Karunaratne <i@indragie.com>
 *  All Rights Reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 *
 *    - Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *    - Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *    - Neither the name of Indragie Karunaratne nor the names of its
 *      contributors may be used to endorse or promote products derived
 *      from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 *  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 *  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 *  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SNRSearchIndex.h"

static SNRSearchIndex *_sharedIndex = nil;

@interface SNRSearchIndexSearch ()
- (id)initWithSearchIndex:(SNRSearchIndex*)index query:(NSString*)query options:(SNRSearchIndexSearchOptions)options;
@end

@interface SNRSearchIndexSearchResult ()
- (id)initWithManagedObjectID:(NSManagedObjectID*)objectID relevanceScore:(float)score;
@end

@implementation SNRSearchIndex {
    SKIndexRef _index;
}
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize fileURL = _fileURL;
@synthesize index = _index; 

- (id)initByOpeningSearchIndexAtURL:(NSURL*)url persistentStoreCoordinator:(NSPersistentStoreCoordinator*)coordinator
{
    if (!url) {
        NSPersistentStore *store = [[coordinator persistentStores] objectAtIndex:0];
        url = [[[coordinator URLForPersistentStore:store] URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"searchindex"];
    }
    if ((self = [super init])) {
        _index = SKIndexOpenWithURL((__bridge CFURLRef)url, NULL, true);
        if (_index == NULL) {
            return nil;
        }
        _persistentStoreCoordinator = coordinator;
        _fileURL = [url copy];
    }
    return self;
}

- (id)initByCreatingSearchIndexAtURL:(NSURL*)url persistentStoreCoordinator:(NSPersistentStoreCoordinator*)coordinator
{
    if (!url) {
        NSPersistentStore *store = [[coordinator persistentStores] objectAtIndex:0];
        url = [[[coordinator URLForPersistentStore:store] URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"searchindex"];
    }
    if ((self = [super init])) {
        _index = SKIndexCreateWithURL((__bridge CFURLRef)url, NULL, kSKIndexInvertedVector, NULL);
        if (_index == NULL) {
            return nil;
        }
        _persistentStoreCoordinator = coordinator;
        _fileURL = [url copy];
    }
    return self;
}

+ (id)sharedIndex
{
    return _sharedIndex;
}

+ (void)setSharedIndex:(SNRSearchIndex *)sharedIndex
{
    if (sharedIndex != _sharedIndex) {
        _sharedIndex = sharedIndex;
    }
}

- (void)dealloc
{
    SKIndexClose(_index);
}

- (BOOL)compact
{
    return (BOOL)SKIndexCompact(_index);
}

- (BOOL)flush
{
    return (BOOL)SKIndexFlush(_index);
}

- (BOOL)setKeywords:(NSArray*)keywords forObjectID:(NSManagedObjectID*)objectID
{
    if (![keywords count]) {
        keywords = [NSArray arrayWithObject:@""];
    }
    NSString *keywordString = [keywords componentsJoinedByString:@" "];
    NSURL *objectURL = [objectID URIRepresentation];
    SKDocumentRef document = SKDocumentCreateWithURL((__bridge CFURLRef)objectURL);
    BOOL result = SKIndexAddDocumentWithText(_index, document, (__bridge CFStringRef)keywordString, true);
    CFRelease(document);
    return result;
}

- (SNRSearchIndexSearch*)searchForQuery:(NSString*)query options:(SNRSearchIndexSearchOptions)options
{
    SNRSearchIndexSearch *search = [[SNRSearchIndexSearch alloc] initWithSearchIndex:self query:query options:options];
    return search;
}

- (CFIndex)numberOfObjects
{
    return SKIndexGetDocumentCount(_index);
}

@end

@implementation SNRSearchIndexSearch  {
    BOOL _isSearching;
    SNRSearchIndexSearchOptions _options;
    SKSearchRef _search;
}
@synthesize searchIndex = _searchIndex;
@synthesize search = _search;

- (id)initWithSearchIndex:(SNRSearchIndex*)index query:(NSString*)query options:(SNRSearchIndexSearchOptions)options
{
    if ((self = [super init])) {
        _searchIndex = index;
        _options = options;
        _search = SKSearchCreate(_searchIndex.index, (__bridge CFStringRef)query, _options);
        if (_search == NULL) {
            return nil;
        }
    }
    return self;
}

- (BOOL)findMatchesWithFetchLimit:(CFIndex)limit maximumTime:(NSTimeInterval)time handler:(void(^)(NSArray *results))handler
{
    // Cancel an existing search if one is already going
    // Flush the index to commit all in-memory changes to the backing store
    [_searchIndex flush];
    // Loop until there are no more matches
    SKDocumentID documentIDs[limit];
    CFURLRef urls[limit];
    float scores[limit];
    CFIndex foundCount;
    Boolean result = SKSearchFindMatches(_search, limit, documentIDs, scores, time, &foundCount);
    // Copy the object URLs for the results 
    SKIndexCopyDocumentURLsForDocumentIDs(_searchIndex.index, foundCount, documentIDs, urls);
    // Loop through the results and create search result objects for each match
    NSMutableArray *results = [NSMutableArray array];
    for (CFIndex i = 0; i < foundCount; i++) {
        float score = scores[i];
        CFURLRef url = urls[i];
        NSManagedObjectID *objectID = [_searchIndex.persistentStoreCoordinator managedObjectIDForURIRepresentation:(__bridge NSURL*)url];
        if (!objectID) { 
            CFRelease(url);
            continue; 
        }
        SNRSearchIndexSearchResult *result = [[SNRSearchIndexSearchResult alloc] initWithManagedObjectID:objectID relevanceScore:score];
        [results addObject:result];
        CFRelease(url);
    }
    // Call the completion handler
    if (handler) {
        handler(results);
    }
    return (BOOL)result;
}

- (void)cancel
{
    SKSearchCancel(_search);
}

- (void)dealloc
{
    if (_isSearching) {
        [self cancel];
    }
    CFRelease(_search);
}
@end

@implementation SNRSearchIndexSearchResult
@synthesize objectID = _objectID;
@synthesize score = _score;

- (id)initWithManagedObjectID:(NSManagedObjectID *)objectID relevanceScore:(float)score
{
    assert(objectID);
    if ((self = [super init])) {
        _objectID = objectID;
        _score = score;
    }
    return self;
}

@end
