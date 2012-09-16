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

#import "SNRSearchController.h"
#import "SNRQueueCoordinator.h"
#import "SNRArtistsViewController.h"
#import "SNRSearchIndex.h"
#import "SNRArtist.h"

#import "NSManagedObjectContext-SNRAdditions.h"

#define kMaxSearchResults 10

@interface SNRSearchController ()
- (NSString*)searchKitQueryForSearchQuery:(NSString*)query;
- (void)insertPlaceholderItemsIntoArray:(NSMutableArray*)array withQuery:(NSString*)query;

- (void)openSearchResultWithObject:(id)object;
- (void)increaseSearchRankingForObject:(id)object;
- (void)selectArtist:(id)artist;

- (void)managedObjectContextObjectsDidChange:(NSNotification*)notification;
@property (nonatomic, retain) SNRSearchIndexSearch *currentSearch;
@end

@implementation SNRSearchController {
    dispatch_queue_t _searchQueue;
}
@synthesize searchResults = _searchResults;
@synthesize currentSearch = _currentSearch;

#pragma mark - Initialization

- (id)init
{
    if ((self = [super init])) {
        _searchQueue = dispatch_queue_create("com.iktm.sonora.search", NULL);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextObjectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:SONORA_MANAGED_OBJECT_CONTEXT];
    }
    return self;
}

- (void)dealloc
{
    if (_searchQueue) { dispatch_release(_searchQueue); }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Search

- (void)performSearchForQuery:(NSString*)query handler:(void(^)(SNRSearchController *controller))handler
{
    if (![query length]) { 
        [self clearSearchQuery];
        return;
    }
    NSString *realQuery = [self searchKitQueryForSearchQuery:query];
    if (!realQuery) { return; }
    SNRSearchIndex *index = [SNRSearchIndex sharedIndex];
    self.currentSearch = [index searchForQuery:realQuery options:SNRSearchIndexSearchOptionDefault];
    dispatch_async(_searchQueue, ^(void) {
        [self.currentSearch findMatchesWithFetchLimit:kMaxSearchResults maximumTime:1.00 handler:^(NSArray *results) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                NSManagedObjectContext *ctx = SONORA_MANAGED_OBJECT_CONTEXT;
                NSMutableArray *searchResults = [NSMutableArray array];
                for (SNRSearchIndexSearchResult *result in results) {
                    NSManagedObject *object = [ctx existingObjectWithID:result.objectID error:nil];
                    if (object) { [searchResults addObject:object]; }
                }
                NSArray *descriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:kSortRankingKey ascending:NO], nil];
                [searchResults sortUsingDescriptors:descriptors];
                [self insertPlaceholderItemsIntoArray:searchResults withQuery:query];
                self.searchResults = searchResults;
                if (handler) handler(self);
            });
        }];
    });
}

- (void)insertPlaceholderItemsIntoArray:(NSMutableArray*)array withQuery:(NSString*)query
{
    NSString *lowerCaseQuery = [query lowercaseString];
    SNRArtistsStaticNodeType type = SNRArtistsStaticNodeTypeNone;
    if ([[NSLocalizedString(@"Albums", nil) lowercaseString] hasPrefix:lowerCaseQuery]) {
        type = SNRArtistsStaticNodeTypeAlbums;
    } else if ([[NSLocalizedString(@"Mixes", nil) lowercaseString] hasPrefix:lowerCaseQuery]) {
        type = SNRArtistsStaticNodeTypeMixes;
    } else if ([[NSLocalizedString(@"Compilations", nil) lowercaseString] hasPrefix:lowerCaseQuery]) {
        type = SNRArtistsStaticNodeTypeCompilations;
    }
    SNRArtistsViewController *artists = SNR_ArtistsViewController;
    if (type != SNRArtistsStaticNodeTypeNone && [artists hasStaticNodeWithType:type]) {
        SNRArtistsStaticNode *node = [[SNRArtistsStaticNode alloc] initWithType:type];
        [array insertObject:node atIndex:0];
    }
}

- (void)openSearchResultWithObject:(id)object
{
    BOOL commandKeyDown = ([NSEvent modifierFlags] & NSCommandKeyMask) == NSCommandKeyMask;
    if ([object isKindOfClass:[SNRArtistsNode class]]) {
        [self selectArtist:object];
    } else if ([object isKindOfClass:[SNRArtist class]]) {
        commandKeyDown ? [self enqueueObject:object] : [self selectArtist:object];
    } else {
        commandKeyDown ? [self enqueueObject:object] : [self playObject:object];
    }
    [self clearSearchQuery];
}

- (void)clearSearchQuery
{
    self.currentSearch = nil;
    self.searchResults = nil;
}

#pragma mark - Notifications

- (void)managedObjectContextObjectsDidChange:(NSNotification*)notification
{
    if (!self.searchResults) { return; }
    NSDictionary *userInfo = [notification userInfo];
    NSArray *deletedObjects = [[userInfo valueForKey:NSDeletedObjectsKey] allObjects];
    NSArray *updatedObjects = [[userInfo valueForKey:NSUpdatedObjectsKey] allObjects];
    NSMutableArray *newSearchResults = [NSMutableArray arrayWithArray:self.searchResults];
    BOOL objectsChanged = NO;
    for (NSManagedObject *object in deletedObjects) {
        [newSearchResults removeObject:object];
        objectsChanged = YES;
    }
    if (!objectsChanged) {
        for (NSManagedObject *object in updatedObjects) {
            if ([newSearchResults containsObject:object]) {
                objectsChanged = YES;
                break;
            }
        }
    }
    if (objectsChanged) {
        self.searchResults = newSearchResults;
    }
}

#pragma mark - Accessors

- (void)setCurrentSearch:(SNRSearchIndexSearch *)currentSearch
{
    if (currentSearch != _currentSearch) {
        [_currentSearch cancel];
        _currentSearch = currentSearch;
    }
}

#pragma mark - Private

- (NSString*)searchKitQueryForSearchQuery:(NSString*)query
{
    if (![query length]) { return nil; }
    NSArray *terms = [query componentsSeparatedByString:@" "];
    if ([terms count] > 1) {
        NSArray *remaining = [terms subarrayWithRange:NSMakeRange(1, [terms count] - 1)];
        for (NSString *term in remaining) {
            if ([term length] == 1) {
                return nil;
            }
        }
    }
    NSMutableString *realQuery = [NSMutableString string];
    for (NSString *term in terms) {
        if ([term length]) {
            [realQuery appendFormat:@"*%@* ", term];
        }
    }
    return realQuery;
}

- (void)selectArtist:(id)artist
{
    [SNR_ArtistsViewController selectArtist:artist];
    [SONORA_MAIN_WINDOW makeKeyAndOrderFront:nil];
    [self increaseSearchRankingForObject:artist];
}

- (void)enqueueObject:(id)object
{
    [SNR_MainQueueController enqueueObjects:[NSArray arrayWithObject:object]];
    [self increaseSearchRankingForObject:object];
}

- (void)playObject:(id)object
{
    SNRQueueController *controller = SNR_MainQueueController;
    if ([object isKindOfClass:[SNRSong class]]) {
        [controller clearQueueImmediately:YES];
        [controller enqueueObjects:[NSArray arrayWithObject:[object album]]];
        [controller playFromSong:object];
    } else {
        [controller playObjects:[NSArray arrayWithObject:object]];
    }
    [self increaseSearchRankingForObject:object];
}

- (void)increaseSearchRankingForObject:(id)object
{
    if (![object respondsToSelector:@selector(ranking)]) { return; }
    NSUInteger ranking = [[object valueForKey:@"ranking"] unsignedIntegerValue];
    ranking++;
    [object setValue:[NSNumber numberWithUnsignedInteger:ranking] forKey:@"ranking"];
    [[object managedObjectContext] saveChanges];
}
@end
